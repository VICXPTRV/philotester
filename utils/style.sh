#!/bin/bash

# Text Styles
BOLD="\e[1m"
RESET="\033[0m"

# Colors
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

# Meaning Colors
OK_COLOR=$GREEN
KO_COLOR=$RED
WARNING_COLOR=$ORANGE
MAIN_COLOR=$WHITE
ADD_COLOR=$GREY
ACCENT_COLOR=$LIGHT_BLUE

# Header style
HEADER_NAME="DINING PHILOSOPHERS TESTER"
HEADER_COLOR=$LIGHT_BLUE
HEADER_SEP="-"
LINE_LENGTH=$(tput cols)

# Emoji
HEADER_EMOJI="🥢"
OK="✅"
KO="💀"
WARNING="⚠️"
LEAK="💧 "
SUCCESS="🎉"
FAILURE="☠️"
