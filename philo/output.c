/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   output.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/01/30 13:54:30 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/14 13:29:58 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

// Printing state while locking both table and philosophers as needed.
void	print_state(t_philo *p, char *msg)
{
	time_t	time_stamp;

	pthread_mutex_lock(&p->bp->table->lock);
	time_stamp = ((unix_time_usec() - p->bp->table->start_time) / 1000);
	if (!p->bp->table->done)
		printf("%ld %d %s\n", time_stamp, p->nr + 1, msg);
	pthread_mutex_lock(&p->lock);
	if (!p->bp->table->done && p->state == DEAD)
	{
		p->bp->table->done = true;
		if (DEBUG)
			printf("DEBUG -- R.I.P. We are done!\n");
	}
	pthread_mutex_unlock(&p->lock);
	pthread_mutex_unlock(&p->bp->table->lock);
}
