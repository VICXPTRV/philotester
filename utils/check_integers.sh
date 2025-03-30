#!/bin/bash

is_int_not_overflow() {
    local INT_MAX="2147483647"
    local INT_MIN="-2147483648"

    for num in "$@"; do
        # Positive check
        if [[ "$num" =~ ^[0-9]+$ ]]; then
            if [[ ${#num} -gt ${#INT_MAX} || ( ${#num} -eq ${#INT_MAX} && "$num" > "$INT_MAX" ) ]]; then
                return 1  # Overflow
            fi
        fi

        # Negative check
        if [[ "$num" =~ ^-[0-9]+$ ]]; then
            stripped="${num:1}"
            if [[ ${#stripped} -gt $((${#INT_MIN} - 1)) || ( ${#stripped} -eq $((${#INT_MIN} - 1)) && "$stripped" > "${INT_MIN:1}" ) ]]; then
                return 1  # Underflow
            fi
        fi
    done
    return 0  # OK
}

is_int_positive() {
    for num in "$@"; do
        if [[ "$num" == -*  || "$num" == 0 ]]; then
            return 1 # Negative or zero
        fi
    done
    return 0  # All positive
}

is_int_valid() {
	for num in "$@"; do
		if [[ ! "$num" =~ ^-?[0-9]+$ ]]; then
			return 1
		fi
	done
	return 0 # All valid
}

is_int_more_than_sixty() {
	t_die=$1
	t_eat=$2
	t_sleep=$3

	if ! [[ $t_die =~ ^[0-9]+$ && $t_eat =~ ^[0-9]+$ && $t_sleep =~ ^[0-9]+$ ]]; then
		return 0
	fi

	if [[ -z $t_die || -z $t_eat || -z $t_sleep ]]; then
		return 0; fi

	if [[ $t_die -lt 60 || $t_eat -lt 60 || $t_sleep -lt 60 ]]; then
		return 1
	fi
	return 0
}

