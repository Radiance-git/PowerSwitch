#!/bin/bash

set -u

INSTALL_PATH="$HOME/.local/bin/power-switch"
INSTALLED_SERVICE="$HOME/.config/systemd/user/power-switch.service"


log() {
    echo "[PowerSwitch] $*"
}


main() {
    log "Uninstalling PowerSwitch..."

    if systemctl --user is-active --quiet power-switch.service; then
        log "Stopping PowerSwitch service..."
        systemctl --user stop power-switch.service
    fi

    if systemctl --user is-enabled --quiet power-switch.service; then
        log "Disabling PowerSwitch service..."
        systemctl --user disable power-switch.service
    fi

    if [ -f "$INSTALLED_SERVICE" ]; then
        rm -f "$INSTALLED_SERVICE"
        log "Removed service file."
    fi

    if [ -f "$INSTALL_PATH" ]; then
        rm -f "$INSTALL_PATH"
        log "Removed executable."
    fi

    systemctl --user daemon-reload

    log "PowerSwitch has been uninstalled."
}


main
