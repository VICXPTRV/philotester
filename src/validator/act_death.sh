#!/bin/bash

source utils/style.sh

is_death_time() {
	t_current="$1"

	if [[ $F_DEBUG == true ]]; then
		echo "			🐞DEBUG: [$philo]: cur:$t_current meal:$T_LAST_MEAL die:$t_die is_death_time()"; fi

	if [[ $((t_current - T_LAST_MEAL)) -gt $((t_die + T_DELAY_TOLERANCE_DEATH)) ]]; then
		validate_death
		return 0
	fi
	return 1
}

validate_death() {
	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: T_DEATH: $time by [$philo] [$action] validate_death()"; fi

	T_DEATH=$time
	set_programm_end "$T_DEATH"
	move_to_next_action
	if [[ $action =~ die ]]; then
		F_FAIL=false
	else
		unexpected_action "Action after death"
	fi
}
