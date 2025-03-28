#!/bin/bash

source utils/style.sh

validate_thinking() {
	if [[ $F_DEBUG == true ]]; then		
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_thinking(), t_death: $T_DEATH"; fi

	if [[ $F_PHILO_LOG_END == true || $T_DEATH -gt -1 ]]; then
		return; fi

	is_death_time "$time" && return

	if [[ $action =~ think ]]; then
		if [[ $(($time - $T_SLEEP_END)) -gt $T_DELAY_TOLERANCE || $(($time - $T_SLEEP_END)) -lt 0 ]]; then
			unexpected_action "Sleeping time error"
			return
		fi
		move_to_next_action
	else
		unexpected_action "Enexpected action, expect think"
	fi
}
