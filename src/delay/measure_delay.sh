#!/bin/bash

compile_usleep() {
	echo '#include <unistd.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
	if (argc > 1) usleep(atoi(argv[1]));
	return 0;
}
' > utils/usleep.c

	cc utils/usleep.c -o utils/usleep
}

# Function to measure the delay of usleep
measure() {
    start=$(date +%s%N)  # Get start time in nanoseconds
    ./utils/usleep 200000  # Sleep for 200 milliseconds
    end=$(date +%s%N)  # Get end time in nanoseconds
    delay=$(echo "scale=3; ($end - $start) / 1000000" | bc)  # Calculate delay in milliseconds
    echo "$delay - 200" | bc  # Subtract the expected 200ms and return the delay
}

# Function to calculate the mean of an array
mean() {
    local sum=0
    local count=0
    for value in "$@"; do
        sum=$(echo "$sum + $value" | bc)
        count=$((count + 1))
    done
    echo "scale=3; $sum / $count" | bc
}

# Function to calculate the maximum value in an array
max() {
    local max_value=$1
    shift
    for value in "$@"; do
        if (( $(echo "$value > $max_value" | bc -l) )); then
            max_value=$value
        fi
    done
    echo "$max_value"
}

# Main function to measure system delay
measure_system_delay() {
    local avgs=()
	avg_color=$OK_COLOR
	peak_color=$OK_COLOR

	compile_usleep

	spinner="\\|/-"
	for i in {1..20}; do
		echo -en "\r${ACCENT_COLOR}${HEADER_EMOJI} Measuring system delay ${spinner:i%4:1}"
		avgs+=($(measure))
	done
	echo -en "\r${ACCENT_COLOR}${HEADER_EMOJI} Measuring system delay  "
    echo -e "${RESET}\n"

    local avg_delay=$(mean "${avgs[@]}")
    local peak_delay=$(max "${avgs[@]}")

	if (( $(echo "$avg_delay > 5" | bc -l) )); then
		avg_color=$WARNING_COLOR
	fi

	if (( $(echo "$peak_delay > 6" | bc -l) )); then
		peak_color=$WARNING_COLOR
	fi


    echo -e "${avg_color}[1] Average delay: ${avg_delay}ms"
    echo -e "${peak_color}[2] Peak delay: ${peak_delay}ms"

    if (( $(echo "$peak_delay > 10" | bc -l) )); then
        echo -e "${WARNING} ${YELLOW} Your machine delay is more than 10ms ${RESET}"
        sleep 5
    fi
	echo -e "\n"
	rm utils/usleep.c utils/usleep
}
