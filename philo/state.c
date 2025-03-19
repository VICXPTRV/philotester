/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   state.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/21 13:37:08 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/15 10:45:33 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

// Checks if philosopher is alive.
// Returns "true" if alive, "false" if dead.
bool	is_alive(t_philo *p)
{
	if ((unix_time_usec() - p->last_meal_time) < p->bp->table->time_to_die)
		return (true);
	set_state(p, DEAD);
	print_state(p, "died");
	return (false);
}

// Check if it's time to end the philosopher thread.
// Returns "true" if philosopher is done, otherwise "false".
bool	check_done(t_philo *p)
{
	bool	result;

	pthread_mutex_lock(&p->bp->table->lock);
	if (p->bp->table->done || (p->bp->table->must_eat > 0 && \
		p->number_of_meals >= p->bp->table->must_eat))
		result = true;
	else
		result = false;
	pthread_mutex_unlock(&p->bp->table->lock);
	return (result);
}

// Sets state for individual philosopher.
void	set_state(t_philo *p, enum e_pstate new_state)
{
	const char	*st[] = \
		{"FORK", "EAT", "ATE", "SLEEP", "THINK", "DEAD", "DONE"};

	pthread_mutex_lock(&p->lock);
	p->state = new_state;
	pthread_mutex_unlock(&p->lock);
	if (DEBUG)
	{
		pthread_mutex_lock(&p->bp->table->lock);
		printf("DEBUG -- Philo %d changed state to \"%s\" at Δ%ldμs.\n", \
			p->nr + 1, st[new_state], \
			(unix_time_usec() - p->bp->table->start_time));
		pthread_mutex_unlock(&p->bp->table->lock);
	}
}

// Gets state for individual philosopher.
enum e_pstate	get_state(t_philo *p)
{
	enum e_pstate	philo_state;

	pthread_mutex_lock(&p->lock);
	philo_state = p->state;
	pthread_mutex_unlock(&p->lock);
	return (philo_state);
}
