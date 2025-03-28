#!/bin/bash

source utils/style.sh

unexpected_action() {
	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] validate_last_action()"; fi

	err=$1
	F_PHILO_LOG_END=true
	F_FAIL=true
	TEST_MSG="$err [$philo]: $action at $time"
}

move_to_next_action() {
	set_programm_end "$time"
	((i++))
	if (( i >= ${#logs[@]} )); then 
		F_PHILO_LOG_END=true
		return; fi

	time="${logs[i]%% *}"
	action="${logs[i]#* }"

	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] move_to_next_action()"; fi
}

check_missed_death() { 
	if [[ $F_DEBUG == true ]]; then
		echo "		🐞DEBUG: Philo $philo: [$time] [$action] die: $t_die end: $T_PROGRAM_END check_missed_death()"; fi

	local t_die="$1"
    for ((philo=1; philo<=number_of_philos; philo++)); do
        if [[ $(( ${arr_lastmeal["$philo"]} + $t_die )) -lt $T_PROGRAM_END ]]; then
            TEST_MSG="Philo $philo must die at $(( ${arr_lastmeal["$philo"]} + $t_die ))!"
            F_FAIL=true
            break
        fi
    done
}

set_programm_end() {
	time="$1"
	if [[ $time -gt $T_PROGRAM_END ]]; then
		T_PROGRAM_END=$time; fi
}

validate() {
	number_of_philos="$1"; t_die="$2"; t_eat="$3"; t_sleep="$4"; meals_to_eat="$5";

	# Declare array of all last meals for each philo
	declare -gA arr_lastmeal
	for ((i=1; i<=number_of_philos; i++)); do
		arr_lastmeal["$i"]=0; done

	if [[ $F_DEBUG == true ]]; then 
		echo -e "\n🐞DEBUG VALIDATION, F_FAIL $F_FAIL"; fi

	for ((philo=1; philo<=number_of_philos; philo++)); do
		[[ $F_FAIL == true ]] && break
		i=0; logs=()
		IFS=$'\n' read -rd '' -a logs <<< "${table[$philo]}"  # Read into array logs, split by newline
		time="${logs[i]%% *}"
		action="${logs[i]#* }"
		set_programm_end "$time"

		if [[ $F_DEBUG == true ]]; then
			while [[ i -lt ${#logs[@]} ]]; do
				echo "	🐞DEBUG: LOGS: $philo: ${logs[i]}"
				((i++))
			done; fi

		t_sleep_end=0; meals_eaten=0
		F_PHILO_LOG_END=false; i=0;
		while (( i < ${#logs[@]} )) ; do

			if is_death_time "$time" ; then
				validate_death
				break; fi
			validate_fork # Has taken forks
			validate_fork # Has taken forks
			validate_eating # Is eating
			validate_sleeping # Is sleeping
			validate_thinking # Is thinking

			if [[ $F_PHILO_LOG_END == true ]]; then
				arr_lastmeal[$philo]=$T_LAST_MEAL
				break; fi
		done

		if [[ $F_DEBUG == true ]]; then
			echo -e "\n"; fi

		check_missed_death "$t_die"
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
		EXEC_MSG=""; return 1; fi

	if ! [[ $EXEC_MSG =~ [Ee]rror|[Ii]nvalid|[Ww]rong|[Uu]sage ]]; then
		TEST_MSG="Your programm should print an error message when input is invalid!"
		F_FAIL=true; fi
	
	if [[ $EXEC_MSG =~ ^[0-9]+\ [0-9] ]]; then
		F_FAIL=true; EXEC_MSG=""; TEST_MSG="Your programm shouldn't run when input is invalid!"

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
		print_result; return; fi
	# Get program output
	parse_output "$log_file" "$number_of_philos"
	# Handle output
	validate "$number_of_philos" "$t_die" "$t_eat" "$t_sleep" "$meals_to_eat"
	# Print result
	print_result
	return
}
