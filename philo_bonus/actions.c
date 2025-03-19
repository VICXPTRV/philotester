/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   actions.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/13 09:31:06 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/17 15:03:17 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo_bonus.h"

// Special case to handle one philosopher.
// Returns "true" if one philosopher, otherwise "false".
bool	solo_eat_check(t_philo *p)
{
	if (p->bp->table->philo_count == 1)
	{
		set_state(p, FORK);
		sem_wait(p->bp->table->fork_count);
		print_state(p, "has taken a fork");
		philo_usleep(p, p->bp->table->time_to_die - \
			(unix_time_usec() - p->last_meal_time));
		set_state(p, DEAD);
		print_state(p, "died");
		sem_post(p->bp->table->fork_count);
		return (true);
	}
	return (false);
}

// Philosopher eat.
// Checking alive status while grabbing forks, and also after eating.
// Returns "true" if philosopher is alive, otherwise "false".
bool	philo_eat(t_philo *p)
{
	if (solo_eat_check(p))
		return (false);
	if (!forks_lock(p))
		return (false);
	set_state(p, EAT);
	p->last_meal_time = unix_time_usec();
	p->number_of_meals++;
	print_state(p, "is eating");
	philo_usleep(p, p->bp->table->time_to_eat);
	if (!is_alive(p))
		return (false);
	set_state(p, ATE);
	return (true);
}

// Philosopher sleep.
// Returns "true" if philosopher is alive, "false" if dead.
bool	philo_sleep(t_philo *p)
{
	set_state(p, SLEEP);
	print_state(p, "is sleeping");
	philo_usleep(p, p->bp->table->time_to_sleep);
	return (is_alive(p));
}

// Philosopher think.
// Philosophers in this simulation has a problem thinking when hungry,
// a trait they share with the author of this program.
// Returns "true" if philosopher is alive, "false" if dead.
bool	philo_think(t_philo *p)
{
	time_t	think_time;

	set_state(p, THINK);
	print_state(p, "is thinking");
	think_time = (p->last_meal_time + p->bp->table->time_to_die) - \
		unix_time_usec();
	if (think_time < 0)
		return (false);
	think_time /= 2;
	if (DEBUG)
		printf("DEBUG -- Philo %d think_time: %ldμs\n", p->nr + 1, think_time);
	philo_usleep(p, think_time);
	return (is_alive(p));
}
