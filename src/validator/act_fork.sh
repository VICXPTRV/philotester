#!/bin/bash

source utils/style.sh

validate_fork() {
	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_fork()"; fi

	if [[ $F_PHILO_LOG_END == true ]]; then
		return; fi

	is_death_time "$time" && return
	if [[ $action =~ fork ]]; then
		move_to_next_action
	else
		unexpected_action "Unexpected action, expect fork"; fi
}
