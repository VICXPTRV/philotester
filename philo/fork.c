/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   fork.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/19 15:24:36 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/17 10:42:03 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

void	set_fork_status(t_philo *p, t_fork *fork, enum e_fork_status status)
{
	pthread_mutex_lock(&p->lock);
	fork->st = status;
	pthread_mutex_unlock(&p->lock);
}

enum e_fork_status	get_fork_status(t_philo *p, t_fork *fork)
{
	enum e_fork_status	fork_status;

	pthread_mutex_lock(&p->lock);
	fork_status = fork->st;
	pthread_mutex_unlock(&p->lock);
	return (fork_status);
}

// Fork thread to handle locks.
void	*fork_thread(void *arg)
{
	t_philo	*p;

	p = (t_philo *) arg;
	while (get_state(p) != DONE)
	{
		while (get_state(p) != FORK)
		{
			usleep(FORK_LOOP_DELAY);
			if (get_state(p) == DONE)
				return (NULL);
		}
		pthread_mutex_lock(&p->bp->table->fork_locks[p->forks->left->nr]);
		set_fork_status(p, p->forks->left, LOCKED);
		pthread_mutex_lock(&p->bp->table->fork_locks[p->forks->right->nr]);
		set_fork_status(p, p->forks->right, LOCKED);
		while (get_state(p) == FORK || get_state(p) == EAT)
			usleep(FORK_LOOP_DELAY);
		pthread_mutex_unlock(&p->bp->table->fork_locks[p->forks->left->nr]);
		set_fork_status(p, p->forks->left, UNLOCKED);
		pthread_mutex_unlock(&p->bp->table->fork_locks[p->forks->right->nr]);
		set_fork_status(p, p->forks->right, UNLOCKED);
	}
	return (NULL);
}

// Checks if philosopher died while trying to get lock.
bool	wait_fork(t_philo *p, t_fork *fork)
{
	while (get_fork_status(p, fork) == UNLOCKED)
	{
		if (!is_alive(p))
			return (false);
		usleep(FORK_LOOP_DELAY);
	}
	return (true);
}

// Checking if philosopher is alive while locking forks.
bool	forks_lock(t_philo *p)
{
	bool		living;

	set_state(p, FORK);
	living = wait_fork(p, p->forks->left);
	if (living)
		print_state(p, "has taken a fork");
	if (living)
		living = wait_fork(p, p->forks->right);
	if (living)
		print_state(p, "has taken a fork");
	return (living);
}
