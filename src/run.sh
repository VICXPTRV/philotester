#!bin/bash

exec_program() {

	test_case="$1"
	test_number="$2"
	test_name="$3"

	log_file="${test_name}_${test_number}.log"
	LEAK_RES=""

	# !RUN PROGRAMM!
	if $F_VALGRIND; then
		output=$(timeout $T_LIMIT $VALGRIND $EXEC $test_case 2>&1)
		status=$?
		if [[ $status -eq 124 ]]; then
			F_TIMEOUT=true; fi
		if grep -q "definitely lost:" "$VALG_LOG"; then
			LEAK_RES=$LEAK; fi
	else
		output=$(timeout $T_LIMIT $EXEC $test_case 2>&1); fi
		status=$?
		if [[ $status -eq 124 ]]; then
			F_TIMEOUT=true; fi

	validate_test "$output" "$log_file" "$test_case"

	unset table
	((TOTAL++))
}

run_tests() {
    case="$1"
    test_file="${CASES_PATH}/${case}"
    test_number=1

	# Run each test in current case file
    while IFS= read -r test_case || [[ -n "$test_case" ]]; do
        [[ -z "$test_case" ]] && continue

		exec_program "$test_case" "$test_number" "${LOGS_PATH}/${case}"
		((test_number++))

    done < "$test_file"
}

# RUN
run_cases() {

	# Manual test mode
	if [[ $F_MANUAL == true ]]; then
		prompt=""
		terminate="^(q|quit)$"
		test_number=1
		echo -e "${MANUAL_TEST_EMOJI}${MANUAL_TEST_COLOR} Enter manual test mode ${ADD_COLOR}(quit or q to finish)\n${RESET}"
		while ! [[ $prompt =~ $terminate ]]; do
			read -p "> " prompt
			if [[ $prompt =~ $terminate ]]; then
				echo -e "${MANUAL_TEST_COLOR}...Exiting manual test mode${RESET}\n"
				return; fi
	
			exec_program "$prompt" "$test_number" "${LOGS_PATH}/manual" 
			((test_number++))
		done
		return
	fi

	# loop through case files
	for case in ${cases[@]}; do
		echo -e "${HEADER_EMOJI}${HEADER_COLOR} Testing: ${case}${RESET}"
		if [[ ! -f "${CASES_PATH}/$case" ]]; then
			echo -e "${KO_COLOR}$ Test file not found: ${case}${RESET}"
			return
		fi
		run_tests "${case}"
		echo -e "\n"
	done
}
