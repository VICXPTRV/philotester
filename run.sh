#!/bin/bash

BOLD="\e[1m"
YELLOW="\033[0;33m"         # Yellow (already defined)
GREY="\033[38;5;244m"       # Dark Grey (already defined)
PURPLE="\033[0;35m"         # Purple (already defined)
BLUE="\033[38;5;74m"        # Tokyo Night Blue
RED="\033[38;5;204m"        # Tokyo Night Red
GREEN="\033[38;5;114m"      # Tokyo Night Green
CYAN="\033[38;5;121m"       # Tokyo Night Cyan
WHITE="\033[38;5;248m"      # Tokyo Night White
ORANGE="\033[38;5;214m"     # Tokyo Night Orange
RESET="\033[0m"             # Reset color

MANDATORY="../../thread_mutex/philo"
CASES_PATH="cases"

if [ ! -d "logs" ]; then
    mkdir logs
fi

run_mandatory=true
specified_cases=()

while getopts "m" opt; do
    case $opt in
        m) run_mandatory=true ;;  # Only mandatory
    esac
done
shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
    specified_cases=($(ls "$CASES_PATH"))
else
    specified_cases=("$@")
fi

echo -e "${PURPLE}${BOLD}------------------------------------------------------${RESET}"
echo -e "${PURPLE}${BOLD}🥢               PHILOSOPHERS TESTER               🥢${RESET}"
echo -e "${PURPLE}${BOLD}------------------------------------------------------${RESET}"

extract_stats() {
    local log_file=$1
    local deaths=0 meals=0 sleeps=0 thinks=0
    
    deaths=$(grep -c "died" "$log_file")
    meals=$(grep -c "is eating" "$log_file")
    sleeps=$(grep -c "is sleeping" "$log_file")
    thinks=$(grep -c "is thinking" "$log_file")
    
    echo "$deaths $meals $sleeps $thinks"
}

run_test() {
    local binary=$1
    local case_name=$2
    local test_file="$CASES_PATH/$case_name"

    if [ ! -f "$test_file" ]; then
        echo "Test case file '$case_name' not found!" >&2
        return
    fi

    echo -e "${PURPLE}$case_name ${RESET}"

    while IFS= read -r test_case && IFS= read -r expected_values; do
        [[ -z "$test_case" || -z "$expected_values" ]] && continue  

        log_file="logs/${case_name}_output.log"
        output=$(eval "$binary $test_case" 2>&1)
        echo "$output" >> "$log_file"

        read -r expected_deaths expected_meals expected_sleeps expected_thinks <<< "$expected_values"
        read -r actual_deaths actual_meals actual_sleeps actual_thinks <<< "$(extract_stats "$log_file")"

        if [[ "$actual_deaths" -eq "$expected_deaths" && "$actual_meals" -eq "$expected_meals" && "$actual_sleeps" -eq "$expected_sleeps" && "$actual_thinks" -eq "$expected_thinks" ]]; then
            echo -e "✅ ${CYAN}$test_case ${RESET}"
        else
            echo -e "💀 ${RED}$test_case${RESET}"
        fi
		echo -e "${GREY}  Deaths   : $actual_deaths (actual) vs $expected_deaths (expected)"
		echo "  Meals    : $actual_meals (actual) vs $expected_meals (expected)"
		echo "  Sleeps   : $actual_sleeps (actual) vs $expected_sleeps (expected)"
		echo -e "  Thinks   : $actual_thinks (actual) vs $expected_thinks (expected)${RESET}"
    done < "$test_file"
}

for case_name in "${specified_cases[@]}"; do
    if $run_mandatory; then
        run_test "$MANDATORY" "$case_name"
    fi
done
