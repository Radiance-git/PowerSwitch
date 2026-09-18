#!/bin/bash

set -u

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SOURCE_FILE="$PROJECT_DIR/src/power-switch"
SERVICE_FILE="$PROJECT_DIR/systemd/power-switch.service"

BIN_DIR="$HOME/.local/bin"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

INSTALL_PATH="$BIN_DIR/power-switch"
INSTALLED_SERVICE="$SYSTEMD_USER_DIR/power-switch.service"

log() {
    echo "[PowerSwitch] $*"
}

error() {
    echo "[PowerSwitch] ERROR: $*" >&2
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

    for command in systemctl udevadm powerprofilesctl; do
        check_command "$command" || exit 1
    done

    mkdir -p "$BIN_DIR" "$SYSTEMD_USER_DIR" || {
        error "Failed to create installation directories."
        exit 1
    }

    chmod +x "$SOURCE_FILE" || {
        error "Failed to make source executable."
        exit 1
    }

    install -m 0755 "$SOURCE_FILE" "$INSTALL_PATH" || {
        error "Failed to install executable."
        exit 1
    }

    install -m 0644 "$SERVICE_FILE" "$INSTALLED_SERVICE" || {
        error "Failed to install systemd service."
        exit 1
    }

    systemctl --user daemon-reload || {
        error "Failed to reload systemd user manager."
        exit 1
    }

    systemctl --user enable power-switch.service || {
        error "Failed to enable PowerSwitch service."
        exit 1
    }

    systemctl --user restart power-switch.service || {
        error "Failed to start PowerSwitch service."
        exit 1
    }

    log "PowerSwitch installed successfully."
    log "Executable: $INSTALL_PATH"
    log "Service: $INSTALLED_SERVICE"

    echo
    systemctl --user --no-pager --full status power-switch.service || true
}

main