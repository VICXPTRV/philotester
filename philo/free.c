/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   free.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/02/24 10:05:07 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/13 09:17:09 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

void	free_fork_memory(t_backpack *bp)
{
	int32_t	i;

	i = 0;
	while (i < bp->table->philo_count)
	{
		free(bp->philos[i].forks->left);
		free(bp->philos[i].forks->right);
		free(bp->philos[i].forks);
		i++;
	}
}

void	free_memory(t_backpack *bp)
{
	free_fork_memory(bp);
	free(bp->philos);
	free(bp->table->fork_locks);
	free(bp->table);
	free(bp);
}
