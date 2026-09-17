#!/bin/bash

set -u

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SOURCE_FILE="$PROJECT_DIR/src/power-switch"
SERVICE_FILE="$PROJECT_DIR/systemd/power-switch.service"

BIN_DIR="$HOME/.local/bin"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

INSTALL_PATH="$BIN_DIR/power-switch"
INSTALLED_SERVICE="$SYSTEMD_USER_DIR/power-switch.service"


error() {
    echo "[PowerSwitch] ERROR: $*" >&2
}


log() {
    echo "[PowerSwitch] $*"
}


check_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        error "Required command not found: $command_name"
        return 1
    fi
}


main() {
    log "Installing PowerSwitch..."

    if [ ! -f "$SOURCE_FILE" ]; then
        error "Source file not found: $SOURCE_FILE"
        exit 1
    fi

    if [ ! -f "$SERVICE_FILE" ]; then
        error "Service file not found: $SERVICE_FILE"
        exit 1
    fi

    check_command systemctl || exit 1
    check_command udevadm || exit 1
    check_command powerprofilesctl || exit 1

    mkdir -p "$BIN_DIR"
    mkdir -p "$SYSTEMD_USER_DIR"

    chmod +x "$SOURCE_FILE"

    cp "$SOURCE_FILE" "$INSTALL_PATH"
    cp "$SERVICE_FILE" "$INSTALLED_SERVICE"

    systemctl --user daemon-reload

    systemctl --user enable power-switch.service
    systemctl --user restart power-switch.service

    log "PowerSwitch installed successfully."
    log "Executable: $INSTALL_PATH"
    log "Service: $INSTALLED_SERVICE"
    log "Service status:"

    systemctl --user --no-pager --full status power-switch.service
}


main
