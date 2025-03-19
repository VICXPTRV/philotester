/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   fork.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/19 15:24:36 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/17 15:02:45 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo_bonus.h"

void	set_fork_status(t_philo *p, t_fork *fork, enum e_fork_status status)
{
	sem_wait(p->lock);
	fork->st = status;
	sem_post(p->lock);
}

enum e_fork_status	get_fork_status(t_philo *p, t_fork *fork)
{
	enum e_fork_status	fork_status;

	sem_wait(p->lock);
	fork_status = fork->st;
	sem_post(p->lock);
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
		sem_wait(p->bp->table->fork_count);
		set_fork_status(p, p->forks->left, LOCKED);
		sem_wait(p->bp->table->fork_count);
		set_fork_status(p, p->forks->right, LOCKED);
		while (get_state(p) == FORK || get_state(p) == EAT)
			usleep(FORK_LOOP_DELAY);
		sem_post(p->bp->table->fork_count);
		set_fork_status(p, p->forks->left, UNLOCKED);
		sem_post(p->bp->table->fork_count);
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
