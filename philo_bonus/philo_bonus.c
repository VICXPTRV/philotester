/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   philo_bonus.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/01/27 12:01:45 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/18 10:39:46 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo_bonus.h"

int	main(int argc, char **argv)
{
	t_backpack	*bp;
	int32_t		creation_status;

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
	creation_status = create_philos(bp);
	if (creation_status == CR_ERROR)
		return (1);
	if (creation_status == CR_PROCESS)
	{
		if (!clean_up_proc(bp))
			return (1);
	}
	else if (creation_status == CR_MAIN)
		if (!clean_up(bp))
			return (1);
	return (0);
}
