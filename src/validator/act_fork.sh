#!/bin/bash

source utils/style.sh

validate_fork() {

	if [[ $FLAG_END == true ]]; then
		return
	fi

	if [[ $flag_debug == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_fork()"
	fi

	if [[ $action =~ fork ]] && is_alive "$t_eat_end" "$t_die" ; then
		move_to_next_action
	else
		validate_last_action
	fi
}
