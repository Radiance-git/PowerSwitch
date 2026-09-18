#!/bin/bash

set -u

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_FILE="$PROJECT_ROOT/src/power-switch"
INSTALL_SCRIPT="$PROJECT_ROOT/install.sh"
UNINSTALL_SCRIPT="$PROJECT_ROOT/uninstall.sh"
SERVICE_FILE="$PROJECT_ROOT/systemd/power-switch.service"

PASS=0
FAIL=0

pass() {
    echo "PASS: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "FAIL: $1"
    FAIL=$((FAIL + 1))
}

run_test() {
    local description="$1"
    local test_function="$2"
    shift 2

    if "$test_function" "$@"; then
        pass "$description"
    else
        fail "$description"
    fi
}

test_file_exists() {
    [ -f "$1" ]
}

test_executable() {
    [ -x "$1" ]
}

test_syntax() {
    bash -n "$1"
}

test_shellcheck() {
    if ! command -v shellcheck >/dev/null 2>&1; then
        return 0
    fi

    shellcheck "$1"
}

test_function_exists() {
    local function_name="$1"

    grep -q "^${function_name}()" "$SOURCE_FILE"
}

test_command_exists() {
    local command_name="$1"

    command -v "$command_name" >/dev/null 2>&1
}

test_get_power_state_ac() {
    local temp_dir

    temp_dir="$(mktemp -d)" || return 1

    echo "1" > "$temp_dir/online" || {
        rm -rf "$temp_dir"
        return 1
    }

    if [ "$(get_power_state "$temp_dir")" = "ac" ]; then
        rm -rf "$temp_dir"
        return 0
    fi

    rm -rf "$temp_dir"
    return 1
}

test_get_power_state_battery() {
    local temp_dir

    temp_dir="$(mktemp -d)" || return 1

    echo "0" > "$temp_dir/online" || {
        rm -rf "$temp_dir"
        return 1
    }

    if [ "$(get_power_state "$temp_dir")" = "battery" ]; then
        rm -rf "$temp_dir"
        return 0
    fi

    rm -rf "$temp_dir"
    return 1
}

test_get_power_state_missing_file() {
    local temp_dir

    temp_dir="$(mktemp -d)" || return 1

    if get_power_state "$temp_dir" >/dev/null 2>&1; then
        rm -rf "$temp_dir"
        return 1
    fi

    rm -rf "$temp_dir"
    return 0
}

test_get_power_state_multiple_adapters() {
    local temp_dir
    local adapter1
    local adapter2

    temp_dir="$(mktemp -d)" || return 1

    adapter1="$temp_dir/AC"
    adapter2="$temp_dir/AC2"

    mkdir -p "$adapter1" "$adapter2" || {
        rm -rf "$temp_dir"
        return 1
    }

    echo "0" > "$adapter1/online"
    echo "1" > "$adapter2/online"

    if [ "$(get_power_state "$adapter1" "$adapter2")" = "ac" ]; then
        rm -rf "$temp_dir"
        return 0
    fi

    rm -rf "$temp_dir"
    return 1
}

test_get_power_state_multiple_adapters_battery() {
    local temp_dir
    local adapter1
    local adapter2

    temp_dir="$(mktemp -d)" || return 1

    adapter1="$temp_dir/AC"
    adapter2="$temp_dir/AC2"

    mkdir -p "$adapter1" "$adapter2" || {
        rm -rf "$temp_dir"
        return 1
    }

    echo "0" > "$adapter1/online"
    echo "0" > "$adapter2/online"

    if [ "$(get_power_state "$adapter1" "$adapter2")" = "battery" ]; then
        rm -rf "$temp_dir"
        return 0
    fi

    rm -rf "$temp_dir"
    return 1
}

test_target_profile_ac() {
    [ "$(get_target_profile "ac")" = "performance" ]
}

test_target_profile_battery() {
    [ "$(get_target_profile "battery")" = "power-saver" ]
}

test_target_profile_invalid() {
    if get_target_profile "invalid" >/dev/null 2>&1; then
        return 1
    fi

    return 0
}

test_apply_profile_invalid_state() {
    if apply_power_profile "invalid" >/dev/null 2>&1; then
        return 1
    fi

    return 0
}

test_update_power_profile_changed() {
    local old_function

    old_function="$(declare -f apply_power_profile)"

    apply_power_profile() {
        [ "$1" = "ac" ]
    }

    if update_power_profile "ac" "battery"; then
        eval "$old_function"
        return 0
    fi

    eval "$old_function"
    return 1
}

test_update_power_profile_unchanged() {
    local old_function

    old_function="$(declare -f apply_power_profile)"

    apply_power_profile() {
        return 1
    }

    if update_power_profile "battery" "battery"; then
        eval "$old_function"
        return 0
    fi

    eval "$old_function"
    return 1
}

test_service_file_exists() {
    [ -f "$SERVICE_FILE" ]
}

test_install_script_exists() {
    [ -f "$INSTALL_SCRIPT" ]
}

test_uninstall_script_exists() {
    [ -f "$UNINSTALL_SCRIPT" ]
}

echo "Running PowerSwitch tests..."
echo

run_test "source file exists" test_file_exists "$SOURCE_FILE"
run_test "source file is executable" test_executable "$SOURCE_FILE"
run_test "bash syntax is valid" test_syntax "$SOURCE_FILE"
run_test "source passes ShellCheck" test_shellcheck "$SOURCE_FILE"

run_test "function exists: find_ac_adapters" \
    test_function_exists find_ac_adapters
run_test "function exists: get_power_state" \
    test_function_exists get_power_state
run_test "function exists: get_target_profile" \
    test_function_exists get_target_profile
run_test "function exists: apply_power_profile" \
    test_function_exists apply_power_profile
run_test "function exists: update_power_profile" \
    test_function_exists update_power_profile
run_test "function exists: monitor_power_events" \
    test_function_exists monitor_power_events
run_test "function exists: main" \
    test_function_exists main

run_test "command exists: bash" test_command_exists bash
run_test "command exists: udevadm" test_command_exists udevadm
run_test "command exists: powerprofilesctl" test_command_exists powerprofilesctl

run_test "service file exists" test_service_file_exists
run_test "install script exists" test_install_script_exists
run_test "uninstall script exists" test_uninstall_script_exists

run_test "install script syntax is valid" test_syntax "$INSTALL_SCRIPT"
run_test "uninstall script syntax is valid" test_syntax "$UNINSTALL_SCRIPT"

run_test "install script passes ShellCheck" \
    test_shellcheck "$INSTALL_SCRIPT"
run_test "uninstall script passes ShellCheck" \
    test_shellcheck "$UNINSTALL_SCRIPT"

# shellcheck source=/dev/null
source "$SOURCE_FILE"

run_test "get_power_state detects AC" \
    test_get_power_state_ac
run_test "get_power_state detects battery" \
    test_get_power_state_battery
run_test "get_power_state handles missing online file" \
    test_get_power_state_missing_file
run_test "get_power_state handles multiple adapters" \
    test_get_power_state_multiple_adapters
run_test "get_power_state handles multiple adapters on battery" \
    test_get_power_state_multiple_adapters_battery

run_test "AC maps to performance profile" \
    test_target_profile_ac
run_test "battery maps to power-saver profile" \
    test_target_profile_battery
run_test "invalid power state is rejected" \
    test_target_profile_invalid
run_test "invalid apply_power_profile state is rejected" \
    test_apply_profile_invalid_state

run_test "update_power_profile handles changed state" \
    test_update_power_profile_changed
run_test "update_power_profile ignores unchanged state" \
    test_update_power_profile_unchanged

echo
echo "--------------------------------"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "--------------------------------"

if [ "$FAIL" -eq 0 ]; then
    echo "All tests passed."
    exit 0
fi

echo "Some tests failed."
exit 1