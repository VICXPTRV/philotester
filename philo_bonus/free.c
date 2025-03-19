/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   free.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/24 10:05:07 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/17 15:02:36 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo_bonus.h"

void	free_fork_sem_memory(t_backpack *bp)
{
	int32_t	i;

	i = 0;
	while (i < bp->table->philo_count)
	{
		free(bp->philos[i].forks->left);
		free(bp->philos[i].forks->right);
		free(bp->philos[i].forks);
		free(bp->philos[i].semname_lock);
		i++;
	}
}

void	free_memory(t_backpack *bp)
{
	free_fork_sem_memory(bp);
	free(bp->philos);
	free(bp->table);
	free(bp);
}
