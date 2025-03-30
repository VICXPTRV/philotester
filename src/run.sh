#!bin/bash

exec_program() {

	test_case="$1"
	test_number="$2"
	test_name="$3"
	F_CRUSH=false

	[[ $F_DEBUG == true ]] && echo "🐞 EXEC TEST CASE: $test_case"

	log_file="${test_name}_${test_number}.log"
	file_name=$(basename "$log_file")
	VALG_LOG="${VALG_PATH}/memcheck/${file_name}"
	HELG_LOG="${VALG_PATH}/helgrind/${file_name}"
	LEAK_RES=""
	F_TIMEOUT=false

	# !RUN PROGRAMM WITH VALGRIND!
	if $F_VALGRIND; then
		# VALG
		output=$(stdbuf -oL timeout $T_LIMIT $VALGRIND --log-file=${VALG_LOG} $EXEC $test_case 2>&1 | tr -d '\0')
		status=$?
		if [[ $status -eq 124 ]]; then
			F_TIMEOUT=true; fi
		grep -q "definitely lost:" "$VALG_LOG" && LEAK_RES=$LEAK
		# HELG
		timeout $T_LIMIT $HELGRIND --log-file=${HELG_LOG} $EXEC $test_case 2>/dev/null
		grep -q "data race:" "$HELG_LOG" && LEAK_RES+="$RACE"

	# !RUN PROGRAMM WITHOUT VALGRIND!
	else
		output=$(stdbuf -oL timeout $T_LIMIT $EXEC $test_case 2>&1 | tr -d '\0')
		status=$?
		if [[ $status -eq 124 ]]; then
			F_TIMEOUT=true; fi
	fi
	[[ $F_DEBUG == true ]] && echo "	Output: $output"
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

	[[ $F_DEBUG == true ]] && echo "🐞 RUN"

	# Manual test mode
	if [[ $F_MANUAL == true ]]; then
		[[ $F_DEBUG == true ]] && echo "RUN MANUAL"
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

	[[ $F_DEBUG == true ]] && echo "RUN AUTO"
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
