#!/bin/bash

# Colors
RED="\033[38;5;168m"
TEAL="\033[38;5;37m"
GOLD="\033[38;5;136m"
BLUE="\033[38;5;68m"
MAGENTA="\033[38;5;164m"
SKY_BLUE="\033[38;5;31m"
# LIGHT_BLUE="\033[38;5;39m"
LIGHT_GRAY="\033[38;5;252m"
DARK_GRAY="\033[38;5;243m"
RUST="\033[38;5;130m"
VIOLET="\033[38;5;99m"
PINK="\033[38;5;205m"
WHITE="\033[38;5;15m"

# Text Styles
BOLD="\e[1m"
UNDERLINE="\e[4m"
RESET="\033[38;5;15m\e[0m"


# Meaning Colors
MAIN_COLOR=$WHITE
ADD_COLOR=$DARK_GRAY
ACCENT_COLOR=$SKY_BLUE
WARNING_COLOR=$RUST
OK_COLOR=$TEAL
KO_COLOR=$RED

MANUAL_TEST_COLOR=$VIOLET
INFO_COLOR=$LIGHT_GRAY

# Header style
HEADER_NAME="PHILOTESTER"
HEADER_COLOR=$SKY_BLUE
HEADER_SEP="-"
LINE_LENGTH=$(tput cols)

# Emoji
HEADER_EMOJI="🥢"
INFO_EMOJI="ℹ️ "
MANUAL_TEST_EMOJI="✍️ "
OK="✅"
KO="💀"
WARNING="⚠️ "
CRUSH_EMOJI="💀 "
LEAK_EMOJI="💧 "
RACE_EMOJI="🏁 "
SUCCESS="🎉"
FAILURE="☠️"

