#!/bin/bash

validate_thinking() {
	if [[ $F_DEBUG == true ]]; then		
		echo "🐞DEBUG: THINK [$time] [$philo] [$action] validate_thinking(), T_DEATH=$T_DEATH"; fi

	if [[ $F_PHILO_LOG_END == true ]]; then
		return; fi

	if is_death_time "$time" || [[ $action =~ die ]]; then
		validate_death
		return
	fi

	if ! [[ $action =~ think ]]; then
		unexpected_action "Enexpected action, expect think"; return; fi

	if [[ $(($time - $T_SLEEP_END)) -gt $T_DELAY_TOLERANCE || $(($time - $T_SLEEP_END)) -lt 0 ]]; then
		unexpected_action "Sleeping time error"
		return
	fi
	move_to_next_action
}
