#!bin/bash

run_bare_program()
{
	output=$(stdbuf -oL timeout $T_LIMIT $EXEC $test_case 2>&1 | tr -d '\0')
	status=$?
	if [[ $status -eq 124 ]]; then
		F_TIMEOUT=true
	fi

}

run_valgrind_memchek() {

	MEMC_LOG="${MEMC_PATH}/${file_name}"
	output=$(stdbuf -oL timeout --preserve-status $T_LIMIT $MEMCHECK --log-file=${MEMC_LOG} $EXEC $test_case 2>&1 | tr -d '\0')
	status=$?
	if [[ $status -eq 124 ]]; then
		F_TIMEOUT=true; fi
	if grep -q "definitely lost:" "$MEMC_LOG"; then
		if grep -q "SIGTERM" "$MEMC_LOG"; then
			CHECK_RES=""; F_FAIL=false; TEST_MSG="Leaks caused by timeout"
		else
			CHECK_RES=$LEAK_EMOJI; F_FAIL=true
		fi
	fi
}

run_valgrind_helgrind() {

	HELG_LOG="${HELG_PATH}/${file_name}"
	output=$(stdbuf -oL timeout --preserve-status $T_LIMIT $HELGRIND --log-file=${HELG_LOG} $EXEC $test_case 2>&1 | tr -d '\0')
	status=$?
	if [[ $status -eq 124 ]]; then
		F_TIMEOUT=true; fi

	if grep -q "data race" "$HELG_LOG" || grep -q "locks" "$HELG_LOG" ; then
		if grep -q "SIGTERM" "$HELG_LOG"; then
			CHECK_RES=""; F_FAIL=false; TEST_MSG="Problem caused by timeout"
		else
			CHECK_RES=$RACE_EMOJI; F_FAIL=true
		fi
	fi
}

run_thread_sanitizer() {

	TSAN_LOG="${TSAN_PATH}/${file_name}"

	export TSAN_OPTIONS="${TSAN_OPT}" 
	(stdbuf -oL timeout --preserve-status $T_LIMIT $EXEC $test_case 2>&1 | tr -d '\0') > $TSAN_LOG
	status=$?
	if [[ $status -eq 124 ]]; then
		F_TIMEOUT=true; fi
	TSAN_LOG_TRIMMED=$(ls -1 "$TSAN_LOG"* 2>/dev/null | head -n 1)
	if grep -q "data race" "$TSAN_LOG_TRIMMED" || grep -q "warnings" "$TSAN_LOG_TRIMMED"; then
		CHECK_RES="$RACE_EMOJI"
		F_FAIL=true
	fi
}

exec_program() {

	test_case="$1"
	test_number="$2"
	test_name="$3"
	F_CRUSH=false
	F_TIMEOUT=false
	CHECK_RES=""

	[[ $F_DEBUG == true ]] && echo "🐞 EXEC TEST CASE: $test_case"

	log_file="${test_name}_${test_number}.log"
	file_name=$(basename "$log_file")

	# !RUN PROGRAMM
	if $F_MEMCHECK; then
		run_valgrind_memchek
	elif $F_HELGRIND; then
		run_valgrind_helgrind
	elif $F_TSAN; then
		run_thread_sanitizer
	else
		run_bare_program
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
