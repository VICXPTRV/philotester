/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   create.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/04 11:39:43 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/17 15:04:06 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo_bonus.h"

// Philosopher process, one for each, also starts fork thread.
void	philo_process(t_philo *p)
{
	if (DEBUG)
		printf("DEBUG -- Hello, I'm philo nr %d.\n", p->nr + 1);
	if (p->bp->table->philo_count > 1 && \
		pthread_create(&p->forks->tid, NULL, &fork_thread, p) != 0)
		printf("\nError creating fork thread for philosopher: %d\n", p->nr + 1);
	p->last_meal_time = unix_time_usec();
	while (!check_done(p))
	{
		if (!philo_eat(p))
			break ;
		if (!philo_sleep(p))
			break ;
		if (!philo_think(p))
			break ;
	}
	set_state(p, DONE);
	if (p->bp->table->philo_count > 1 && \
		pthread_join(p->forks->tid, NULL) != 0)
		printf("\nError joining fork thread for philosopher: %d\n", p->nr + 1);
	if (DEBUG)
		printf("DEBUG -- Goodbye, I'm philo nr %d.\n", p->nr + 1);
}

// Creating philosopher processes.
// Returns value to control path of execution for parent and child processes.
int32_t	create_philos(t_backpack *bp)
{
	int32_t	i;

	i = 0;
	while (i < bp->table->philo_count)
	{
		bp->philos[i].pid = fork();
		if (DEBUG && bp->philos[i].pid > 0)
			printf("DEBUG -- Process %d for philosopher %d started.\n", \
				bp->philos[i].pid, i + 1);
		if (bp->philos[i].pid == -1)
		{
			printf("\nError forking process for philosopher: %d\n", i + 1);
			free_memory(bp);
			return (CR_ERROR);
		}
		else if (bp->philos[i].pid == 0)
		{
			philo_process(&bp->philos[i]);
			return (CR_PROCESS);
		}
		i++;
	}
	return (CR_MAIN);
}
