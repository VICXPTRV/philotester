#!/bin/bash

# COLORS
# BOLD="\e[1m"
# RESET="\033[0m"
# BLACK="\033[38;5;0m"
# DARK_BLUE="\033[38;5;18m"
# # LIGHT_BLUE="\033[38;5;39m"
# LIGHT_BLUE="\033[38;5;81m"
# ICE_BLUE="\033[38;5;189m"
# VIOLET="\033[38;5;93m"
# PINK="\033[38;5;205m"
# RED="\033[38;5;196m"
# ORANGE="\033[38;5;208m"
# YELLOW="\033[38;5;226m"
# GREEN="\033[38;5;46m"
# CYAN="\033[38;5;37m"
# WHITE="\033[38;5;15m"    
# COLORS
BOLD="\e[1m"
RESET="\033[0m"
BLACK="\033[38;5;0m"
DARK_BLUE="\033[38;5;18m"
LIGHT_BLUE="\033[38;5;38m"   # Slightly lighter blue
PINK="\033[38;5;205m"
RED="\033[38;5;160m"        # Darker red
ORANGE="\033[38;5;166m"     # Orange, more muted
YELLOW="\033[38;5;221m"     # Soft yellow
GREEN="\033[38;5;28m"       # Dark green
WHITE="\033[38;5;15m"       # White


# PATH
EXEC_PATH="../../thread_mutex"					# Customize
EXEC="${EXEC_PATH}/philo"						# Customize
CASES_PATH="cases/"
if [[ ! -d "logs" ]]; then
	mkdir logs; fi
LOGS_PATH="logs"

# VALGRIND
if [[ ! -f "${LOGS_PATH}/valgrind.log" ]] ; then
	touch ${LOGS_PATH}/valgrind.log; fi
if [[ ! -f "valgrind.supp" ]] ; then
	touch "valgrind.supp"; fi
VALG_LOG=${LOGS_PATH}/valgrind.log
VALG_SUP="valgrind.supp"
VALGRIND="valgrind -q \
--track-fds=yes \
--trace-children=yes --leak-check=full \
--show-leak-kinds=all --error-limit=no \
--suppressions=$VALG_SUP \
--log-file=$VALG_LOG"

# FLAGS
flag_valgrind=false					# Customize
while getopts "v" flag; do
	case $flag in
		v) flag_valgrind=true ;; 		# Customize
	esac
done

# CASES
TOTAL=0
FAILED=0
if [[ $# -gt 0 ]]; then
	cases=("$@")
else
	cases=($(ls $CASES_PATH)); fi

# HEADER
print_header() {
	HEADER_NAME="DINING PHILOSOPHERS TESTER"	# Customize
	HEADER_COLOR=$LIGHT_BLUE						# Customize
	HEADER_EMOJI="🥢"							# Customize
	HEADER_SEP="-"
	LINE_LENGTH=$(tput cols)
    HEADER_TEXT="${HEADER_EMOJI} ${HEADER_NAME} ${HEADER_EMOJI}"

    # Calculate padding to center the header
    SEPARATOR=$(printf "%-${LINE_LENGTH}s" "" | tr " " "-")

    # Calculate the padding needed to center the header text
    HEADER_TEXT_LENGTH=${#HEADER_TEXT}
    PADDING=$(( (LINE_LENGTH - HEADER_TEXT_LENGTH) / 2 ))

    echo -e "\n${HEADER_COLOR}${BOLD}${SEPARATOR}${RESET}\n"
    printf "${HEADER_COLOR}${BOLD}%*s%s%*s${RESET}\n" $PADDING "" "$HEADER_TEXT" $PADDING ""
    echo -e "${HEADER_COLOR}${BOLD}${SEPARATOR}${RESET}\n"
}

# NORM (optional)
check_norm() {
    echo -e "${HEADER_EMOJI}${HEADER_COLOR}build and norm${RESET}"
	make -C "$EXEC_PATH" fclean > /dev/null 2>&1
	norminette $EXEC_PATH > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		echo -e "${CYAN}✅ Norminette ok${RESET}"
	else
		echo -e "${RED}💀 Norminette failed...${RESET}"
	fi
}

# BUILD
build_program() {

	BUILD_FAIL=$(make -C "$EXEC_PATH" re > /dev/null 2>&1)
	if [[ $? -eq 0 ]]; then
		echo -e "${CYAN}✅ Build sucessfully\n${RESET}"
	else
		echo -e "${RED}💀 Build failed..${RESET}"
		echo "$BUILD_FAIL"
		exit 1
	fi
}

run_cases() {
	for case in ${cases[@]}; do
        echo -e "${HEADER_EMOJI}${HEADER_COLOR}${case}${RESET}"
		run_tests case
		echo -e "\n"
	done
}

run_tests() {

	if [[ : ]]; then
		echo -e "${CYAN}✅ testcase${RESET}"
	else
		echo -e "${RED}💀 testcase${RESET}"
		((FAILED++))
	fi
	((TOTAL++))
}

print_result() {
    PASSED=$((TOTAL - FAILED))
    if [[ "$PASSED" -eq "$TOTAL" ]] ; then
        RES_EMOJI="🎉"
		RES_COLOR=$CYAN
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
check_norm
build_program
run_cases
print_result