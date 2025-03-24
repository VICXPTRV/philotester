#!/bin/bash

source utils/style.sh

is_invalid_action_sequence() {
    local expected_order=("fork" "fork" "eat" "sleep" "think")
    if [[ "$action" =~ fork|eat|sleep|think ]]; then
        if [[ "$action" != "${expected_order[action_idx]}" ]]; then
            TEST_MSG="Philo $philo: Invalid action order at $time"
            FAIL_FLAG=true
            return 1
        else
            action_idx=$(( (action_idx + 1) % 5 ))
            return 0
        fi
    fi
    return 0
}

is_invalid_action_dur() {
    if [[ "$action" == "eat" ]]; then
        if [[ "$last_eat_time" -ne 0 && "$((time - last_eat_time))" -ne "$t_eat" ]]; then
            TEST_MSG="Philo $philo: Incorrect t_eat duration at $time"
            FAIL_FLAG=true
            return 1
        fi
        last_eat_time="$time"
        ((eat_count++))
    elif [[ "$action" == "sleep" ]]; then
        if [[ "$last_sleep_time" -ne 0 && "$((time - last_sleep_time))" -ne "$t_sleep" ]]; then
            TEST_MSG="Philo $philo: Incorrect t_sleep duration at $time"
            FAIL_FLAG=true
            return 1
        fi
        last_sleep_time="$time"
    fi
    return 0
}

is_invalid_death() {

	if ! [[ "$action" =~ died ]]; then
		return 0; fi

	# if [[ $TEST_MSG =~ [Tt]imeout ]]


    if [[ "$((time - last_eat_time))" -lt "$t_die" ]]; then
        TEST_MSG="Philo $philo: Unexpected death at $time"
        FAIL_FLAG=true
        return 1
    fi
    if [[ "$action" == "died" && "$time" -ne "$((last_eat_time + t_die))" ]]; then
        TEST_MSG="Philo $philo: Incorrect time of death at $time"
        FAIL_FLAG=true
        return 1
    fi
    return 0
}

is_invalid_meals_eaten() {
    if [[ -n "$meals_to_eat" && "$eat_count" -ge "$meals_to_eat" ]]; then
        TEST_MSG="Philo $philo: Ate more than $meals_to_eat times"
        FAIL_FLAG=true
        return 1
    fi
    return 0
}

validate_output() {
    number_of_philos="$1"
    t_die="$2"
    t_eat="$3"
    t_sleep="$4"
    meals_to_eat="$5"

    for ((philo=1; philo<=number_of_philos; philo++)); do
        logs=(${table[$philo-1]//$'\n'/ })
        eat_count=0
        last_eat_time=0
        last_sleep_time=0
        action_idx=0

        for ((i=0; i<${#logs[@]}; i+=2)); do
            time="${logs[i]}"
            action="${logs[i+1]}"

			# if action == "died" && next action exists

            if is_invalid_death || is_invalid_action_sequence || 
               is_invalid_action_dur || is_invalid_meals_eaten; then
                print_result
                return
            fi
        done
        print_result
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
		is_int_not_overflow "$number_of_philos" "$t_die" "$t_eat" "$t_sleep" "$meals_to_eat" && \
		is_int_positive "$number_of_philos" "$t_die" "$t_eat" "$t_sleep" "$meals_to_eat" && \
		is_int_valid "$number_of_philos" "$t_die" "$t_eat" "$t_sleep" "$meals_to_eat"
	then
		EXEC_MSG=""
		return 1
	fi

	if ! [[ $EXEC_MSG =~ [Ee]rror|[Ii]nvalid|[Ww]rong|[Uu]sage ]]; then
		TEST_MSG="Your programm should print an error message when input is invalid!"
		FAIL_FLAG=true
	fi
	
	if [[ $EXEC_MSG =~ ^[0-9]+\ [0-9] ]]; then
		FAIL_FLAG=true
		EXEC_MSG=""
		TEST_MSG="Your programm shouldn't run when input is invalid!"

		if [[ -n $meals_to_eat && $meals_to_eat -eq 0 && 
		! ($number_of_philos -ne 0 || $t_die -ne 0 || $t_eat -ne 0 || $t_sleep -ne 0) ]]; then
			FAIL_FLAG=false; fi
	fi
	return 0
}
