#!/bin/bash

set -u

INSTALL_PATH="$HOME/.local/bin/power-switch"
INSTALLED_SERVICE="$HOME/.config/systemd/user/power-switch.service"

log() {
    echo "[PowerSwitch] $*"
}

error() {
    echo "[PowerSwitch] ERROR: $*" >&2
}

main() {
    log "Uninstalling PowerSwitch..."

    if systemctl --user is-active --quiet power-switch.service 2>/dev/null; then
        log "Stopping PowerSwitch service..."
        systemctl --user stop power-switch.service || true
    fi

    if systemctl --user is-enabled --quiet power-switch.service 2>/dev/null; then
        log "Disabling PowerSwitch service..."
        systemctl --user disable power-switch.service || true
    fi

    if [ -f "$INSTALLED_SERVICE" ]; then
        rm -f "$INSTALLED_SERVICE" || {
            error "Failed to remove service file."
            exit 1
        }

        log "Removed service file."
    fi

    if [ -f "$INSTALL_PATH" ]; then
        rm -f "$INSTALL_PATH" || {
            error "Failed to remove executable."
            exit 1
        }

        log "Removed executable."
    fi

    systemctl --user daemon-reload || {
        error "Failed to reload systemd user manager."
        exit 1
    }

    log "PowerSwitch has been uninstalled."
}

main