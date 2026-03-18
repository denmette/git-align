# git-align

```
             __    __                      __  __                     
            /  |  /  |                    /  |/  |                    
    ______  $$/  _$$ |_           ______  $$ |$$/   ______   _______  
   /      \ /  |/ $$   |  ______ /      \ $$ |/  | /      \ /       \ 
  /$$$$$$  |$$ |$$$$$$/  /      |$$$$$$  |$$ |$$ |/$$$$$$  |$$$$$$$  |
  $$ |  $$ |$$ |  $$ | __$$$$$$/ /    $$ |$$ |$$ |$$ |  $$ |$$ |  $$ |
  $$ \__$$ |$$ |  $$ |/  |      /$$$$$$$ |$$ |$$ |$$ \__$$ |$$ |  $$ |
  $$    $$ |$$ |  $$  $$/       $$    $$ |$$ |$$ |$$    $$ |$$ |  $$ |
   $$$$$$$ |$$/    $$$$/         $$$$$$$/ $$/ $$/  $$$$$$$ |$$/   $$/ 
  /  \__$$ |                                      /  \__$$ |          
  $$    $$/                                       $$    $$/           
   $$$$$$/                                         $$$$$$/            

```

> Keep multiple Git repositories aligned with their default branch.

`git-align` helps you update many local repositories in one go.
It fetches, rebases, and keeps your branches in sync with the remote default branch while handling local changes safely.

---

## ✨ Features

- 🔄 Update multiple repositories at once
- ⚡ Parallel execution support
- 📊 Live progress output while repositories are processed
- 🎯 Interactive selection with `fzf`
- ⏱️ Filter repositories by recent remote changes (`--since`)
- 🔀 Rebase current branch on default branch
- 🧪 Preview changes with `--dry-run`
- 🧹 Auto-stash and restore local changes
- 🧭 Fallback detection when local `origin/HEAD` is missing
- 📜 Optional detailed logs
- 🧠 Smart log cleanup (only failures kept by default)

---

## 📦 Installation

### Option 1: Installer

```bash
bash install.sh
```

This installs `git-align` and its companion `git-align.version` file into Homebrew's bin when writable, or `~/.local/bin` otherwise.

---

### Option 2: Manual

```bash
cp bin/git-align ~/.local/bin/git-align
cp VERSION ~/.local/bin/git-align.version
chmod +x ~/.local/bin/git-align
```

Make sure `~/.local/bin` is in your `$PATH`.

---

## 🚀 Usage

```bash
git-align [options]
```

Use `git-align --help` to print the current version and CLI help.

---

## ⚙️ Options

| Option               | Description                                     |
| -------------------- | ----------------------------------------------- |
| `-p, --parallel <n>` | Run in parallel with `n` jobs                   |
| `-s, --since <time>` | Only update repos with recent remote changes    |
| `-i, --interactive`  | Select repositories using `fzf`                 |
| `-v, --verbose`      | Show detailed logs after execution              |
| `--logs`             | Persist logs (otherwise only failures are kept) |
| `--dry-run`          | Show planned actions without changing repos     |
| `-V, --version`      | Show version                                    |
| `-h, --help`         | Show help                                       |

---

## 🔥 Examples

### Update everything

```bash
git-align
```

---

### Parallel execution

```bash
git-align -p 4
```

---

### Only recent changes

```bash
git-align -s "2 days ago"
```

---

### Interactive selection

```bash
git-align -i
```

---

### Power combo

```bash
git-align -p 4 -s "1 week ago" -i
```

---

### Debug mode

```bash
git-align -v --logs
```

---

### Dry run

```bash
git-align --dry-run
```

---

### Dry run with selection

```bash
git-align -i --dry-run
```

---

## 🧠 How it works

For each repository:

1. Fetches all remotes
2. Detects the default branch, recovering `origin/HEAD` when possible
3. Checks if updates are needed
4. Stashes local changes if necessary
5. Updates default branch
6. Rebases current branch on top of it
7. Restores stash

---

## 📜 Logs

* By default:

  * Only logs of failed repositories are kept
* With `--logs`:

  * All logs are persisted under:

```bash
~/.git-align/logs/<timestamp>
```

---

## 🧪 Development

Run the current shell test suite with:

```bash
bash tests/run.sh
```

This covers CLI argument handling and syntax validation. Add new tests under `tests/` as standalone Bash scripts.

The suite includes command-level integration tests for rebase behavior, empty selections, invalid options, dry runs, missing `origin/HEAD`, and path handling with spaces.

---

## 🚢 Releases

Releases are managed manually through the GitHub Actions `Release` workflow. Conventional commits still drive the next semantic version, but a release is only created when you trigger the workflow. `semantic-release` updates the Git tag, `CHANGELOG.md`, and the tracked `VERSION` file. The CLI reads its version from `git-align.version` for installed copies, then `VERSION`, then the latest Git tag.

To cut a release:

```text
GitHub -> Actions -> Release -> Run workflow
```

Use the optional `dry_run` workflow input to preview the next version and notes without creating a tag or release.

---

## ⚠️ Requirements

* `git`
* [`fd`](https://github.com/sharkdp/fd)
* [`fzf`](https://github.com/junegunn/fzf) (optional, for interactive mode)

Install via Homebrew:

```bash
brew install fd fzf
```

---

## ⚡ Performance

* Uses `fd` for fast repository discovery when available
* Falls back to `find` when `fd` is not installed
* Supports parallel execution and live progress output

---

## 🛡️ Disclaimer

This tool performs rebases and modifies local repositories.

> Use at your own risk.

Always ensure you understand your Git workflow before running it on critical repositories.

---

## 📄 License

MIT License — do whatever you want, at your own responsibility.

---

## 🙌 Contributing

Feel free to fork, tweak, and improve.

Ideas for future improvements:

* colored output
* JSON output mode

---

## ❤️ Inspiration

Built for developers working across many repositories who want to stay up-to-date without friction.
