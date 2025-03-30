#!/bin/bash

unexpected_action() {
	if [[ $F_DEBUG == true ]]; then
		echo "⚠️  SET F_PHILO_LOG_END=true F_FAIL=true, unexpected_action()"; fi

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
		echo "➡️  MOVED to [$time] [$philo] [$action] move_to_next_action()"; fi
}

set_programm_end() {
	time="$1"
	if [[ $time -gt $T_PROGRAM_END ]]; then
		if [[ $F_DEBUG == true ]]; then
			echo "⚠️  SET T_PROGRAM_END=$time"; fi
		T_PROGRAM_END=$time; fi
}

validate() {
	number_of_philos="$1"; t_die="$2"; t_eat="$3"; t_sleep="$4"; meals_to_eat="$5";
	# Reset globals for new test
	T_PROGRAM_END=-1; T_DEATH=-1; F_ANY_DEATH=false

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

		if [[ $F_DEBUG == true ]]; then
			while [[ i -lt ${#logs[@]} ]]; do
				echo "	LOGS: $philo: ${logs[i]}"
				((i++))
			done; fi

		F_PHILO_LOG_END=false;
		meals_eaten=0; i=0;
		if [[ $number_of_philos -eq 1 ]]; then
			validate_fork
			validate_death
		fi

		while (( i < ${#logs[@]} )) ; do
			validate_fork
			validate_fork
			validate_eating
			validate_sleeping
			validate_thinking

			if [[ $F_PHILO_LOG_END == true ]]; then
				arr_lastmeal[$philo]=$T_LAST_MEAL
				break; fi
		done

		validate_meals_eaten
		check_missed_death "$t_die"
	
		if [[ $F_DEBUG == true ]]; then
			echo -e "\n"; fi
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

	if ! [[ $EXEC_MSG =~ [Ee]rror|[Ii]nvalid|[Ww]rong|[Uu]sage|[Tt]oo ]]; then
		TEST_MSG="An error message was expected! "
		F_TIMEOUT=false
		F_FAIL=true
	fi
	
	if [[ $EXEC_MSG =~ ^[0-9]+\ [0-9] ]]; then
		F_FAIL=true
		EXEC_MSG=""
		TEST_MSG+="Program shouldn't run!"
		F_TIMEOUT=false
		return
	fi

	if ((${#EXEC_MSG} > 60)); then
		EXEC_MSG="${EXEC_MSG:0:30}...${EXEC_MSG: -30}"
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
