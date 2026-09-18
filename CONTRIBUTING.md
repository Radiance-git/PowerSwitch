# Contributing to PowerSwitch

Thanks for considering a contribution! PowerSwitch aims to stay small,
readable, and dependency-free, so please keep that in mind when proposing
changes.

## Getting started

1. Fork the repository and clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/power-switch.git
   cd power-switch
   ```
2. Create a branch for your change:
   ```bash
   git checkout -b fix/short-description
   ```
3. Make sure you have the runtime dependencies installed locally:
   - `bash`
   - `udevadm`
   - `powerprofilesctl` (from `power-profiles-daemon`)
   - `shellcheck` (for linting)

## Making changes

- Keep the script POSIX-friendly where practical; the project intentionally
  avoids Bash-specific features unless they add real value.
- Every new function should be covered by at least one test in
  `tests/test.sh`.
- Run the full check locally before opening a PR:
  ```bash
  shellcheck src/power-switch install.sh uninstall.sh tests/test.sh
  ./tests/test.sh
  ```
- Update `README.md` if you change installation steps, behavior, or
  requirements.

## Commit messages

Use short, imperative commit messages (e.g. `Add dry-run mode`, not
`Added dry-run mode` or `dry run stuff`).

## Pull requests

- Describe **what** changed and **why**, not just a summary of the diff.
- Link any related issue with `Closes #123` if applicable.
- Keep PRs focused — one logical change per PR is easier to review and
  merge quickly.
- CI (ShellCheck + tests) must pass before a PR can be merged.

## Reporting bugs / requesting features

Please use the issue templates provided when opening a new issue — they
make sure we get the information needed to reproduce or evaluate a request
on the first pass.

## Code of Conduct

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md). By
participating, you agree to uphold it.
