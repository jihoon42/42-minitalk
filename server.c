/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   server.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jkim2 <jkim2@student.42gyeongsan.kr>       +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/03/16 10:19:22 by jkim2             #+#    #+#             */
/*   Updated: 2026/03/16 10:19:27 by jkim2            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minitalk.h"
#include "libft/libft.h"

t_data	g_data;

static void	handle_signal(int sig)
{
	if (sig == SIGUSR2)
		g_data.c |= (1 << g_data.bit);
	g_data.bit++;
	if (g_data.bit == 8)
	{
		if (g_data.c == '\0')
			write(1, "\n", 1);
		else
			write(1, &g_data.c, 1);
		g_data.bit = 0;
		g_data.c = 0;
	}
}

int	main(void)
{
	struct sigaction	sa;

	ft_putnbr_fd(getpid(), 1);
	write(1, "\n", 1);
	sa.sa_handler = handle_signal;
	sa.sa_flags = SA_RESTART;
	sigemptyset(&sa.sa_mask);
	sigaddset(&sa.sa_mask, SIGUSR1);
	sigaddset(&sa.sa_mask, SIGUSR2);
	sigaddset(&sa.sa_mask, SIGINT);
	sigaction(SIGUSR1, &sa, NULL);
	sigaction(SIGUSR2, &sa, NULL);
	while (1)
		pause();
	return (0);
}
