#!/bin/bash

source utils/style.sh

validate_thinking() {

	if [[ $F_PHILO_LOG_END == true ]]; then
		return
	fi

	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_thinking()"
	fi
	if [[ $action =~ think ]] && is_alive  "$t_die" ; then
		t_sleep_end=$time
		if [[ $t_sleep -ne $((t_sleep_end - t_sleep_start)) ]]; then
			TEST_MSG="Philo $philo: Time to sleep is wrong"
			F_FAIL=true
			F_PHILO_LOG_END=true
			return; fi
		move_to_next_action
	else
		validate_last_action
	fi
}
