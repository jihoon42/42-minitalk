#!/bin/bash
# ============================================================================
#  minitalk_test.sh — macOS / Linux test for minitalk (42)
#  Usage:  bash minitalk_test.sh [usleep_value]
# ============================================================================

export LC_ALL=C

RED='\033[1;31m'; GRN='\033[1;32m'; YEL='\033[1;33m'
BLU='\033[1;34m'; MAG='\033[1;35m'; CYN='\033[1;36m'; NC='\033[0m'

PASS=0; FAIL=0; TOTAL=0; SERVER_PID=""
TMPDIR_MT="/tmp/mt_$$"
mkdir -p "$TMPDIR_MT"

ok()    { PASS=$((PASS+1)); TOTAL=$((TOTAL+1)); printf "${GRN}OK${NC}\n"; }
ko()    { FAIL=$((FAIL+1)); TOTAL=$((TOTAL+1)); printf "${RED}KO${NC}  %s\n" "$1"; }
title() { printf "${BLU}%-40s${NC}: " "$1"; }

stop_server() {
    if [ -n "$SERVER_PID" ] && kill -0 "$SERVER_PID" 2>/dev/null; then
        kill "$SERVER_PID" 2>/dev/null
        wait "$SERVER_PID" 2>/dev/null
    fi
    SERVER_PID=""
}

final_cleanup() {
    stop_server
    rm -rf "$TMPDIR_MT"
}
trap final_cleanup EXIT

start_server() {
    stop_server
    sleep 0.2
    ./server > "$TMPDIR_MT/srv.txt" 2>&1 &
    SERVER_PID=$!
    local tries=0; S_PID=""
    while [ $tries -lt 20 ]; do
        if [ -s "$TMPDIR_MT/srv.txt" ]; then
            S_PID=$(head -1 "$TMPDIR_MT/srv.txt" 2>/dev/null)
            if [ -n "$S_PID" ] && kill -0 "$SERVER_PID" 2>/dev/null; then
                return 0
            fi
        fi
        sleep 0.1; tries=$((tries + 1))
    done
    printf "${RED}ERROR: server failed to start${NC}\n"
    return 1
}

# get server output (skip PID line, strip newlines)
srv_payload() {
    tail -n +2 "$TMPDIR_MT/srv.txt" 2>/dev/null | LC_ALL=C tr -d '\n'
}

send_and_check() {
    local name="$1" msg="$2" expected="$3" timeout="${4:-5}"
    title "$name"
    if ! start_server; then ko "server start failed"; return; fi
    ./client "$S_PID" "$msg" 2>/dev/null
    sleep "$timeout"
    local actual; actual=$(srv_payload)
    if [ "$actual" = "$expected" ]; then ok
    else ko "exp='$(printf '%.50s' "$expected")' got='$(printf '%.50s' "$actual")'"; fi
}

send_and_check_file() {
    local name="$1" expfile="$2" timeout="$3"
    title "$name"
    if ! start_server; then ko "server start failed"; return; fi
    ./client "$S_PID" "$(cat "$expfile")" 2>/dev/null
    sleep "$timeout"
    srv_payload > "$TMPDIR_MT/actual.txt"
    if diff -q "$expfile" "$TMPDIR_MT/actual.txt" > /dev/null 2>&1; then ok
    else
        local alen elen info
        alen=$(wc -c < "$TMPDIR_MT/actual.txt" | tr -d ' ')
        elen=$(wc -c < "$expfile" | tr -d ' ')
        info=$(python3 -c "
with open('$expfile','rb') as e, open('$TMPDIR_MT/actual.txt','rb') as a:
    eb,ab=e.read(),a.read()
    for i in range(min(len(eb),len(ab))):
        if eb[i]!=ab[i]: print(f'pos {i}: exp=0x{eb[i]:02x} got=0x{ab[i]:02x}'); break
    else: print(f'len: exp={len(eb)} got={len(ab)}')
" 2>/dev/null || echo "?")
        ko "exp=$elen got=$alen $info"
    fi
}

# ── Setup ───────────────────────────────────────────────────────────────────
DIR="$(cd "$(dirname "$0")" && pwd)"; cd "$DIR"
printf "${MAG}══════════════════════════════════════════════════════${NC}\n"
printf "${MAG}       minitalk test  —  $(date +%F)  ($(uname -s)) ${NC}\n"
printf "${MAG}══════════════════════════════════════════════════════${NC}\n\n"

# Kill stale servers from previous runs
pkill -f '\./server$' 2>/dev/null || true; sleep 0.2

PATCHED=""
if [ -n "$1" ]; then
    printf "${YEL}[patch]${NC} usleep -> ${CYN}%s${NC}\n" "$1"
    cp client.c client.c.bak; PATCHED="1"
    if [ "$(uname -s)" = "Darwin" ]; then
        sed -i '' "s/usleep([0-9]*)/usleep($1)/" client.c
    else
        sed -i "s/usleep([0-9]*)/usleep($1)/" client.c
    fi
fi

printf "${CYN}[compile]${NC} make re ... "
if make re > "$TMPDIR_MT/make.log" 2>&1; then printf "${GRN}OK${NC}\n\n"
else printf "${RED}FAIL${NC}\n"; cat "$TMPDIR_MT/make.log"; exit 1; fi

# ═══════════════════════════════════════════════════════════════════════════

send_and_check "1. Basic string" "Hello, 42!" "Hello, 42!" 1

title "2. Empty string (null byte only)"
if start_server; then
    ./client "$S_PID" "" 2>/dev/null; sleep 1
    LC=$(wc -l < "$TMPDIR_MT/srv.txt" | tr -d ' ')
    if [ "$LC" -ge 2 ]; then ok; else ko "expected >=2 lines, got $LC"; fi
else ko "server start failed"; fi

send_and_check "3. Special chars" \
    'Test `~!@#$%^&*()_+-=[]{}|;:,.<>?' \
    'Test `~!@#$%^&*()_+-=[]{}|;:,.<>?' 1

send_and_check "4. Tabs in string" \
    "$(printf '123\t456\t789')" "$(printf '123\t456\t789')" 1

python3 -c "print('A'*100, end='')" > "$TMPDIR_MT/exp100.txt"
send_and_check_file "5. 100 characters" "$TMPDIR_MT/exp100.txt" 3

python3 -c "print('B'*500, end='')" > "$TMPDIR_MT/exp500.txt"
send_and_check_file "6. 500 characters" "$TMPDIR_MT/exp500.txt" 5

python3 -c "print('C'*1000, end='')" > "$TMPDIR_MT/exp1000.txt"
send_and_check_file "7. 1000 characters" "$TMPDIR_MT/exp1000.txt" 8

title "8. Multiple clients (no restart)"
if start_server; then
    ./client "$S_PID" "First" 2>/dev/null;  sleep 1
    ./client "$S_PID" "Second" 2>/dev/null; sleep 1
    ./client "$S_PID" "Third" 2>/dev/null;  sleep 1
    ACTUAL=$(tail -n +2 "$TMPDIR_MT/srv.txt" | LC_ALL=C tr '\n' '|')
    if echo "$ACTUAL" | grep -q "First" && echo "$ACTUAL" | grep -q "Second" \
       && echo "$ACTUAL" | grep -q "Third"; then ok
    else ko "got='$ACTUAL'"; fi
else ko "server start failed"; fi

title "9. Speed: 100 chars < 1 second"
if start_server; then
    MSG100=$(python3 -c "print('X'*100, end='')")
    ST=$(python3 -c "import time; print(int(time.time()*1000))")
    ./client "$S_PID" "$MSG100" 2>/dev/null
    EN=$(python3 -c "import time; print(int(time.time()*1000))")
    MS=$((EN - ST)); sleep 0.5
    if [ "$MS" -lt 1000 ]; then ok; printf "                                          (${CYN}%d ms${NC})\n" "$MS"
    else ko "took ${MS}ms"; fi
else ko "server start failed"; fi

python3 -c "print('A'*5000, end='')" > "$TMPDIR_MT/exp5ku.txt"
send_and_check_file "10. 5000 chars (uniform)" "$TMPDIR_MT/exp5ku.txt" 15

python3 -c "
import string; s=string.printable[:94]; print((s*54)[:5000], end='')
" > "$TMPDIR_MT/exp5km.txt"
send_and_check_file "11. 5000 chars (mixed)" "$TMPDIR_MT/exp5km.txt" 15

# ═══════════════════════════════════════════════════════════════════════════
printf "\n${MAG}══════════════════════════════════════════════════════${NC}\n"
printf "  ${GRN}PASS: %d${NC}  ${RED}FAIL: %d${NC}  TOTAL: %d\n" "$PASS" "$FAIL" "$TOTAL"
if [ "$FAIL" -eq 0 ]; then printf "  ${GRN}All tests passed!${NC}\n"
else
    printf "  ${YEL}Some tests failed.${NC}\n"
    printf "  ${CYN}Tip: 5000ch flaky at usleep(100) = signal loss.${NC}\n"
    printf "  ${CYN}     Try:  bash minitalk_test.sh 200${NC}\n"
    printf "  ${CYN}     Bonus ACK mode fixes this completely.${NC}\n"
fi
printf "${MAG}══════════════════════════════════════════════════════${NC}\n"

if [ -n "$PATCHED" ]; then
    mv client.c.bak client.c
    printf "\n${YEL}[reverted]${NC} client.c restored\n"
fi
exit "$FAIL"
