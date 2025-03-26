#!/bin/bash

source utils/style.sh

validate_eating() {

	if [[ $F_PHILO_LOG_END == true ]]; then
		return
	fi

	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_eating()"
	fi

	if [[ $action =~ eat ]] && is_alive "$T_LAST_MEAL" "$t_die" ; then
		t_eat_start=$time
		((meals_eaten++))
		T_LAST_MEAL=$(($t_eat_start + $t_eat))		
		move_to_next_action
	else
		validate_last_action
	fi

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
