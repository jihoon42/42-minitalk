# CLAUDE.md — Minitalk (42 Project)

This file guides Claude Code when working on the Minitalk project.
Follow every rule here strictly. When in doubt, be more restrictive.

---

## Project Overview

Build two programs: `server` and `client`.

- **server**: starts first, prints its own PID, then waits for signals. Must handle multiple clients in a row without restarting. Must print received strings without noticeable delay.
- **client**: takes two arguments — the server PID and a string — then sends the string to the server bit by bit using only UNIX signals.

Communication must use **only** `SIGUSR1` and `SIGUSR2`. No other IPC mechanism is allowed.

---

## Allowed Functions

Only the following functions may be used (mandatory part):

```
write, ft_printf (or equivalent coded by the student),
signal, sigemptyset, sigaddset, sigaction,
kill, getpid,
malloc, free,
pause, sleep, usleep,
exit
```

A `libft/` folder may be used to hold helper functions needed by the project. However, every function inside it must be written from scratch — do not copy or import code from any existing libft repository. Only include functions that are actually needed by the project.

---

## Global Variables

Each program may use **at most one** global variable. Its use must be justified (signal handlers cannot receive extra arguments, so a global is the standard justification).

The global variable name must start with `g_` per the Norm.

---

## Bonus Part

Only implement if the mandatory part is fully complete and error-free.

- Server acknowledges each received message by sending a signal back to the client.
- Unicode (multi-byte) character support.

Bonus files must be named `*_bonus.c` / `*_bonus.h`.

---

## The 42 Norm (Version 4.1) — Enforced Rules

All `.c` and `.h` files must comply with the Norm. A norm error means a score of 0.

### Naming

- Variables, functions, types: `snake_case` only. No uppercase letters.
- `struct` names: prefix `s_`
- `typedef` names: prefix `t_`
- `union` names: prefix `u_`
- `enum` names: prefix `e_`
- Global variable names: prefix `g_`
- File and directory names: `snake_case` only.
- All identifiers must be meaningful English words or mnemonics.
- Non-ASCII characters are forbidden except inside string/char literals.

### Formatting

- Max **25 lines** per function (not counting the opening/closing braces of the function itself).
- Max **80 columns** per line (tabs count as the number of spaces they represent).
- Indent with **real tab characters** (ASCII 9), not spaces.
- Braces `{` and `}` are alone on their own line (except for struct/enum/union declarations).
- Blocks inside braces must be indented one level.
- Empty lines must be truly empty (no spaces or tabs).
- No trailing spaces or tabs at the end of any line.
- No two consecutive empty lines anywhere.
- No two consecutive spaces anywhere.
- Functions must be separated by exactly one empty line.
- One variable declaration per line.
- Declarations must all appear at the top of a function, before any instructions.
- One empty line between declarations and the first instruction inside a function. No other empty lines inside a function.
- All variable names in the same scope must be aligned on the same column.
- Pointer `*` is attached to the variable name, not the type: `char *str`, not `char* str`.
- Declaration and initialisation on the same line is forbidden (except for globals, statics, and constants).
- Only one instruction or control structure per line. No assignment inside a condition. No two assignments on the same line.
- Each comma or semicolon (unless at end of line) must be followed by a space.
- Each operator and operand must be separated by exactly one space.
- Each C keyword (`if`, `while`, `return`, `sizeof`, etc.) must be followed by a space, except type keywords (`int`, `char`, `float`, ...) and `sizeof`.
- Control structures (`if`, `while`) must use braces unless the body is a single instruction on a single line.
- `return` value must be in parentheses: `return (value);`. Void returns: `return ;`.
- Each function must have a single tab between its return type and its name.

### Functions

- Max **4 named parameters** per function.
- A function that takes no arguments must be prototyped as `func(void)`.
- All parameters in prototypes must be named.
- Max **5 variable declarations** per function.

### Files

- A `.c` file cannot be included in another `.c` or `.h` file.
- Max **5 function definitions** per `.c` file.

### Headers

- Header files must be protected against double inclusion:
  ```c
  #ifndef FT_FOO_H
  # define FT_FOO_H
  /* content */
  #endif
  ```
- Allowed content in headers: inclusions, declarations, defines, prototypes, macros.
- All `#include` directives must be at the top of the file.
- Unused headers must not be included.
- Structures cannot be declared in a `.c` file (declare in `.h`).

### Macros and Preprocessor

- `#define` constants must only be used for literal/constant values.
- `#define` must not be used to bypass the Norm or obfuscate code.
- Multiline macros are forbidden.
- Macro names must be ALL_UPPERCASE.
- Preprocessor directives inside `#if`/`#ifdef`/`#ifndef` blocks must be indented.
- Preprocessor instructions are forbidden outside global scope.

### Forbidden Constructs

The following are strictly forbidden:

```
for
do...while
switch / case
goto
?: (ternary operator)
VLAs (Variable Length Arrays)
Implicit types in variable declarations
```

### Comments

- Comments are not allowed inside function bodies.
- Comments may appear at the end of a line, or on their own line (outside functions).
- Comments must be in English and must be useful.
- A comment cannot justify a poorly designed or catch-all function.

### 42 Header

Every `.c` and `.h` file must begin with the standard 42 header comment (generated by the editor plugin). It must include the creator's login, student email, creation date, and last-update info.

---

## Makefile Requirements

The Makefile must include at least these rules: `$(NAME)`, `all`, `clean`, `fclean`, `re`.

- `all` must be the default rule (first rule in the file).
- `$(NAME)` for this project means two binaries: `client` and `server`. Define separate rules for each.
- No unnecessary relinking: recompile only what changed.
- No wildcards (`*.c`, `*.o`) — all source files must be listed explicitly.
- If `libft/` is used, the Makefile must compile it automatically via its own Makefile.
- For bonuses, a `bonus` rule must be added.

---

## Memory and Error Handling

- All heap-allocated memory must be freed before the program exits.
- No memory leaks are tolerated.
- The program must never crash with a segfault, bus error, double free, or similar under normal usage.
- Error cases must be handled explicitly.

---

## Performance Requirement

Displaying 100 characters must not take 1 second or more. Using `usleep` between each bit send is acceptable as long as it is short enough (typically ≤ 100µs per signal).

---

## Suggested File Structure

```
minitalk/
├── CLAUDE.md
├── Makefile
├── minitalk.h
├── server.c
├── client.c
├── libft/           (optional — only if helper functions are needed, written from scratch)
├── server_bonus.c   (bonus only)
├── client_bonus.c   (bonus only)
└── minitalk_bonus.h (bonus only)
```

The `.h` file must contain all shared type definitions, macros, and function prototypes. No struct definitions in `.c` files.
