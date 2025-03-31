#!/bin/bash

validate_fork() {

	if [[ $F_DEBUG == true ]]; then		
		echo -e "🐞DEBUG: FORK [$time] [$philo] [$action], T_DEATH=$T_DEATH"; fi

	if [[ $F_PHILO_LOG_END == true ]]; then
		return; fi

	if is_death_time "$time" || [[ $action =~ die ]]; then
		validate_death
		return; fi

	if ! [[ $action =~ fork ]]; then
		unexpected_action "Unexpected action, expect fork"; return; fi

	move_to_next_action
}
