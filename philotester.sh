#!/bin/bash

# PATH
EXEC_PATH="../../thread_mutex"				#<------ YOUR PATH
EXEC="${EXEC_PATH}/philo"
CASES_PATH="cases/"
if [[ ! -d "logs" ]]; then
	mkdir logs
else
	rm logs/*
fi
LOGS_PATH="logs"

# VALGRIND
if [[ ! -f "${LOGS_PATH}/valgrind.log" ]] ; then
	touch ${LOGS_PATH}/valgrind.log; fi
if [[ ! -f "valgrind.supp" ]] ; then
	touch "valgrind.supp"; fi
VALG_LOG=${LOGS_PATH}/valgrind.log
VALG_SUP="valgrind.supp"
VALGRIND="valgrind -q \
--show-leak-kinds=all --error-limit=no \
--suppressions=$VALG_SUP \
--log-file=$VALG_LOG"          				#<------ YOUR VALGRIND FLAGS

# FLAGS
flag_valgrind=false
while getopts "v" flag; do
	case $flag in
		v) flag_valgrind=true ;;
	esac
done

# CASES
TOTAL=0
FAILED=0
if [[ $# -gt 0 ]]; then
	cases=("$@")
else
	cases=($(ls $CASES_PATH)); fi

# COLORS
BOLD="\e[1m"
RESET="\033[0m"
BLACK="\033[38;5;0m"
GREY="\033[38;5;250m"
DARK_BLUE="\033[38;5;25m"
LIGHT_BLUE="\033[38;5;39m"
PINK="\033[38;5;213m"
RED="\033[38;5;196m"
ORANGE="\033[38;5;208m"
YELLOW="\033[38;5;220m"
GREEN="\033[38;5;40m"
WHITE="\033[38;5;15m"
PURPLE="\033[38;5;129m"

# HEADER
print_header() {
	HEADER_NAME="DINING PHILOSOPHERS TESTER"
	HEADER_COLOR=$LIGHT_BLUE
	HEADER_EMOJI="🥢"
	HEADER_SEP="-"
	LINE_LENGTH=$(tput cols)
	HEADER_TEXT="${HEADER_EMOJI} ${HEADER_NAME} ${HEADER_EMOJI}"
	SEPARATOR=$(printf "%-${LINE_LENGTH}s" "" | tr " " "-")
	HEADER_TEXT_LENGTH=${#HEADER_TEXT}
	PADDING=$(( (LINE_LENGTH - HEADER_TEXT_LENGTH) / 2 ))
	echo -e "\n${HEADER_COLOR}${BOLD}${SEPARATOR}${RESET}\n"
	printf "${HEADER_COLOR}${BOLD}%*s%s%*s${RESET}\n" $PADDING "" "$HEADER_TEXT" $PADDING ""
	echo -e "${HEADER_COLOR}${BOLD}${SEPARATOR}${RESET}\n"
}

# NORM (optional)
check_norm() {
	echo -e "${HEADER_EMOJI}${HEADER_COLOR} Testing: build and norm${RESET}"
	make -C "$EXEC_PATH" fclean > /dev/null 2>&1
	norminette $EXEC_PATH > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		echo -e "${GREEN}✅ Norminette ok${RESET}"
	else
		echo -e "${RED}💀 Norminette failed...${RESET}"
	fi
}

# BUILD
build_program() {

	BUILD_FAIL=$(make -C "$EXEC_PATH" re > /dev/null 2>&1)
	if [[ $? -eq 0 ]]; then
		echo -e "${GREEN}✅ Build sucessfully\n${RESET}"
	else
		echo -e "${RED}💀 Build failed..${RESET}"
		echo "$BUILD_FAIL"
		exit 1
	fi
}

run_cases() {
	for case in ${cases[@]}; do
		echo -e "${HEADER_EMOJI}${HEADER_COLOR} Testing: ${case}${RESET}"
		run_tests "${case}"
		echo -e "\n"
	done
}

run_tests() {
    case="$1"
    test_file="${CASES_PATH}/${case}"  # Correct path to the test file
    counter=1  # Counter for log files

    # Check if the test file exists
    if [[ ! -f "$test_file" ]]; then
        echo -e "${RED}💀 Test file not found: ${test_file}${RESET}"
        return
    fi

    while IFS= read -r test_case && IFS= read -r expected_values; do
        [[ -z "$test_case" || -z "$expected_values" ]] && continue

        # Generate log file name with counter
        log_file="${LOGS_PATH}/${case}_${counter}.log"

        # Run the program with the test case
        if $flag_valgrind; then
            output=$($VALGRIND $EXEC $test_case 2>&1)
        else
            output=$($EXEC $test_case 2>&1)
        fi

        # Log the output
        echo "$output" > "$log_file"

        # Extract actual stats from the log output
        actual_deaths=$(grep -c "died" "$log_file")
        actual_meals=$(grep -c "is eating" "$log_file")
        actual_sleeps=$(grep -c "is sleeping" "$log_file")
        actual_thinks=$(grep -c "is thinking" "$log_file")

        # Extract expected stats
        read -r expected_deaths expected_meals expected_sleeps expected_thinks <<< "$expected_values"

        # Compare actual vs expected
        if [[ "$actual_deaths" -le "$expected_deaths" \
              && "$actual_meals" -eq "$expected_meals" \
              && "$actual_sleeps" -eq "$expected_sleeps" \
              && "$actual_thinks" -eq "$expected_thinks" ]]; then
            echo -e "${GREEN}[$counter] ${WHITE}./philo ${test_case}${RESET}"
        else
            echo -e "${RED}[$counter] ./philo ${test_case}${RESET}"
            echo -e "${GREY}  Deaths   : $actual_deaths (actual) vs $expected_deaths (expected)"
            echo "  Meals    : $actual_meals (actual) vs $expected_meals (expected)"
            echo "  Sleeps   : $actual_sleeps (actual) vs $expected_sleeps (expected)"
            echo -e "  Thinks   : $actual_thinks (actual) vs $expected_thinks (expected)${RESET}"
            ((FAILED++))
        fi
        ((TOTAL++))
		((counter++))
    done < "$test_file"
}

print_result() {
	PASSED=$((TOTAL - FAILED))
	if [[ "$PASSED" -eq "$TOTAL" ]] ; then
		RES_EMOJI="🎉"
		RES_COLOR=$GREEN
	else
		RES_EMOJI="☠️"
		RES_COLOR=$RED
	fi
	RESULT="${RES_EMOJI}  ${PASSED}/$TOTAL ${RES_EMOJI}"
	RESULT_LENGTH=${#RESULT}
	PADDING=$(( (LINE_LENGTH - RESULT_LENGTH) / 2 ))
	echo -e "${RES_COLOR}${BOLD}${SEPARATOR}${RESET}\n"
	printf "${RES_COLOR}${BOLD}%*s%s%*s${RESET}\n" $PADDING "" "$RESULT" $PADDING ""
	echo -e "${RES_COLOR}${BOLD}${SEPARATOR}${RESET}\n"
}


# RUN SCRIPT
print_header
source ./measure_delay.sh
check_norm
build_program
run_cases
print_result