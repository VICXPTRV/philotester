#!/bin/bash

# NORM (optional)
check_norm() {
	if [[ ! -d "logs/log_norm" ]]; then
		mkdir logs/log_norm
	else
		rm -f logs/log_norm/*; fi
	NORM_LOG="logs/log_norm/norm.log"
	echo -e "${HEADER_EMOJI}${HEADER_COLOR} Testing: build and norm${RESET}"
	make -C "$EXEC_PATH" fclean > /dev/null 2>&1
	norminette $EXEC_PATH > ${NORM_LOG} 2>&1
	if [[ $? -eq 0 ]]; then
		echo -e "${OK_COLOR}[1] Norminette ok${RESET}"
	else
		echo -e "${KO_COLOR}[1] Norminette failed. See: ${NORM_LOG}${RESET}"
	fi
}

build_tsanitize() {

    CFLAGS="$TSANITAZER" CXXFLAGS="$TSANITAZER" make -C "$EXEC_PATH" re > "${TSAN_PATH}/build.log" 2>&1

    # Check if the build with ThreadSanitizer passed or failed
    if [[ $? -eq 0 ]]; then
        echo -e "${OK_COLOR}[2] Build successfully with ThreadSanitizer\n${RESET}"
    else
        echo -e "${KO_COLOR}[2] Build failed with ThreadSanitizer. See: ${THREAD_SANITIZE_LOG}${RESET}"
		exit 1
    fi

}

# BUILD
build_program() {

	if [[ $F_TSAN == true ]]; then
		build_tsanitize
		return
	fi

	if [[ ! -d "logs/log_build" ]]; then
		mkdir logs/log_build
	else
		rm -f logs/log_build/*; fi

	BUILD_LOG="logs/log_build/build.log"
	BUILD_FAIL=$(make -C "$EXEC_PATH" re > "$BUILD_LOG" 2>&1)
	if [[ $? -eq 0 ]]; then
		echo -e "${OK_COLOR}[2] Build sucessfully\n${RESET}"
	else
		echo -e "${KO_COLOR}[2] Build failed. See: ${BUILD_LOG} ${RESET}"
		echo "$BUILD_FAIL"
		exit 1
	fi
}

