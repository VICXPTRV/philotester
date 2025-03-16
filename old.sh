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


MANDATORY="../../philo/philo"
BONUS="../../philo_bonus/philo_bonus"
CASES_PATH="cases"

test_cases=(
    "parsing"
)

if [ ! -d "logs" ]; then
    mkdir logs
fi

run_mandatory=true
run_bonus=true
specified_cases=()

while getopts "mb" opt; do
    case $opt in
        m) run_bonus=false ;;  # Only mandatory
        b) run_mandatory=false ;;  # Only bonus
    esac
done
shift $((OPTIND - 1))

# If no specific cases given, use all in test_cases
if [ $# -eq 0 ]; then
    specified_cases=("${test_cases[@]}")
else
    specified_cases=("$@")
fi

> "logs/${case_name}_output.log"
> "logs/${case_name}_valgrind.log"
> "logs/${case_name}_valgrind_output.log"


echo -e "${RED}${BOLD}------------------------------------------------------${RESET}"
echo -e "${RED}${BOLD}🥢               PHILOSOPHERS TESTER               🥢${RESET}"
echo -e "${RED}${BOLD}------------------------------------------------------${RESET}"

run_test() {
    local binary=$1
    local case_name=$2

    if [ ! -f "$CASES_PATH/$case_name" ]; then
        echo "Test case file '$CASES_PATH/$case_name' not found!" >&2
        return
    fi

    echo -e "${PURPLE}$case_name ${RESET}"

    # Loop through each line in the test case file
    while IFS= read -r test_case; do
        echo "$test_case"

        echo "------------$test_case------------\n" >> "logs/${case_name}_output.log"
        echo "------------$test_case------------\n" >> "logs/${case_name}_valgrind.log"
		if $binary $test_case >> "logs/${case_name}_output.log" 2>&1; then
			valgrind --leak-check=full --show-reachable=yes --log-file="logs/${case_name}_valgrind.log" $binary $test_case >> "logs/${case_name}_valgrind_output.log" 2>&1
		fi
    done < "$CASES_PATH/$case_name"
}

for case_name in "${specified_cases[@]}"; do
    if $run_mandatory; then
        run_test "$MANDATORY" "$case_name"
    fi
    if $run_bonus; then
        run_test "$BONUS" "$case_name"
    fi
done

