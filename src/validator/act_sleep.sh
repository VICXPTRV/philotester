#!/bin/bash

source utils/style.sh

validate_sleeping() {

	if [[ $FLAG_END == true ]]; then
		return
	fi

	if [[ $flag_debug == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_sleeping()"
	fi

	if [[ $action =~ sleep ]] && is_alive "$t_eat_end" "$t_die" ; then
		t_sleep_start=$time
		if [[ $t_sleep_start -ne $t_eat_end && $t_sleep_start -gt $(($t_eat_end + $T_DELAY_TOLERANCE)) ]]; then
			TEST_MSG="Philo $philo eating duration is wrong"
			FLAG_FAIL=true
			FLAG_END=true
			return
		fi
		move_to_next_action
	else
		validate_last_action
	fi
}