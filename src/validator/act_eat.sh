#!/bin/bash

source utils/style.sh

validate_eating() {
	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_eating()"; fi

	if [[ $F_PHILO_LOG_END == true ]]; then
		return; fi

	is_death_time "$time" && return

	if [[ $action =~ eat ]]; then
		T_LAST_MEAL=$(($time + $t_eat))		
		((meals_eaten++))
		move_to_next_action
	else
		unexpected_action "Unexpected action, expect eat" ; fi
}

validate_meals_eaten() {

	if [[ -z $meals_to_eat ]]; then
		return
	fi
	if [[ $meals_eaten -lt $meals_to_eat ]]; then
		TEST_MSG="Philo $philo: Should eat at least $meals_to_eat times, but ate $meals_eaten"
		F_FAIL=true
		F_PHILO_LOG_END=true
	fi
}
code 