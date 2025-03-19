/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   philo_bonus.h                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/01/27 12:02:01 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/18 14:16:53 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PHILO_BONUS_H
# define PHILO_BONUS_H

# include <stdio.h>
# include <stdlib.h>
# include <pthread.h>
# include <unistd.h>
# include <sys/time.h>
# include <stdbool.h>
# include <inttypes.h>
# include <fcntl.h>
# include <sys/stat.h>
# include <semaphore.h>
# include <signal.h>
# include <sys/wait.h>
# include <limits.h>

# ifndef DEBUG
#  define DEBUG 0
# endif

# define PHILO_LIMIT 500
# define FORK_LOOP_DELAY 42

# define SEM_NAME_FORK_COUNT "/philo_fork_count"
# define SEM_NAME_TABLE_LOCK "/philo_table_lock"
# define SEM_NAME_TABLE_START "/philo_table_start"
# define SEM_NAME_TABLE_DONE "/philo_table_done"
# define SEM_NAME_PHILO_LOCK "/philo_lock_"

# if INTPTR_MAX == INT64_MAX
#  define SEM_SIZE 32
# else
#  define SEM_SIZE 16
# endif

# define CR_ERROR -1
# define CR_PROCESS 1
# define CR_MAIN 0

enum e_pstate
{
	FORK,
	EAT,
	ATE,
	SLEEP,
	THINK,
	DEAD,
	DONE
};

enum e_fork_status
{
	UNLOCKED,
	LOCKED
};

typedef struct s_fork
{
	enum e_fork_status	st;
}	t_fork;

typedef struct s_forks
{
	t_fork		*left;
	t_fork		*right;
	pthread_t	tid;
}	t_forks;

typedef struct s_philo
{
	enum e_pstate		state;
	int32_t				nr;
	t_forks				*forks;
	int64_t				number_of_meals;
	time_t				last_meal_time;
	char				*semname_lock;
	sem_t				*lock;
	pid_t				pid;
	struct s_backpack	*bp;
}	t_philo;

typedef struct s_table
{
	int32_t			philo_count;
	time_t			start_time;
	time_t			time_to_die;
	time_t			time_to_eat;
	time_t			time_to_sleep;
	int64_t			must_eat;
	sem_t			*lock;
	sem_t			*fork_count;
	union u_sem		*done;
}	t_table;

typedef struct s_backpack
{
	t_philo			*philos;
	t_table			*table;
}	t_backpack;

typedef union u_sem
{
	char		size[SEM_SIZE];
	int32_t		value;
}	t_sem;

// input.c
bool				check_input(int argc, char **argv);
int64_t				philo_atol(const char *str);

// allocate.c
bool				allocate_memory(t_backpack *bp);

// init.c
bool				init(t_backpack *bp, int argc, char **argv);

// time.c
time_t				unix_time_usec(void);
void				philo_usleep(t_philo *p, time_t sleep_time);

// output.c
void				print_state(t_philo *p, char *msg);

// free.c
void				free_memory(t_backpack *bp);

// clean_up.c
bool				clean_up(t_backpack *bp);
bool				clean_up_proc(t_backpack *bp);

// create.c
void				philo_process(t_philo *p);
int32_t				create_philos(t_backpack *bp);

// state.c
bool				is_alive(t_philo *p);
bool				check_done(t_philo *p);
void				set_state(t_philo *p, enum e_pstate new_state);
enum e_pstate		get_state(t_philo *p);

// actions.c
bool				solo_eat_check(t_philo *p);
bool				philo_eat(t_philo *p);
bool				philo_sleep(t_philo *p);
bool				philo_think(t_philo *p);

// fork.c
void				*fork_thread(void *arg);
bool				forks_lock(t_philo *p);

// name.c
size_t				ft_strlen(const char *str);
char				*ft_putnbr_base(int32_t nbr, char *base);
void				*ft_memcpy(void *dest, const void *src, size_t len);

#endif
