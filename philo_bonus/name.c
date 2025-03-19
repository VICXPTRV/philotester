/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   name.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <rvesterl@student.42bangkok.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/09/12 09:28:07 by rvesterl          #+#    #+#             */
/*   Updated: 2025/03/17 15:02:14 by rvesterl         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo_bonus.h"

size_t	ft_strlen(const char *str)
{
	size_t	i;

	i = 0;
	while (str[i] != '\0')
		i++;
	return (i);
}

static int32_t	validate_base(char *base)
{
	int32_t			i;
	int32_t			j;
	const int32_t	len = ft_strlen(base);

	if (len <= 1)
		return (0);
	i = 0;
	while (i < len)
	{
		j = i + 1;
		while (j < len)
		{
			if (base[i] == base[j])
			{
				return (0);
			}
			j++;
		}
		if (base[i] == '+' || base[i] == '-')
			return (0);
		i++;
	}
	return (len);
}

static int32_t	buf_len(int32_t lnbr, char *base)
{
	int32_t			len;
	const int32_t	len_base = ft_strlen(base);

	len = 1;
	if (lnbr < 0)
	{
		len++;
		lnbr = -lnbr;
	}
	while (lnbr >= len_base)
	{
		lnbr /= len_base;
		len++;
	}
	return (len);
}

char	*ft_putnbr_base(int32_t lnbr, char *base)
{
	const int32_t	len_base = validate_base(base);
	int32_t			i;
	char			*buf;

	i = buf_len(lnbr, base);
	buf = malloc(sizeof(char) * (i + 1));
	if (!buf)
		return (NULL);
	if (len_base)
	{
		if (lnbr < 0)
		{
			buf[0] = '-';
			lnbr = -lnbr;
		}
		buf[i--] = '\0';
		while (len_base <= lnbr)
		{
			buf[i--] = base[lnbr % len_base];
			lnbr /= len_base;
		}
		buf[i] = base[lnbr % len_base];
		return (buf);
	}
	return (NULL);
}

void	*ft_memcpy(void *dest, const void *src, size_t len)
{
	const char	*s;
	char		*d;

	if (!dest && !src)
		return (NULL);
	s = (const char *) src;
	d = (char *) dest;
	while (len--)
		*d++ = *s++;
	return (dest);
}
