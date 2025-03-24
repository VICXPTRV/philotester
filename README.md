# Philotester 🥢

> [!WARNING]  
> This tester is not fully ready yet. It currently checks only norminette, project build, and invalid input cases.

A testing suite for the Dining Philosophers project. Automates norm checks, compilation, test case validation, and memory leak detection.

<!-- ![Test Example](add png when done) -->

## Features

- **Norminette** - Ensures code adheres to standards
- **Compilation** - Builds your project before testing
- **Valgrind** - Memory leak detection with `-v` flag
- **Test Cases** - Predefined scenarios in `cases/` directory
- **Performance** - Measures system delay impact

## Installation

1. Clone the tester:
```bash
git clone git@github.com:VICXPTRV/philotester.git
cd philotester
```

2. Configure the tester:
   - Open file `config`
   - Update `EXEC_PATH` to point to your philo project
   - Update `VALGRIND` to customize flags (optional)
   - Update `T_LIMIT` to customize timeout for  

## Usage

**Basic test:**
```bash
./philotester
```

**Test with valgrind memory checks:**
```bash
./philotester -v
```

**Run specific test cases:**
```bash
./philotester invalid_input one_philo
```

## Adding New Test Cases

All test cases are stored in the `cases/` directory.
You can change existing case or add new one

**Test case format**:
```text
number_of_philosophers time_to_die time_to_eat time_to_sleep meal_count
```

**Example**:
```text
3 400 200 200 2
1 400 200 200
```

## Logs

- Your program output in `logs/` directory
- Valgrind reports in `logs/valgrind.log`
- Automatic cleanup between runs
