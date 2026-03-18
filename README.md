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
It fetches, rebases, and keeps your branches in sync with the default branch (`origin/HEAD`), while handling local changes safely.

---

## ✨ Features

- 🔄 Update multiple repositories at once
- ⚡ Parallel execution support
- 🎯 Interactive selection with `fzf`
- ⏱️ Filter repositories by recent remote changes (`--since`)
- 🔀 Rebase current branch on default branch
- 🧹 Auto-stash and restore local changes
- 📜 Optional detailed logs
- 🧠 Smart log cleanup (only failures kept by default)

---

## 📦 Installation

### Option 1: Manual

```bash
chmod +x git-align
mv git-align ~/.local/bin
```

Make sure `~/.local/bin` is in your `$PATH`.

---

### Option 2: Homebrew-style (custom)

```bash
cp git-align $(brew --prefix)/bin
```

---

## 🚀 Usage

```bash
git-align [options]
```

---

## ⚙️ Options

| Option               | Description                                     |
| -------------------- | ----------------------------------------------- |
| `-p, --parallel <n>` | Run in parallel with `n` jobs                   |
| `-s, --since <time>` | Only update repos with recent remote changes    |
| `-i, --interactive`  | Select repositories using `fzf`                 |
| `-v, --verbose`      | Show detailed logs after execution              |
| `--logs`             | Persist logs (otherwise only failures are kept) |
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

## 🧠 How it works

For each repository:

1. Fetches all remotes
2. Detects default branch (`origin/HEAD`)
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

The suite now includes an integration test that creates temporary Git repositories and verifies branch update/rebase behavior end to end.

---

## 🚢 Releases

Releases are managed by `semantic-release` on `main`. Conventional commits drive the next tag, `CHANGELOG.md`, and the tracked `VERSION` file. The CLI reads its version from `git-align.version` for installed copies, then `VERSION`, then the latest Git tag.

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

* Uses `fd` for fast repository discovery
* Supports parallel execution via `xargs -P`
* Optimized for large monorepo-style directory structures

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

* `--dry-run`
* progress indicator
* colored output
* JSON output mode

---

## ❤️ Inspiration

Built for developers working across many repositories who want to stay up-to-date without friction.
