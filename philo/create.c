/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   create.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/04 11:39:43 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/15 10:37:21 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

// Philosopher thread, one for each, also starts fork thread.
void	*philo_thread(void *arg)
{
	t_philo		*p;

	p = (t_philo *) arg;
	if (DEBUG)
		printf("DEBUG -- Hello, I'm philo nr %d, thread started.\n", p->nr + 1);
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
		printf("DEBUG -- Goodbye, I'm philo nr %d, thread ended.\n", p->nr + 1);
	return (NULL);
}

// Setting start_time and creating philosopher threads.
bool	create_philos(t_backpack *bp)
{
	int32_t	i;

	bp->table->start_time = unix_time_usec();
	if (DEBUG)
		printf("DEBUG -- Unix start time in microseconds: %ld\n", \
			bp->table->start_time);
	i = 0;
	while (i < bp->table->philo_count)
	{
		if (pthread_create(&bp->philos[i].tid, NULL, \
			&philo_thread, &bp->philos[i]) != 0)
		{
			printf("\nError creating thread for philosopher: %d\n", i + 1);
			free_memory(bp);
			return (false);
		}
		i++;
	}
	return (true);
}
