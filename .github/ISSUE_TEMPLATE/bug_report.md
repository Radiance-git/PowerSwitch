---
name: Bug report
about: Report unexpected behavior in PowerSwitch
title: "[Bug] "
labels: bug
assignees: ''
---

**Describe the bug**
A clear description of what's going wrong.

**To reproduce**
Steps to reproduce the behavior:
1. Run '...'
2. Plug/unplug AC adapter
3. See error / wrong profile applied

**Expected behavior**
What you expected to happen instead.

**Logs**
Paste relevant output from:
```bash
journalctl --user -u power-switch.service -n 50
```

**Environment**
- Distro / version: [e.g. Ubuntu 24.04]
- Desktop environment: [e.g. GNOME, KDE]
- `power-profiles-daemon` version: `powerprofilesctl --version`
- Output of `systemctl --user status power-switch.service`

**Additional context**
Anything else relevant (multiple batteries/adapters, custom udev rules, etc).
