/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   clean_up.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/04 09:56:40 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/17 15:03:54 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo_bonus.h"

// Wait for philosopher processes to finish.
void	wait_philos(t_backpack *bp)
{
	int32_t	i;
	int		wstatus;

	i = 0;
	while (i < bp->table->philo_count)
	{
		waitpid(bp->philos[i].pid, &wstatus, 0);
		if (DEBUG && bp->philos[i].pid > 0)
			printf("DEBUG -- Process %d for philosopher %d terminated " \
			"with status %d.\n", bp->philos[i].pid, i + 1, wstatus);
		i++;
	}
}

bool	close_philo_semaphores(t_backpack *bp)
{
	int32_t	i;

	i = 0;
	while (i < bp->table->philo_count)
	{
		sem_unlink(bp->philos[i].semname_lock);
		if (sem_close(bp->philos[i].lock) != 0)
		{
			printf("Closing lock semaphore for philo %d failed\n", i);
			return (false);
		}
		i++;
	}
	return (true);
}

bool	close_semaphores(t_backpack *bp)
{
	if (!close_philo_semaphores(bp))
		return (false);
	sem_unlink(SEM_NAME_TABLE_LOCK);
	if (sem_close(bp->table->lock) != 0)
		return (false);
	sem_unlink(SEM_NAME_FORK_COUNT);
	if (sem_close(bp->table->fork_count) != 0)
		return (false);
	sem_unlink(SEM_NAME_TABLE_DONE);
	if (sem_close((sem_t *) bp->table->done) != 0)
		return (false);
	return (true);
}

// Main parent process waits for processes to end, close semaphores,
// and free memory.
bool	clean_up(t_backpack *bp)
{
	wait_philos(bp);
	if (DEBUG)
		printf("DEBUG -- Main process Unix end time in microseconds: %ld\n", \
			unix_time_usec());
	if (!close_semaphores(bp))
	{
		printf("\nError closing semaphores!\n");
		free_memory(bp);
		return (false);
	}
	free_memory(bp);
	return (true);
}

// Forked child processes goes here to close semaphores and free memory.
bool	clean_up_proc(t_backpack *bp)
{
	if (!close_semaphores(bp))
	{
		printf("\nError closing semaphores!\n");
		free_memory(bp);
		return (false);
	}
	free_memory(bp);
	return (true);
}
