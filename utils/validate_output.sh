#!/bin/bash

source utils/style.sh

FLAG_END=false
DEATH_TIME=-1

validate_death() {
	if [[ $DEATH_TIME -gt 0 && $time -gt $DEATH_TIME ]]; then
		TEST_MSG="Programm continue after first death"
		FLAG_FAIL=true

	elif [[ $time -gt $((t_eat_end + t_die - 10)) ]]; then
		TEST_MSG="Philo $philo died too late"
		FLAG_FAIL=true
	fi

	FLAG_END=true
}


is_alive() {
	t_eat_end="$1"
	t_die="$2"

	if [[ $time -gt $((t_eat_end + t_die)) ]]; then
		return 1
	fi

	DEATH_TIME=$time

	return 0
}

validate_last_action() {
	if [[ $flag_debug == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] last_action()"
	fi
	if [[ $action =~ die ]]; then
		validate_death
	else
		if [[ $action =~ eat ]]; then
			TEST_MSG="Unexpected eating"
		elif [[ $action =~ sleep ]]; then
			TEST_MSG="Unexpected sleeping"
		elif [[ $action =~ think ]]; then
			TEST_MSG="Unexpected thinking"
		else
			TEST_MSG="Unexpected action"
		fi
		FLAG_FAIL=true
		FLAG_END=true
	fi
}

move_to_next_action() {
	((i++))
	if (( i >= ${#logs[@]} )); then return; fi
	time="${logs[i]%% *}" # before space
	action="${logs[i]#* }" # after the space
	if [[ $flag_debug == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] move_to_next_action()"; fi

}

validate_fork() {

	if [[ $FLAG_END == true ]]; then
		return
	fi

	if [[ $flag_debug == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_fork()"
	fi

	if [[ $action =~ fork ]] && is_alive "$t_eat_end" "$t_die" ; then
		move_to_next_action
	else
		validate_last_action
	fi
}

validate_eating() {

	if [[ $FLAG_END == true ]]; then
		return
	fi

	if [[ $flag_debug == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_eating()"
	fi

	if [[ $action =~ eat ]] && is_alive "$t_eat_end" "$t_die" ; then
		t_eat_start=$time
		((meals_eaten++))
		t_eat_end=$(($t_eat_start + $t_eat))		
		move_to_next_action
	else
		validate_last_action
	fi

}

validate_sleeping() {

	if [[ $FLAG_END == true ]]; then
		return
	fi

	if [[ $flag_debug == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_sleeping()"
	fi

	if [[ $action =~ sleep ]] && is_alive "$t_eat_end" "$t_die" ; then
		t_sleep_start=$time
		if [[ $t_sleep_start -ne t_eat_end ]]; then
			TEST_MSG="Philo $philo eating duration is wrong"
			FLAG_FAIL=true
			FLAG_END=true
			return
		fi
		move_to_next_action
	else
		validate_last_action
	fi
}

validate_thinking() {

	if [[ $FLAG_END == true ]]; then
		return
	fi

	if [[ $flag_debug == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_thinking()"
	fi
	if [[ $action =~ think ]] && is_alive "$t_eat_end" "$t_die" ; then
	t_sleep_end=$time
		if [[ $t_sleep -ne $((t_sleep_end - t_sleep_start)) ]]; then
			TEST_MSG="Philo $philo: Time to sleep is wrong"
			FLAG_FAIL=true
			FLAG_END=true
			return
		fi
		move_to_next_action
	else
		validate_last_action
	fi
}

validate_meals_eaten() {

	if [[ -z $meals_to_eat ]]; then
		return
	fi
	if [[ $meals_eaten -eq $meals_to_eat ]]; then
		TEST_MSG="Philo $philo: Shouldn't eat more than $meals_to_eat times"
		FLAG_FAIL=true
		FLAG_END=true
	fi
}

validate_output_one_philo() {

	logs=(${table[0]//$'\n'/ })

	i=0
	time="${logs[i]}"
	action="${logs[i+1]}"

	while (( i<${#logs[@]} )); do

		# Has taken a fork
		validate_fork
		# Died
		if [[ $action =~ die ]]; then
			validate_death
		else
			TEST_MSG="Philo 1: Didn't die"
			FLAG_FAIL=true
			break
		fi
	done	
	FLAG_END=true
}

validate_output() {
    number_of_philos="$1"
    t_die="$2"
    t_eat="$3"
    t_sleep="$4"
    meals_to_eat="$5"

	if [[ $number_of_philos -eq 1 ]]; then
		validate_output_one_philo
		return
	fi
	
    for ((philo=1; philo<=number_of_philos; philo++)); do

		i=0
		logs=()
		FLAG_END=false

		IFS=$'\n' read -rd '' -a logs <<< "${table[$philo]}"  # Read into array logs, split by newline

		time="${logs[i]%% *}" # before space
		action="${logs[i]#* }" # after the space

		if [[ $flag_debug == true ]]; then
			while [[ i -lt ${#logs[@]} ]]; do
				echo "	🐞DEBUG: LOGS: $philo: ${logs[i]}"
				((i++))
			done
		fi

		t_eat_end=$time
		t_eat_start=0
		t_sleep_start=0
		t_sleep_end=0
		meals_eaten=0

		while [[ i -lt ${#logs[@]} && "$FLAG_END" == "false" ]]; do

			# Has taken forks
			validate_fork
			validate_fork
			# Is eating
			validate_eating
			# Is sleeping
			validate_sleeping
			# Is thinking
			validate_thinking
        done

		if [[ $flag_debug == true ]]; then
			echo -e "\n"; fi

		validate_meals_eaten

    done
}

is_invalid_input() {
	number_of_philos="$1"
	t_die="$2"
	t_eat="$3"
	t_sleep="$4"
	meals_to_eat="$5"
	extra_arg="$6"

	EXEC_MSG=$(<"$log_file")

	if [[ -z "$extra_arg" ]] && \
		( [[ -z "$meals_to_eat" ]] || 
			( is_int_not_overflow "$meals_to_eat" && is_int_positive "$meals_to_eat" && is_int_valid "$meals_to_eat" ) 
		) && \
		is_int_not_overflow "$number_of_philos" "$t_die" "$t_eat" "$t_sleep" && \
		is_int_positive "$number_of_philos" "$t_die" "$t_eat" "$t_sleep" && \
		is_int_valid "$number_of_philos" "$t_die" "$t_eat" "$t_sleep"
	then
		EXEC_MSG=""
		return 1
	fi

	if ! [[ $EXEC_MSG =~ [Ee]rror|[Ii]nvalid|[Ww]rong|[Uu]sage ]]; then
		TEST_MSG="Your programm should print an error message when input is invalid!"
		FLAG_FAIL=true
	fi
	
	if [[ $EXEC_MSG =~ ^[0-9]+\ [0-9] ]]; then
		FLAG_FAIL=true
		EXEC_MSG=""
		TEST_MSG="Your programm shouldn't run when input is invalid!"

		if [[ -n $meals_to_eat && $meals_to_eat -eq 0 && 
		! ($number_of_philos -ne 0 || $t_die -ne 0 || $t_eat -ne 0 || $t_sleep -ne 0) ]]; then
			FLAG_FAIL=false; fi
	fi
	return 0
}
