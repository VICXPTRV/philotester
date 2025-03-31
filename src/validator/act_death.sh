#!/bin/bash

is_death_time() {
	t_current="$1"

	if [[ $F_DEBUG == true ]]; then
		echo "	⌛ is_death_time() [$philo]: t_currnt=$t_current T_LAST_MEAL=$T_LAST_MEAL"; fi

	if (( t_current - T_LAST_MEAL >= t_die && t_current - T_LAST_MEAL <= t_die + T_DELAY_TOLERANCE_DEATH )); then
		return 0
	fi
	return 1
}

validate_death() {
	if [[ $F_DEBUG == true ]]; then
		echo -e "🐞DEBUG: DEATH [$time] [$philo] [$action] validate_death()"; fi

	if [[ $action =~ die ]]; then
		F_ANY_DEATH=true
		arr_death[$philo]=$time
	fi

	if [[ $T_DEATH -eq -1 ]]; then
		T_DEATH=$time
		[[ $F_DEBUG == true ]] && echo "	⚠️  SET T_DEATH=$time"
		set_programm_end "$T_DEATH"
	fi

	# unexpected death
	if ! is_death_time "$time" && [[ $action =~ die ]]; then
		unexpected_action "Philo died when shouldn't"
		return;
	# time to die but no death
	elif is_death_time "$time" && ! [[ $action =~ die ]]; then
		unexpected_action "Time to die but [$philo] [$time] [$action] detected"
		return;
	# death at right time
	elif move_to_next_action; then
		unexpected_action "Action after death: [$philo] [$time] [$action]"
	fi
}

check_missed_death() { 
	if [[ $F_DEBUG == true ]]; then
		echo "🐞DEBUG: check_missed_death()"
	fi

    for ((philo=1; philo<=number_of_philos; philo++)); do
		[[ $F_DEBUG == true ]] && echo "	[$philo] meal [${arr_lastmeal["$philo"]}] t_die=$t_die, died [${arr_death["$philo"]}] T_PROGRAM_END=$T_PROGRAM_END T_DEATH=$T_DEATH"
        if (( arr_lastmeal["$philo"] + t_die < $T_PROGRAM_END && arr_death["$philo"] == -1 )); then
			expected_death=$(( arr_lastmeal["$philo"] + t_die ))
            TEST_MSG="Philo $philo must die at $expected_death"
            F_FAIL=true
            break
        fi
    done
}

validate_death_number()
{
	first_death="$T_DEATH"
	death_count=0
	for ((philo=1; philo<=number_of_philos; philo++)); do
		if [[ arr_death["$philo"] -ne -1 ]]; then
			((death_count+=1))
			if [[ ${arr_death["$philo"]} < "$first_death" ]]; then 
				first_death="${arr_death["$philo"]}"; fi
		fi
	done
	if [[ $death_count -gt 1 ]]; then
		F_FAIL=true
		TEST_MSG="More than one death detected"  
	fi

	[[ $F_DEBUG == true ]] && echo "🐞DEBUG: validate_death_number()" && echo "	Deaths=$death_count T_PROGRAM_END=$T_PROGRAM_END T_DEATH=$T_DEATH"

}

