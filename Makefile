SERVER = server
CLIENT = client

CC = cc
CFLAGS = -Wall -Wextra -Werror

SERVER_SRCS = server.c
CLIENT_SRCS = client.c
SERVER_OBJS = $(SERVER_SRCS:.c=.o)
CLIENT_OBJS = $(CLIENT_SRCS:.c=.o)

LIBFT_DIR = libft
LIBFT = $(LIBFT_DIR)/libft.a

all: $(SERVER) $(CLIENT)

$(LIBFT):
	$(MAKE) -C $(LIBFT_DIR)

$(SERVER): $(SERVER_OBJS) $(LIBFT)
	$(CC) $(CFLAGS) $(SERVER_OBJS) $(LIBFT) -o $(SERVER) 2>/dev/null

$(CLIENT): $(CLIENT_OBJS) $(LIBFT)
	$(CC) $(CFLAGS) $(CLIENT_OBJS) $(LIBFT) -o $(CLIENT) 2>/dev/null

%.o: %.c minitalk.h
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	$(MAKE) -C $(LIBFT_DIR) clean
	rm -f $(SERVER_OBJS) $(CLIENT_OBJS)

fclean: clean
	$(MAKE) -C $(LIBFT_DIR) fclean
	rm -f $(SERVER) $(CLIENT)

re: fclean all

.PHONY: all clean fclean re
