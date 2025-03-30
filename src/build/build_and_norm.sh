#!/bin/bash

# NORM (optional)
check_norm() {
	echo -e "${HEADER_EMOJI}${HEADER_COLOR} Testing: build and norm${RESET}"
	make -C "$EXEC_PATH" fclean > /dev/null 2>&1
	norminette $EXEC_PATH > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		echo -e "${OK_COLOR}[1] Norminette ok${RESET}"
	else
		echo -e "${KO_COLOR}[1] Norminette failed...${RESET}"
	fi
}

# BUILD
build_program() {

	BUILD_FAIL=$(make -C "$EXEC_PATH" re > /dev/null 2>&1)
	if [[ $? -eq 0 ]]; then
		echo -e "${OK_COLOR}[2] Build sucessfully\n${RESET}"
	else
		echo -e "${KO_COLOR}[2] Build failed..${RESET}"
		echo "$BUILD_FAIL"
		exit 1
	fi
}
