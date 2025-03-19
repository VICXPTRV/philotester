/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   init.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/04 09:43:45 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/18 14:16:25 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo_bonus.h"

// Gets a prefix string and appends a hex number string.
// Returns a string with the full sempahore name.
char	*get_sem_name(char *prefix_str, int32_t philo_nr)
{
	char			*nr_str;
	char			*result;
	const int32_t	prefix_len = ft_strlen(prefix_str);
	int32_t			nr_len;

	nr_str = ft_putnbr_base(philo_nr, "0123456789abcdef");
	if (!nr_str)
		return (NULL);
	nr_len = ft_strlen(nr_str);
	result = malloc(sizeof(char) * (prefix_len + nr_len + 1));
	if (!result)
		return (NULL);
	ft_memcpy(&result[0], prefix_str, prefix_len);
	ft_memcpy(&result[prefix_len], nr_str, nr_len + 1);
	free(nr_str);
	return (result);
}

// Initializes the "lock" semaphore for each philosopher, also making sure
// each semaphore name is unique by adding number suffix.
bool	init_philo_semaphores(t_backpack *bp)
{
	int32_t	i;

	i = 0;
	while (i < bp->table->philo_count)
	{
		bp->philos[i].semname_lock = get_sem_name(SEM_NAME_PHILO_LOCK, i);
		if (!bp->philos[i].semname_lock)
			return (false);
		if (DEBUG)
			printf("DEBUG -- Semaphore lock name: %s\n", \
				bp->philos[i].semname_lock);
		sem_unlink(bp->philos[i].semname_lock);
		bp->philos[i].lock = sem_open(bp->philos[i].semname_lock, \
			O_CREAT, S_IRUSR | S_IWUSR, 1);
		if (bp->philos[i].lock == SEM_FAILED)
			return (false);
		i++;
	}
	return (true);
}

// Initializes fork "count", "lock" and "done" semaphores.
bool	init_semaphores(t_backpack *bp)
{
	sem_unlink(SEM_NAME_FORK_COUNT);
	bp->table->fork_count = sem_open(SEM_NAME_FORK_COUNT, \
		O_CREAT, S_IRUSR | S_IWUSR, bp->table->philo_count);
	sem_unlink(SEM_NAME_TABLE_LOCK);
	bp->table->lock = sem_open(SEM_NAME_TABLE_LOCK, \
		O_CREAT, S_IRUSR | S_IWUSR, 1);
	sem_unlink(SEM_NAME_TABLE_DONE);
	bp->table->done = (t_sem *) sem_open(SEM_NAME_TABLE_DONE, \
		O_CREAT, S_IRUSR | S_IWUSR, 0);
	if (bp->table->fork_count == SEM_FAILED || bp->table->lock == SEM_FAILED \
		|| bp->table->done == (t_sem *) SEM_FAILED)
		return (false);
	if (!init_philo_semaphores(bp))
		return (false);
	return (true);
}

// Sets initial values for parts of the philosopher structure and start time.
void	set_philos(t_backpack *bp)
{
	int32_t	i;

	i = 0;
	while (i < bp->table->philo_count)
	{
		bp->philos[i].nr = i;
		bp->philos[i].state = EAT;
		bp->philos[i].forks->left->st = UNLOCKED;
		bp->philos[i].forks->right->st = UNLOCKED;
		bp->philos[i].number_of_meals = 0;
		bp->philos[i].bp = bp;
		i++;
	}
	bp->table->start_time = unix_time_usec();
	if (DEBUG)
		printf("DEBUG -- Main process Unix start time in microseconds: %ld\n", \
			bp->table->start_time);
}

// Allocate memory, set arguments, initialize sempahores and set each
// philosopher defaults.
bool	init(t_backpack *bp, int argc, char **argv)
{
	bp->table = malloc(sizeof(t_table));
	if (!bp->table)
		return (false);
	bp->table->philo_count = philo_atol(argv[1]);
	bp->table->time_to_die = philo_atol(argv[2]) * 1000;
	bp->table->time_to_eat = philo_atol(argv[3]) * 1000;
	bp->table->time_to_sleep = philo_atol(argv[4]) * 1000;
	if (argc == 6)
		bp->table->must_eat = philo_atol(argv[5]);
	else
		bp->table->must_eat = -1;
	if (!allocate_memory(bp))
	{
		printf("\nError when allocating memory.\n");
		return (false);
	}
	if (!init_semaphores(bp))
	{
		printf("\nError when initializing semaphores.\n");
		free_memory(bp);
		return (false);
	}
	set_philos(bp);
	return (true);
}
