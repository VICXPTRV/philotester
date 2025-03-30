#!/bin/bash

validate_eating() {

	if [[ $F_DEBUG == true ]]; then		
		echo -e "\n🐞DEBUG: EAT [$time] [$philo] [$action] validate_eating(), T_DEATH=$T_DEATH"; fi

	if [[ $F_PHILO_LOG_END == true ]]; then
		return; fi

	if is_death_time "$time" || [[ $action =~ die ]]; then
		validate_death; return; fi

	if ! [[ $action =~ eat ]]; then
		unexpected_action "Unexpected action, expect eat"; return; fi

	T_LAST_MEAL=$time	
	((meals_eaten++))
	move_to_next_action
}

validate_meals_eaten() {

	if [[ -z $meals_to_eat ]]; then
		return
	fi
	if [[ $meals_eaten -lt $meals_to_eat ]]; then
		TEST_MSG="Philo $philo: Should eat at least $meals_to_eat times, but ate $meals_eaten"
		F_FAIL=true
	fi
}
code 