#!/bin/bash

source utils/style.sh

validate_sleeping() {

	if [[ $F_PHILO_LOG_END == true ]]; then
		return
	fi

	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_sleeping()"
	fi

	if [[ $action =~ sleep ]] && is_alive "$t_eat_end" "$t_die" ; then
		t_sleep_start=$time
		if [[ $t_sleep_start -ne $t_eat_end && $t_sleep_start -gt $(($t_eat_end + $T_DELAY_TOLERANCE)) ]]; then
			TEST_MSG="Philo $philo eating duration is wrong"
			F_FAIL=true
			F_PHILO_LOG_END=true
			return
		fi
		move_to_next_action
	else
		validate_last_action
	fi
}