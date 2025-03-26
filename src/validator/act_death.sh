#!/bin/bash

source utils/style.sh

validate_death() {

	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: time: $time, t_eat_end: $t_eat_end, t_die: $t_die"; fi

	if is_death_time "$time" && [[ $action =~ death ]]; then
		if [[ $T_DEATH_TIME -gt 0 ]]; then
			TEST_MSG="Program continues after first death $T_DEATH_TIME, $philo $time $action"
		elif [[ $F_TIMEOUT == true ]]; then
			TEST_MSG="Timeout after $T_TIMEOUT, no one died"
		fi

	elif (($time - ($t_eat_end + $t_die) > $T_DELAY_TOLERANCE_DEATH)); then
		TEST_MSG="Philo $philo died too late"
		F_FAIL=true
	fi

	F_PHILO_LOG_END=true
}

is_death_time() {
	t_current="$1"

	if [[ $T_DEATH_TIME -gt 0 && $t_current -ge $T_DEATH_TIME ]]; then
		return 0
	fi
	return 1
}

is_alive() {
	t_eat_end="$1"
	t_die="$2"

	if [[ $time -gt $((t_eat_end + t_die)) ]]; then
		if [[ $F_DEBUG == true ]]; then
			echo "			🐞DEBUG: DEATH_TIME set to $time by $philo"; fi
		DEATH_TIME=$time
		return 1
	fi
	return 0
}
