#!/bin/bash

print_tester_info() {
    echo -e "${INFO_EMOJI} ${INFO_COLOR}This tester helps catch regressions during development. Do not rely on results for final validation.${RESET}"
    echo -e "    ${INFO_COLOR}More info: ${UNDERLINE}https://github.com/VICXPTRV/philotester${RESET}"
    echo -e "    ${INFO_COLOR}Use -H for help.${RESET}"
    echo
}

# HEADER
print_header() {

	HEADER_TEXT="${HEADER_EMOJI} ${HEADER_NAME} ${HEADER_EMOJI}"
	SEPARATOR=$(printf "%-${LINE_LENGTH}s" "" | tr " " "-")
	HEADER_TEXT_LENGTH=${#HEADER_TEXT}
	PADDING=$(( (LINE_LENGTH - HEADER_TEXT_LENGTH) / 2 ))
	echo -e "\n${HEADER_COLOR}${BOLD}${SEPARATOR}${RESET}\n"
	printf "${HEADER_COLOR}${BOLD}%*s%s%*s${RESET}\n" $PADDING "" "$HEADER_TEXT" $PADDING ""
	echo -e "${HEADER_COLOR}${BOLD}${SEPARATOR}${RESET}\n"

	print_tester_info
}

# MODE

print_mode() {
	echo -e "${MANUAL_TEST_COLOR}${MODE_MESSAGE}\n${RESET}"
}


# RESULT
print_result(){

	TEST_EMOJI=""
	color=$OK_COLOR
	death_warning=""

	if [[ $F_DEBUG == true ]]; then
		echo "	🐞DEBUG: $TEST_MSG, $EXEC_MSG, $F_FAIL"
	fi

	if [[ $F_TIMEOUT == true || $F_ANY_DEATH=true ]]; then
		if $F_TIMEOUT; then
			death_warning="Results can be affected by timeout!"; fi
		
		if [[ $F_ANY_DEATH == true && $F_NO_RUN == false ]]; then
			death_warning+="${ADD_COLOR} *someone has died at [$first_death] ${RESET}"
		elif [[ $F_ANY_DEATH == false && $F_NO_RUN == false ]]; then
			death_warning+="${ADD_COLOR} *no deaths occurred${RESET}"
		fi
	fi
	if [[ $F_FAIL == true ]]; then
		color=$KO_COLOR
		((FAILED++)); fi
	if [[ -n "$TEST_MSG" ]]; then
		TEST_EMOJI="$WARNING"; fi

	if [[ $F_CRUSH == true ]]; then
		TEST_EMOJI="$CRUSH_EMOJI"; fi

	echo -e "${color}[$test_number]${TEST_EMOJI}${CHECK_RES}./philo ${test_case}${ADD_COLOR} ${EXEC_MSG}${RESET}${WARNING_COLOR} $death_warning ${RESET}"

	if [[ -n "$TEST_MSG" ]]; then
		echo -e "${WARNING_COLOR}   $TEST_MSG${RESET}";fi

	EXEC_MSG=""
	TEST_MSG=""
	F_FAIL=false
}

# FOOTER
print_footer() {

	PASSED=$((TOTAL - FAILED))
	if [[ "$PASSED" -eq "$TOTAL" ]] ; then
		RES_EMOJI=$SUCCESS
		RES_COLOR=$OK_COLOR
	else
		RES_EMOJI=$FAILURE
		RES_COLOR=$KO_COLOR
	fi
	RESULT="${RES_EMOJI}  ${PASSED}/$TOTAL ${RES_EMOJI}"
	RESULT_LENGTH=${#RESULT}
	PADDING=$(( (LINE_LENGTH - RESULT_LENGTH) / 2 ))
	echo -e "${RES_COLOR}${BOLD}${SEPARATOR}${RESET}\n"
	printf "${RES_COLOR}${BOLD}%*s%s%*s${RESET}\n" $PADDING "" "$RESULT" $PADDING ""
	echo -e "${RES_COLOR}${BOLD}${SEPARATOR}${RESET}\n"
}
