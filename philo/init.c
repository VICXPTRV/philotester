/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   init.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/04 09:43:45 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/18 14:00:14 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

bool	init_mutex(t_backpack *bp)
{
	int32_t	i;

	i = 0;
	while (i < bp->table->philo_count)
	{
		if (pthread_mutex_init(&bp->table->fork_locks[i], NULL) != 0)
			return (false);
		i++;
	}
	if (pthread_mutex_init(&bp->table->lock, NULL) != 0)
		return (false);
	return (true);
}

// Forks are also grabbed interleaved to avoid helgrind lock order violation.
void	set_forks(t_philo *p, int32_t philo_count)
{
	if (p->nr % 2)
	{
		p->forks->left->nr = p->nr;
		p->forks->right->nr = (p->nr + 1) % philo_count;
	}
	else
	{
		p->forks->left->nr = (p->nr + 1) % philo_count;
		p->forks->right->nr = p->nr;
	}
	p->forks->left->st = UNLOCKED;
	p->forks->right->st = UNLOCKED;
}

void	set_philos(t_backpack *bp)
{
	int32_t	i;

	i = 0;
	if (DEBUG)
		printf("DEBUG -- Fork distribution.\n");
	while (i < bp->table->philo_count)
	{
		bp->philos[i].nr = i;
		bp->philos[i].state = EAT;
		set_forks(&bp->philos[i], bp->table->philo_count);
		bp->philos[i].number_of_meals = 0;
		bp->philos[i].bp = bp;
		if (pthread_mutex_init(&bp->philos[i].lock, NULL) != 0)
			printf("\nError initiating mutex lock for philosopher: %d\n", i);
		if (DEBUG)
		{
			printf("DEBUG -- Philo %d will take fork %d in left hand.\n", \
				i + 1, bp->philos[i].forks->left->nr + 1);
			printf("DEBUG -- Philo %d will take fork %d in right hand.\n", \
				i + 1, bp->philos[i].forks->right->nr + 1);
		}
		i++;
	}
}

// Allocate memory, set arguments, initialize mutex and set each philosopher
// defaults.
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
	bp->table->done = false;
	if (!allocate_memory(bp))
	{
		printf("\nError when allocating memory.\n");
		return (false);
	}
	if (!init_mutex(bp))
	{
		printf("\nError when initializing mutex.\n");
		free_memory(bp);
		return (false);
	}
	set_philos(bp);
	return (true);
}
