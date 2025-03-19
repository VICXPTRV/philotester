/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   input.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/01/27 12:01:24 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/18 14:14:58 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

static int32_t	walk_space(const char *s)
{
	int32_t	i;

	i = 0;
	while (s[i] == ' ' || s[i] == '\f' || s[i] == '\n' || \
		s[i] == '\r' || s[i] == '\t' || s[i] == '\v')
		i++;
	return (i);
}

int64_t	philo_atol(const char *str)
{
	int32_t	i;
	int64_t	result;

	result = 0;
	i = walk_space(str);
	if (str[i] == '-')
		return (-1);
	else if (str[i] == '+')
		i++;
	while (str[i] != '\0')
	{
		if (str[i] >= '0' && str[i] <= '9')
		{
			result *= 10;
			result += (str[i++] - '0');
		}
		else
			return (-1);
	}
	return (result);
}

bool	check_input(int argc, char **argv)
{
	int	i;

	if (argc == 5 || argc == 6)
	{
		i = 0;
		while (argv[++i])
		{
			if ((i == 1 && philo_atol(argv[i]) <= 0) || \
				(i > 1 && philo_atol(argv[i]) < 0))
			{
				printf("Error: Invalid input.\n");
				return (false);
			}
		}
		if (philo_atol(argv[1]) > PHILO_LIMIT)
		{
			printf("Too many philosophers.\n");
			return (false);
		}
		return (true);
	}
	printf("Usage: %s <number_of_philosophers> <time_to_die> <time_to_eat> "
		"<time_to_sleep> [number_of_times_each_philosopher_must_eat]\n", \
			argv[0]);
	return (false);
}
