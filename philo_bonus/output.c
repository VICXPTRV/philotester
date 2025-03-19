/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   output.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/01/30 13:54:30 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/17 15:04:26 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo_bonus.h"

// Printing state while locking both table and philosophers as needed.
void	print_state(t_philo *p, char *msg)
{
	time_t	time_stamp;
	t_sem	*fork_count;

	fork_count = (t_sem *) p->bp->table->fork_count;
	sem_wait(p->bp->table->lock);
	time_stamp = ((unix_time_usec() - p->bp->table->start_time)) / 1000;
	if (!p->bp->table->done->value)
		printf("%ld %d %s\n", time_stamp, p->nr + 1, msg);
	sem_wait(p->lock);
	if (!p->bp->table->done->value && p->state == DEAD)
	{
		sem_post((sem_t *) p->bp->table->done);
		if (DEBUG)
			printf("DEBUG -- R.I.P. We are done!\n");
	}
	if (DEBUG && !p->bp->table->done->value && p->state == EAT)
	{
		printf("DEBUG -- fork_count: %d\n", fork_count->value);
	}
	sem_post(p->lock);
	sem_post(p->bp->table->lock);
}
