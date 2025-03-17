#!/bin/bash

# Text Styles
BOLD="\e[1m"
RESET="\033[0m"
# Colors
BLACK="\033[38;5;0m"        # Black
GREY="\033[38;5;250m"
DARK_BLUE="\033[38;5;25m"   # Dracula-inspired dark blue
LIGHT_BLUE="\033[38;5;39m"  # Bright but not overwhelming light blue
PINK="\033[38;5;213m"       # Soft pink
RED="\033[38;5;196m"        # Bright red for errors or warnings
ORANGE="\033[38;5;208m"     # Vibrant orange
YELLOW="\033[38;5;220m"     # Warm yellow
GREEN="\033[38;5;40m"       # Fresh green
WHITE="\033[38;5;15m"       # Pure white
PURPLE="\033[38;5;129m"     # Dracula-inspired purple (optional addition)

echo '#include <unistd.h>
#include <stdlib.h>
int main(int argc, char *argv[]) {
    if (argc > 1) usleep(atoi(argv[1]));
    return 0;
}' > usleep.c

cc usleep.c -o usleep

# Function to measure the delay of usleep
measure() {
    start=$(date +%s%N)  # Get start time in nanoseconds
    ./usleep 200000  # Sleep for 200 milliseconds
    end=$(date +%s%N)  # Get end time in nanoseconds
    delay=$(( (end - start) / 1000000 ))  # Calculate delay in milliseconds
    echo $((delay - 200))  # Subtract the expected 200ms and return the delay
}

# Function to calculate the mean of an array
mean() {
    local sum=0
    local count=0
    for value in "$@"; do
        sum=$((sum + value))
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

    echo -en "${LIGHT_BLUE}⏳ Measuring system delay for 200ms usleep on this machine"
    for i in {1..20}; do
        echo -n "."
        avgs+=($(measure))
    done
    echo -e "${RESET}\n"

    local avg_delay=$(mean "${avgs[@]}")
    local peak_delay=$(max "${avgs[@]}")

    echo "[1] Average delay: ${avg_delay}ms"
    echo "[2] Peak delay: ${peak_delay}ms"

    if (( $(echo "$avg_delay > 10" | bc -l) )); then
        echo -e "⚠️ ${YELLOW}Your machine delay is more than 10ms ${RESET}"
        sleep 5
    fi
	echo -e "\n"
}

# Run the measurement
measure_system_delay

rm usleep.c usleep