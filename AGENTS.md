# Repository Guidelines

## Project Structure & Module Organization
This repository is a small Bash CLI tool. The main executable lives at [bin/git-align](/Users/macs/Coding/Personal/git-align/bin/git-align), installation logic is in [install.sh](/Users/macs/Coding/Personal/git-align/install.sh), and usage notes live in [README.md](/Users/macs/Coding/Personal/git-align/README.md). There is no `src/` or `tests/` directory yet; if tests are added, keep them under `tests/` and mirror the CLI behavior they cover.

## Build, Test, and Development Commands
Use `bash bin/git-align --help` to verify the CLI parses and prints usage. Use `bash bin/git-align -v --logs` for a verbose local run against repositories under the current directory. Use `bash install.sh` to install `git-align` into Homebrew’s bin when writable, or `~/.local/bin` otherwise. Before opening a PR, run `bash -n bin/git-align install.sh` to catch shell syntax errors.

## Coding Style & Naming Conventions
Keep scripts POSIX-leaning Bash unless a Bash-specific feature is clearly needed. Follow the existing style in `bin/git-align`: two-space indentation, uppercase globals like `LOG_DIR`, and lowercase local variables like `repo` and `log_file`. Prefer descriptive long options such as `--parallel` and `--interactive`. Keep user-facing output concise and aligned with current CLI messaging.

## Testing Guidelines
There is no automated test suite yet, so validation is currently command-based. At minimum, check syntax with `bash -n` and exercise the help/version paths plus one real run in a safe directory, for example `bash bin/git-align --version`. If you add tests, favor lightweight shell-based integration checks and name them after the behavior under test, such as `tests/help_output.sh`.

## Commit & Pull Request Guidelines
Recent history uses conventional prefixes like `feat:` and `release:`; keep commit subjects short, imperative, and scoped to one change. Pull requests should explain the user-visible effect, note any dependency changes (`fd`, `fzf`, `git`), and include sample commands or terminal output when behavior changes. Link related issues when applicable.

## Security & Configuration Tips
`git-align` performs `fetch`, `switch`, `pull --rebase`, and `rebase`, so avoid testing against critical repositories first. Use `GIT_ALIGN_LOG_DIR` when you need logs in a custom location, and document any new environment variables in `README.md`.
