# By: rvesterl <rvesterl@student.42bangkok.com>

CC = cc
CFLAGS = -Wall -Wextra -Werror -pthread

NAME = philo

SRC = philo.c \
	  input.c \
	  output.c \
	  allocate.c \
	  init.c \
	  time.c \
	  free.c \
	  clean_up.c \
	  create.c \
	  state.c \
	  actions.c \
	  fork.c

HDR = .

OBJ = $(SRC:.c=.o)

.PHONY: all clean fclean re debug

all: $(NAME)

debug: CFLAGS = -g -O0 -Wall -Wextra -Werror -D DEBUG=1 -pthread
debug: re

$(NAME): $(OBJ) philo.h
	$(CC) $(CFLAGS) $(OBJ) -o $(NAME)

%.o: %.c Makefile philo.h
	$(CC) $(CFLAGS) -I $(HDR) -c $< -o $@

clean:
	rm -f $(OBJ)

fclean:
	rm -f $(NAME)
	rm -f $(OBJ)

re: fclean all
