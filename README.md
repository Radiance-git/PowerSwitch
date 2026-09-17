# PowerSwitch

> Automatically switch your Linux power profile when you plug in or unplug your laptop. PowerSwitch listens for power-supply events through udev and applies the appropriate `powerprofilesctl` profile without polling.

![Shell](https://img.shields.io/badge/shell-bash-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)

---

## Why PowerSwitch?

Power management tools can be much larger than what you need if all you want is automatic profile switching.

PowerSwitch focuses on one task:

> Listen for AC adapter events → apply the appropriate power profile.

It uses an event-driven approach instead of repeatedly polling the system.

| Feature                      | PowerSwitch                 | TLP                   | auto-cpufreq           |
| ---------------------------- | --------------------------- | --------------------- | ---------------------- |
| Event-driven power switching | ✅                           | ❌                     | ❌                      |
| Main purpose                 | Profile switching           | Full power management | CPU/power optimization |
| Runtime                      | Bash + systemd user service | Multiple components   | Python + daemon        |
| Configuration required       | None                        | Optional/configurable | Optional/configurable  |

---

## Features

* ⚡ **Event-driven** — reacts to power-supply events using `udevadm`
* 🪶 **Lightweight** — a small Bash daemon with a systemd user service
* 🔌 **Automatic AC detection** — discovers the AC adapter through the Linux `power_supply` subsystem
* 🛠️ **Simple installation** — install and uninstall with a single command
* 🛑 **Graceful shutdown** — handles `SIGTERM` and `SIGINT`
* 🔄 **Boot-time synchronization** — applies the correct profile when the service starts
* ✅ **Tested** — includes automated tests and ShellCheck validation

---

## How it works

PowerSwitch maps the current power state to a power profile:

| Power State      | Profile       |
| ---------------- | ------------- |
| 🔌 AC plugged in | `performance` |
| 🔋 On battery    | `power-saver` |

When the service starts, PowerSwitch:

1. Detects the available AC adapter.
2. Reads its current `online` state.
3. Applies the corresponding power profile.
4. Starts listening for power-supply events.
5. Changes the profile only when the power state changes.

While waiting for events, the daemon remains idle instead of continuously polling the system.

---

## Requirements

* Linux with `systemd` user services
* Bash
* `udevadm`
* [`power-profiles-daemon`](https://gitlab.freedesktop.org/upower/power-profiles-daemon) providing `powerprofilesctl`

**Tested on:** Ubuntu Linux

> PowerSwitch is intended for Linux systems using `systemd`, `udev`, and `power-profiles-daemon`. Compatibility with other distributions may depend on their power-management configuration.

---

## Installation

Clone the repository and run the installer:

```bash
git clone https://github.com/YOUR_USERNAME/power-switch.git
cd power-switch
./install.sh
```

The installer:

1. Copies the PowerSwitch executable to `~/.local/bin/power-switch`
2. Installs the systemd user service
3. Reloads the systemd user manager
4. Enables the service
5. Starts the service

Check the service status:

```bash
systemctl --user status power-switch.service
```

You should see:

```text
Active: active (running)
```

---

## Service management

Check whether the service is running:

```bash
systemctl --user is-active power-switch.service
```

Restart the service:

```bash
systemctl --user restart power-switch.service
```

Stop the service:

```bash
systemctl --user stop power-switch.service
```

View service logs:

```bash
journalctl --user -u power-switch.service
```

Follow logs in real time:

```bash
journalctl --user -u power-switch.service -f
```

---

## Manual usage

The installed executable can also be run directly:

```bash
~/.local/bin/power-switch
```

This is useful for development and debugging.

Press `Ctrl+C` to stop it gracefully.

---

## Testing

Run the project test suite:

```bash
./tests/test.sh
```

The test suite checks the project structure, core implementation, required behavior, and ShellCheck validation.

You can also run ShellCheck directly:

```bash
shellcheck src/power-switch
```

---

## Uninstallation

From the project directory:

```bash
./uninstall.sh
```

The uninstaller:

* Stops the service
* Disables the service
* Removes the installed systemd user service
* Removes the installed executable

The source code in the project directory is not removed.

---

## Project structure

```text
power-switch/
├── src/
│   └── power-switch           # Main daemon script
├── systemd/
│   └── power-switch.service   # systemd user service unit
├── tests/
│   └── test.sh                # Test suite + ShellCheck
├── install.sh                 # Installation script
├── uninstall.sh               # Uninstallation script
├── .gitignore
└── README.md
```

---

## Roadmap

* [ ] Configurable power profiles
* [ ] Support for multiple AC adapters
* [ ] `--once` mode for testing
* [ ] Dry-run mode
* [ ] Optional desktop notifications
* [ ] Error scenario tests
* [ ] GitHub Actions CI

---

## Contributing

Contributions are welcome.

Before submitting a pull request, run:

```bash
./tests/test.sh
```

Make sure all tests pass and ShellCheck reports no issues.

---

## License

MIT License. See [LICENSE](LICENSE) for details.
