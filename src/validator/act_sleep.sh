#!/bin/bash

validate_sleeping() {
	if [[ $F_DEBUG == true ]]; then
		echo "🐞DEBUG: SLEEP [$time] [$philo] [$action] last_meal[$T_LAST_MEAL] validate_sleeping()"; fi

	if [[ $F_PHILO_LOG_END == true ]]; then
		return; fi
	if is_death_time "$time" || [[ $action =~ die ]]; then
		validate_death; return; fi

	if ! [[ $action =~ sleep ]]; then
		unexpected_action "Unexpected action, expect sleep"; return; fi

	T_SLEEP_END=$(($time + $t_sleep))
	if (( time - T_LAST_MEAL < t_eat || time - T_LAST_MEAL > t_eat + T_DELAY_TOLERANCE )); then
		unexpected_action "Eating time error" ; return; fi
	move_to_next_action
}
