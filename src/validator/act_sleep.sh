#!/bin/bash

source utils/style.sh

validate_sleeping() {
	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_sleeping()"
	fi

	if [[ $F_PHILO_LOG_END == true ]]; then
		return; fi
	is_death_time "$time" && return


	if [[ $action =~ sleep ]]; then
		T_SLEEP_END=$(($time + $t_sleep))
		if [[ $(($time - $T_LAST_MEAL)) -gt $T_DELAY_TOLERANCE || $(($time - $T_LAST_MEAL)) -lt 0 ]]; then
			unexpected_action "Eating time error" ; return; fi
		move_to_next_action
	else
		unexpected_action "Enexpected action, expect sleep"; fi
}
