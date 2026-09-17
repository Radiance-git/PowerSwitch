#!/bin/bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_FILE="$PROJECT_DIR/src/power-switch"

PASSED=0
FAILED=0


pass() {
    echo "PASS: $1"
    PASSED=$((PASSED + 1))
}


fail() {
    echo "FAIL: $1"
    FAILED=$((FAILED + 1))
}


assert_contains() {
    local output="$1"
    local expected="$2"
    local test_name="$3"

    if echo "$output" | grep -Fq "$expected"; then
        pass "$test_name"
    else
        fail "$test_name"
        echo "  Expected to contain: $expected"
        echo "  Actual output: $output"
    fi
}


echo "Running PowerSwitch tests..."
echo


if [ -f "$SOURCE_FILE" ]; then
    pass "Source file exists"
else
    fail "Source file exists"
fi


if [ -x "$SOURCE_FILE" ]; then
    pass "Source file is executable"
else
    fail "Source file is executable"
fi


if head -n 1 "$SOURCE_FILE" | grep -q '^#!/bin/bash$'; then
    pass "Bash shebang exists"
else
    fail "Bash shebang exists"
fi


if grep -q 'udevadm monitor --kernel --subsystem-match=power_supply' "$SOURCE_FILE"; then
    pass "Event-driven power monitoring is enabled"
else
    fail "Event-driven power monitoring is enabled"
fi



if grep -q 'target_profile="performance"' "$SOURCE_FILE"; then
    pass "Performance profile is supported"
else
    fail "Performance profile is supported"
fi


if grep -q 'target_profile="power-saver"' "$SOURCE_FILE"; then
    pass "Power-saver profile is supported"
else
    fail "Power-saver profile is supported"
fi


if grep -q 'find_ac_adapter' "$SOURCE_FILE"; then
    pass "Dynamic AC adapter detection exists"
else
    fail "Dynamic AC adapter detection exists"
fi


if grep -q 'trap shutdown SIGTERM' "$SOURCE_FILE"; then
    pass "Graceful SIGTERM shutdown exists"
else
    fail "Graceful SIGTERM shutdown exists"
fi


if grep -q 'trap shutdown SIGINT' "$SOURCE_FILE"; then
    pass "Graceful SIGINT shutdown exists"
else
    fail "Graceful SIGINT shutdown exists"
fi

if command -v shellcheck >/dev/null 2>&1; then
    if shellcheck "$SOURCE_FILE"; then
        pass "ShellCheck"
    else
        fail "ShellCheck"
    fi
else
    fail "ShellCheck is installed"
fi

echo
echo "--------------------------------"
echo "Tests passed: $PASSED"
echo "Tests failed: $FAILED"
echo "--------------------------------"


if [ "$FAILED" -eq 0 ]; then
    echo "All tests passed."
    exit 0
else
    echo "Some tests failed."
    exit 1
fi
