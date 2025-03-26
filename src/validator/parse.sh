#!bin/bash

source utils/style.sh

fill_table() {
	time="$1"
	philo="$2"
	action="$3"
	max="$4"

	declare -gA table

	# Initialize if not set
	[[ -z "${table[$philo]}" ]] && table["$philo"]=""

	if ! [[ "$philo" =~ ^[0-9]+$ ]]; then
		TEST_MSG="Invalid philosopher number: $philo (not a number)"
		FLAG_FAIL=true
    	return
	fi
	if [[ "$philo" -lt 1 || "$philo" -gt "$max" ]]; then
		TEST_MSG="Invalid philosopher number: $philo max: $max"
		FLAG_FAIL=true
        return
    fi
    table["$philo"]+="$time $action"$'\n'
}

parse_output() {

	log_file="$1"
	number_of_philos="$2"


	while IFS=" " read -r first second rest; do
		TEST_MSG=""
		if echo "$first $second $rest" | grep -q "segmentation"; then
			TEST_MSG="Segmentation fault"
			continue
		elif [[ "$first" =~ ^[0-9]+$ && "$second" =~ ^[0-9]+$ ]]; then
			time="$first"
			philo="$second"
			action="$rest"
			fill_table "$time" "$philo" "$action" "$number_of_philos"
		else
			TEST_MSG="Unexpected output"
			FLAG_FAIL=true
			continue
		fi
	done < "$log_file"
}

parse_input(){

	test_case="$1"

	number_of_philos=$(echo "$test_case" | cut -d " " -f 1)
	t_die="$(echo "$test_case" | cut -d " " -f 2)"
	t_eat="$(echo "$test_case" | cut -d " " -f 3)"
	t_sleep="$(echo "$test_case" | cut -d " " -f 4)"
	meals_to_eat="$(echo "$test_case" | cut -d " " -f 5)"
	extra_arg="$(echo "$test_case" | cut -d " " -f 6)"

}
