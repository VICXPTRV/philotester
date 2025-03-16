# Philotester 🥢

⚠️ Note: This project is still under development

A robust testing suite for the Dining Philosophers project. Automates norm checks, compilation, test case validation, and memory leak detection.

<!-- ![Test Example](add png when done) -->

## Features

- **Norm Compliance Check** - Ensures code adheres to 42's standards
- **Auto-compilation** - Builds your project before testing
- **Comprehensive Test Cases** - Predefined scenarios in `cases/` directory
- **Valgrind Integration** - Memory leak detection with `-v` flag
- **Performance Metrics** - Measures system delay impact
- **Detailed Logging** - Stores complete test outputs in `logs/`
- **Color-coded Results** - Instant visual feedback

## Installation

1. Clone the tester:
```bash
git clone git@github.com:VICXPTRV/philotester.git
cd philotester
```

2. Configure paths:
   - Open `philotester` script
   - Update `EXEC_PATH` to point to your philo project
   - Update `VALGRIND` to customize flags (optional)

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
./philotester invalid_input edge_cases
```

## Test Customization

All test cases are stored in the `cases/` directory. Each file contains pairs of:

1. **Test Input**:  
   Program arguments for `philo` (e.g., `number_of_philosophers time_to_die time_to_eat time_to_sleep [meal_count]`).

2. **Expected Outcomes**:  
   Validation metrics in the format:  
   ```
   [max_deaths] [min_meals] [min_sleeps] [min_thinks]
   ```

**Example**:
```text
# Test input
3 400 200 200 2

# Expected results
0 4 2 2
```

### Adding New Test Cases
1. Create a new file in the `cases/` directory.
2. Add test pairs following the format:
   - Line 1: Program arguments
   - Line 2: Expected results
3. Repeat for additional test cases.

## Logs

- Detailed test outputs in `logs/` directory
- Valgrind reports in `logs/valgrind.log`
- Automatic cleanup between runs
