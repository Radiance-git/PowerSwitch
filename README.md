# PowerSwitch

A lightweight Linux utility that automatically switches power profiles between **performance** and **power-saver** modes based on AC power connection status.

PowerSwitch monitors power supply events and changes the active power profile automatically using `powerprofilesctl`.

## Features

* Automatic switching between AC and battery power modes
* Performance profile when the charger is connected
* Power-saver profile when running on battery
* Real-time power event monitoring using `udev`
* Lightweight Bash implementation
* Runs as a user-level systemd service
* Automated test suite
* ShellCheck validated
* Simple installation and removal scripts

## How It Works

PowerSwitch monitors Linux power supply events:

```
AC connected
      |
      v
Detect power change
      |
      v
Enable performance profile
```

```
AC disconnected
      |
      v
Detect power change
      |
      v
Enable power-saver profile
```

The project uses:

* `udev` for detecting power supply changes
* `systemd --user` for background service management
* `powerprofilesctl` for changing power profiles

## Requirements

PowerSwitch requires:

* Linux
* Bash
* systemd user services
* udev
* power-profiles-daemon

Check available power profiles:

```bash
powerprofilesctl list
```

## Installation

Clone the repository:

```bash
git clone https://github.com/Radiance-git/PowerSwitch.git
```

Enter the project directory:

```bash
cd PowerSwitch
```

Run the installer:

```bash
./install.sh
```

The installer will:

* Install the PowerSwitch executable
* Create the systemd user service
* Enable automatic startup
* Start the service

## Usage

After installation, PowerSwitch runs automatically in the background.

Check service status:

```bash
systemctl --user status power-switch.service
```

View logs:

```bash
journalctl --user -u power-switch.service -f
```

## Service Management

Start:

```bash
systemctl --user start power-switch.service
```

Stop:

```bash
systemctl --user stop power-switch.service
```

Restart:

```bash
systemctl --user restart power-switch.service
```

Enable at startup:

```bash
systemctl --user enable power-switch.service
```

Disable startup:

```bash
systemctl --user disable power-switch.service
```

## Uninstallation

To remove PowerSwitch:

```bash
./uninstall.sh
```

The uninstall script removes:

* Installed executable
* systemd user service
* Service configuration

## Testing

PowerSwitch includes an automated test suite.

Run:

```bash
./tests/test.sh
```

The tests verify:

* Source file availability
* Bash syntax
* ShellCheck compliance
* Required functions
* Required commands
* Power state detection
* Multiple power adapters handling
* Profile mapping
* Invalid input handling
* Profile update behavior

Current test status:

```
32 tests passed
0 tests failed
```

## Project Structure

```
PowerSwitch/
│
├── src/
│   └── power-switch
│
├── systemd/
│   └── power-switch.service
│
├── tests/
│   └── test.sh
│
├── install.sh
├── uninstall.sh
│
├── README.md
├── SECURITY.md
├── LICENSE
│
└── .github/
    └── workflows/
        └── ci.yml
```

## Troubleshooting

### Power profile does not change

Check available profiles:

```bash
powerprofilesctl list
```

Check power-profiles-daemon:

```bash
systemctl status power-profiles-daemon
```

### Service problems

View service logs:

```bash
journalctl --user -u power-switch.service
```

Restart the service:

```bash
systemctl --user restart power-switch.service
```

## Limitations

* Requires Linux systems with `power-profiles-daemon`
* Depends on kernel power supply information
* Tested primarily on Ubuntu-based systems

## Contributing

Contributions are welcome.

Before submitting changes:

Run ShellCheck:

```bash
shellcheck src/power-switch install.sh uninstall.sh tests/test.sh
```

Run tests:

```bash
./tests/test.sh
```

Please keep changes focused and include tests for new behavior.

## Security

For security reports, please read:

[SECURITY.md](SECURITY.md)

## License

This project is licensed under the MIT License.

See [LICENSE](LICENSE) for details.