/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   time.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/01/28 10:08:46 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/14 13:27:29 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

// Returns Unix time in microseconds or -1 on fail.
time_t	unix_time_usec(void)
{
	struct timeval	tv;
	int				result;

	result = gettimeofday(&tv, NULL);
	if (result == -1)
		return (-1);
	return ((tv.tv_sec * 1000000) + tv.tv_usec);
}

// Philosopher thread sleep time, automatically adjust for timely death.
void	philo_usleep(t_philo *p, time_t sleep_time)
{
	time_t	alive_time;

	alive_time = (p->last_meal_time + p->bp->table->time_to_die) \
		- unix_time_usec();
	if (alive_time < 0)
		return ;
	if (alive_time < sleep_time)
		usleep(alive_time);
	else
		usleep(sleep_time);
}

// Philosopher initial delay before first meal to avoid fork fight.
void	philo_start_delay(t_philo *p)
{
	if (p->number_of_meals == 0)
	{
		if (p->bp->table->philo_count % 2 && p->nr == 0)
			usleep(p->bp->table->time_to_eat / 4);
		else if (p->nr % 2)
			usleep(p->bp->table->time_to_eat / 2);
	}
}
