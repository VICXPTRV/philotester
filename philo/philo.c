/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   philo.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/01/27 12:01:45 by rvesterl          #+#    #+#             */
/*   Updated: 2025/02/11 11:15:25 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

int	main(int argc, char **argv)
{
	t_backpack	*bp;

	if (!check_input(argc, argv))
		return (1);
	bp = malloc(sizeof(t_backpack));
	if (!bp)
	{
		printf("Error allocating memory.\n");
		return (1);
	}
	if (!init(bp, argc, argv))
		return (1);
	if (!create_philos(bp))
		return (1);
	if (!clean_up(bp))
		return (1);
	return (0);
}
