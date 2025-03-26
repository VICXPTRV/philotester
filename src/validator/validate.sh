#!/bin/bash

source utils/style.sh

validate_last_action() {
	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] last_action()"; fi
	
	if [[ $action =~ die ]]; then
		validate_death
	elif is_later_than_death "$time"; then
			TEST_MSG="Unexpected $action by $philo at $time while death was at $T_DEATH_TIME"
	fi
	F_PHILO_LOG_END=true
}


move_to_next_action() {
	((i++))
	if (( i >= ${#logs[@]} )); then 
		F_PHILO_LOG_END=true
		return; fi

	time="${logs[i]%% *}" # before space
	action="${logs[i]#* }" # after the space

	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] move_to_next_action()"; fi

}

validate() {
    number_of_philos="$1"
    t_die="$2"
    t_eat="$3"
    t_sleep="$4"
    meals_to_eat="$5"

	if [[ $F_DEBUG == true ]]; then
			echo -e "\n🐞DEBUG VALIDATION, F_FAIL $F_FAIL"; fi
	
    for ((philo=1; philo<=number_of_philos; philo++)); do

		if [[ $F_FAIL == true ]]; then
			break
		fi

		i=0
		logs=()

		IFS=$'\n' read -rd '' -a logs <<< "${table[$philo]}"  # Read into array logs, split by newline

		time="${logs[i]%% *}" # before space
		action="${logs[i]#* }" # after the space

		if [[ $F_DEBUG == true ]]; then
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
		F_PHILO_LOG_END=false
		i=0
		while (( i < ${#logs[@]} )) && [[ "$F_PHILO_LOG_END" == false ]]; do
			validate_fork # Has taken forks
			validate_fork # Has taken forks
			validate_eating # Is eating
			validate_sleeping # Is sleeping
			validate_thinking # Is thinking
        done

		if [[ $F_DEBUG == true ]]; then
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
		F_FAIL=true
	fi
	
	if [[ $EXEC_MSG =~ ^[0-9]+\ [0-9] ]]; then
		F_FAIL=true
		EXEC_MSG=""
		TEST_MSG="Your programm shouldn't run when input is invalid!"

		if [[ -n $meals_to_eat && $meals_to_eat -eq 0 && 
		! ($number_of_philos -ne 0 || $t_die -ne 0 || $t_eat -ne 0 || $t_sleep -ne 0) ]]; then
			F_FAIL=false; fi
	fi
	return 0
}

validate_test() {
	output="$1"
	log_file="$2"
	test_case="$3"

	# Log the output
	echo -e "${output}" > "$log_file"

	# Get program input
	parse_input "$test_case"

	# Check if case of invalid input and stop further processing
	if is_invalid_input "$number_of_philos" "$t_die" "$t_eat" "$t_sleep" "$meals_to_eat" "$extra_arg"; then
		print_result
		return
	fi

	# Get program output
	parse_output "$log_file" "$number_of_philos"

	# Handle output
	validate "$number_of_philos" "$t_die" "$t_eat" "$t_sleep" "$meals_to_eat"

	# Print result
	print_result
	return
}
