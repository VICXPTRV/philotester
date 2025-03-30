#!/bin/bash

is_death_time() {
	t_current="$1"

	if [[ $F_DEBUG == true ]]; then
		echo "⌛ is_death_time() [$philo]: t_currnt=$t_current T_LAST_MEAL=$T_LAST_MEAL"; fi

	if (( t_current - T_LAST_MEAL >= t_die && t_current - T_LAST_MEAL <= t_die + T_DELAY_TOLERANCE_DEATH )); then
		return 0
	fi
	return 1
}

validate_death() {
	if [[ $F_DEBUG == true ]]; then
		echo -e "\n🐞DEBUG: DEATH [$time] [$philo] [$action] validate_death()"; fi

	F_ANY_DEATH=true

	[[ $T_DEATH -eq -1 ]] && T_DEATH=$time && ( [[ $F_DEBUG == true ]] && echo "⚠️  SET T_DEATH=$time" )
	if [[ $time -lt $T_DEATH ]]; then
		T_DEATH=$time && [[ $F_DEBUG == true ]] && echo "⚠️  SET T_DEATH=$time"
		F_FAIL=true
		set_programm_end "$T_DEATH"
		return; fi

	set_programm_end "$T_DEATH"
	move_to_next_action
	if [[ $action =~ die ]]; then
		F_FAIL=false
	else
		unexpected_action "Action after death"
	fi
}

check_missed_death() { 
	if [[ $F_DEBUG == true ]]; then
		echo "🐞DEBUG: check_missed_death()"
		echo "		T_PROGRAM_END=$T_PROGRAM_END T_DEATH=$T_DEATH"; fi

	local t_die="$1"
    for ((philo=1; philo<=number_of_philos; philo++)); do
        if (( arr_lastmeal["$philo"] + t_die < T_DEATH && arr_lastmeal["$philo"] + t_die > T_DEATH + T_DELAY_TOLERANCE_DEATH )); then
			if [[ $F_DEBUG == true ]]; then
				echo "		philo $philo last meal:${arr_lastmeal["$philo"]}"; fi
            TEST_MSG="Philo $philo must die at $(( ${arr_lastmeal["$philo"]} + $t_die )) T_DEATH=$T_DEATH"
            F_FAIL=true
            break
        fi
		 [[ $F_DEBUG == true ]] && echo "		philo $philo last meal:${arr_lastmeal["$philo"]}"
    done
}

