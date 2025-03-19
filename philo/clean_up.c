/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   clean_up.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/04 09:56:40 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/14 13:29:05 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

// Wait for each philosopher thread to end.
bool	wait_philos(t_backpack *bp)
{
	int32_t	i;

	i = 0;
	while (i < bp->table->philo_count)
	{
		if (pthread_join(bp->philos[i].tid, NULL) != 0)
			return (false);
		i++;
	}
	return (true);
}

bool	destroy_mutex(t_backpack *bp)
{
	int32_t	i;

	i = 0;
	while (i < bp->table->philo_count)
	{
		if (pthread_mutex_destroy(&bp->table->fork_locks[i]) != 0)
		{
			printf("Destroying mutex for fork %d failed\n", i);
			return (false);
		}
		if (pthread_mutex_destroy(&bp->philos[i].lock) != 0)
		{
			printf("Destroying mutex for philo %d failed\n", i);
			return (false);
		}
		i++;
	}
	if (pthread_mutex_destroy(&bp->table->lock) != 0)
		return (false);
	return (true);
}

// Wait for threads to end, destroy mutex, free memory.
bool	clean_up(t_backpack *bp)
{
	if (!wait_philos(bp))
	{
		printf("\nError joining thread!\n");
		free_memory(bp);
		return (false);
	}
	if (DEBUG)
		printf("DEBUG -- Unix end time in microseconds: %ld\n", \
			unix_time_usec());
	if (!destroy_mutex(bp))
	{
		printf("\nError destroying mutex!\n");
		free_memory(bp);
		return (false);
	}
	free_memory(bp);
	return (true);
}
