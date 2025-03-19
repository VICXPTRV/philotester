/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   philo.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/01/27 12:02:01 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/18 13:58:01 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PHILO_H
# define PHILO_H

# include <stdio.h>
# include <stdlib.h>
# include <pthread.h>
# include <unistd.h>
# include <sys/time.h>
# include <stdbool.h>
# include <inttypes.h>

# ifndef DEBUG
#  define DEBUG 0
# endif

# define PHILO_LIMIT 500
# define FORK_LOOP_DELAY 42

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
	int32_t				nr;
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
	pthread_t			tid;
	pthread_mutex_t		lock;
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
	bool			done;
	pthread_mutex_t	lock;
	pthread_mutex_t	*fork_locks;
}	t_table;

typedef struct s_backpack
{
	t_philo			*philos;
	t_table			*table;
}	t_backpack;

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
void				philo_start_delay(t_philo *p);

// output.c
void				print_state(t_philo *p, char *msg);

// free.c
void				free_memory(t_backpack *bp);

// clean_up.c
bool				clean_up(t_backpack *bp);

// create.c
void				*philo_thread(void *arg);
bool				create_philos(t_backpack *bp);

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

#endif
