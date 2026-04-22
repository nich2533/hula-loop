# hula_loop

Automated multi-iteration code review for Claude Code. Loop a PR review until issues settle, with templates for recurring tasks.

## What it does

`hula_loop` wraps Claude Code's headless mode (`claude -p`) in a shell loop. Each iteration appends to a working log, so the model can see prior rounds and avoid repeating itself. Two example templates ship by default:

- **`pr`** — review a pull request and fix Critical/High/Medium issues
- **`test`** — minimal loop to verify the plumbing works

Both are starting points — copy and edit them for your own workflows.

## Install

Clone `hula_loop` once to a long-lived tools directory, then run the installer against each project you want to use it in.

**macOS / Linux:**

```bash
# one time
git clone https://github.com/nich2533/hula-loop.git ~/tools/hula-loop

# for each project you want to install it into
bash ~/tools/hula-loop/install.sh /path/to/your/project
```

**Windows (PowerShell):**

```powershell
# one time
git clone https://github.com/nich2533/hula-loop.git C:/tools/hula-loop

# for each project
bash C:/tools/hula-loop/install.sh C:/Users/<you>/code/<your-project>
```

If bash's directory check rejects a `C:/...` path, use the Git Bash form instead: `/c/Users/<you>/code/<your-project>`.

The installer copies `.claude/` and `scripts/` into your project without overwriting existing files, and appends `documentation/working_log/` and `.claude/settings.local.json` to the target's `.gitignore`.

To update later: `cd` into the tools clone, `git pull`, and re-run the installer against each project. Existing customizations in target projects are preserved (`cp -n` never overwrites).

## Usage

After installing, `cd` into the target project. There are two ways to invoke a review.

### Interactive — one-shot review inside Claude Code

```bash
claude
```

Then at the prompt:

```
/pr 1234
```

Runs the PR skill once. Claude fetches the diff, reads the changed files, and returns a structured review.

### Automated loop — multi-iteration headless review

```bash
./scripts/loop.sh pr 1234         # 10 iterations (default)
./scripts/loop.sh pr 1234 3       # 3 iterations
./scripts/loop.sh test 3          # sanity check — no PR needed
./scripts/loop.sh "Look for accessibility issues" 1234 3   # ad-hoc instruction
```

The loop spawns headless `claude` repeatedly. Each iteration reads the existing working log (so it can see what prior rounds found), reviews and optionally fixes issues, then appends a new `### Round N` section. Working logs land in `documentation/working_log/<PR>-<template>.md`.

Issues tend to settle after a few rounds — the loop is useful specifically because a single pass often misses things that a subsequent pass, informed by the log, will catch.

## Customizing

The shipped agents and templates are **generic starters**. Tailor them to your stack:

- `.claude/agents/*.md` — reviewer agent definitions
- `.claude/skills/pr/reference/pr_process.md` — your PR review process
- `scripts/loop-templates/*.md` — templates for recurring workflows

See [`docs/customizing.md`](docs/customizing.md) for a walkthrough.

## Requirements

- [Claude Code CLI](https://claude.com/claude-code), installed and authenticated (verify with `claude --version`)
- `git` and [`gh` (GitHub CLI)](https://cli.github.com/) authenticated (`gh auth status`) — only needed for PR workflows
- `bash` — on Windows, [Git for Windows](https://git-scm.com/download/win) includes Git Bash

## Troubleshooting

**`./scripts/loop.sh: $'\r': command not found`**

CRLF line endings. The latest hula_loop ships a `.gitattributes` that prevents this on fresh clones, but if you have an older checkout:

```bash
git config core.autocrlf false
git checkout -- scripts/loop.sh install.sh
```

**`WARNING: You have uncommitted changes` but `git status` looks clean**

You're likely running from a different shell than the one that created the checkout (for example, WSL against a repo cloned via PowerShell). The two git instances have different `autocrlf` settings and every file shows as modified due to phantom line-ending diffs. Fix per-repo:

```bash
git config core.autocrlf false
git checkout -- .
```

**`target directory 'C:/...' does not exist` when the path clearly exists**

Git Bash's POSIX-style check can't resolve Windows drive-letter paths. Use `/c/Users/...` form, or pass a relative path from where you're running the installer.

## License

MIT — see [LICENSE](LICENSE).
