#!/bin/bash

source utils/style.sh

validate_fork() {

	if [[ $F_PHILO_LOG_END == true ]]; then
		return
	fi

	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_fork()"
	fi

	if [[ $action =~ fork ]] && is_alive "$t_die" ; then
		move_to_next_action
	else
		validate_last_action
	fi
}
