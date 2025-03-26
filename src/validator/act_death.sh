#!/bin/bash

source utils/style.sh

validate_death() {

	if [[ $flag_debug == true ]]; then
		echo "		🐞DEBUG: time: $time, t_eat_end: $t_eat_end, t_die: $t_die"
	fi
	if is_later_than_death "$time"; then
		TEST_MSG="Program continues after first death $T_DEATH_TIME, $philo $time $action"

	elif (($time - ($t_eat_end + $t_die) > $T_DELAY_TOLERANCE_DEATH)); then
		TEST_MSG="Philo $philo died too late"
		FLAG_FAIL=true
	fi

	FLAG_END=true
}

is_later_than_death() {
	t_current="$1"

	if [[ $T_DEATH_TIME -gt 0 && $t_current -gt $T_DEATH_TIME ]]; then
		FAIL_FLAG=true
		return 0
	fi
	return 1
}

is_alive() {
	t_eat_end="$1"
	t_die="$2"

	if [[ $time -gt $((t_eat_end + t_die)) ]]; then
		if [[ $flag_debug == true ]]; then
			echo "			🐞DEBUG: DEATH_TIME set to $time by $philo"; fi
		DEATH_TIME=$time
		return 1
	fi
	return 0
}
