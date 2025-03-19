/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   allocate.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/20 09:55:22 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/17 15:02:25 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo_bonus.h"

bool	allocate_fork_memory(t_backpack *bp)
{
	int32_t	i;

	i = 0;
	while (i < bp->table->philo_count)
	{
		bp->philos[i].forks = malloc(sizeof(t_forks));
		if (!bp->philos[i].forks)
			return (false);
		bp->philos[i].forks->left = malloc(sizeof(t_fork));
		if (!bp->philos[i].forks->left)
		{
			free(bp->philos[i].forks);
			return (false);
		}
		bp->philos[i].forks->right = malloc(sizeof(t_fork));
		if (!bp->philos[i].forks->right)
		{
			free(bp->philos[i].forks->left);
			free(bp->philos[i].forks);
			return (false);
		}
		i++;
	}
	return (true);
}

bool	allocate_memory(t_backpack *bp)
{
	bp->philos = malloc(sizeof(t_philo) * bp->table->philo_count);
	if (!bp->philos)
	{
		free(bp->table);
		return (false);
	}
	if (!allocate_fork_memory(bp))
		return (false);
	return (true);
}
