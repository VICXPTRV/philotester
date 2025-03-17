#!/bin/bash

is_int_overflow() {
    local INT_MAX="2147483647"
    local INT_MIN="-2147483648"

    for num in "$@"; do
        # Positive check
        if [[ "$num" =~ ^[0-9]+$ ]]; then
            if [[ ${#num} -gt ${#INT_MAX} || ( ${#num} -eq ${#INT_MAX} && "$num" > "$INT_MAX" ) ]]; then
                return 0  # Overflow
            fi
        fi

        # Negative check
        if [[ "$num" =~ ^-[0-9]+$ ]]; then
            stripped="${num:1}"
            if [[ ${#stripped} -gt $((${#INT_MIN} - 1)) || ( ${#stripped} -eq $((${#INT_MIN} - 1)) && "$stripped" > "${INT_MIN:1}" ) ]]; then
                return 0  # Underflow
            fi
        fi
    done
    return 1  # OK
}

is_int_negative_or_zero() {
    for num in "$@"; do
        if [[ "$num" == -*  || "$num" == 0 ]]; then
            return 0  # Negative or xero
        fi
    done
    return 1  # All positive
}
