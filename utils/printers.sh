#!/bin/bash

source utils/style.sh

# HEADER
print_header() {
	HEADER_TEXT="${HEADER_EMOJI} ${HEADER_NAME} ${HEADER_EMOJI}"
	SEPARATOR=$(printf "%-${LINE_LENGTH}s" "" | tr " " "-")
	HEADER_TEXT_LENGTH=${#HEADER_TEXT}
	PADDING=$(( (LINE_LENGTH - HEADER_TEXT_LENGTH) / 2 ))
	echo -e "\n${HEADER_COLOR}${BOLD}${SEPARATOR}${RESET}\n"
	printf "${HEADER_COLOR}${BOLD}%*s%s%*s${RESET}\n" $PADDING "" "$HEADER_TEXT" $PADDING ""
	echo -e "${HEADER_COLOR}${BOLD}${SEPARATOR}${RESET}\n"
}

# RESULT
print_result(){

	TEST_EMOJI=""
	color=$OK_COLOR

	if [[ $FAIL_FLAG == true ]]; then
		color=$KO_COLOR
		((FAILED++)); fi
	if [[ -n "$TEST_MSG" ]]; then
		TEST_EMOJI="$WARNING"; fi

	echo -e "${color}[$test_number]${TEST_EMOJI}${LEAK_RES}./philo ${test_case}${ADD_COLOR} ${EXEC_MSG}${RESET}"

	if [[ -n "$TEST_MSG" ]]; then
		echo -e "${WARNING_COLOR}    $TEST_MSG${RESET}"
	fi

	EXEC_MSG=""
	TEST_MSG=""
	FAIL_FLAG=false
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
