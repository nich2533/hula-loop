# hula_loop

Automated multi-iteration code review for Claude Code. Loop a PR review until issues settle, with templates for recurring tasks.

## What it does

`hula_loop` wraps Claude Code's headless mode (`claude -p`) in a shell loop. Each iteration appends to a working log, so the model can see prior rounds and avoid repeating itself. Two example templates ship by default:

- **`pr`** — review a pull request and fix Critical/High/Medium issues
- **`test`** — minimal loop to verify the plumbing works

Both are starting points — copy and edit them for your own workflows.

## Install

```bash
git clone https://github.com/<your-user>/hula_loop.git
cd hula_loop
./install.sh /path/to/your/project
```

The installer copies `.claude/` and `scripts/` into your project without overwriting existing files.

## Usage

```bash
# PR review, 10 iterations
./scripts/loop.sh pr 1234

# Sanity check, 3 iterations, no PR needed
./scripts/loop.sh test 3

# Ad-hoc instruction
./scripts/loop.sh "Look for accessibility issues" 1234 3
```

Working logs land in `documentation/working_log/<PR>-<template>.md`. Each loop iteration appends a new `### Round N` section.

## Customizing

The shipped agents and templates are **generic starters**. Tailor them to your stack:

- `.claude/agents/*.md` — reviewer agent definitions
- `.claude/skills/pr/reference/pr_process.md` — your PR review process
- `scripts/loop-templates/*.md` — templates for recurring workflows

See [`docs/customizing.md`](docs/customizing.md) for a walkthrough.

## Requirements

- Claude Code CLI installed and authenticated
- `git` and `gh` (GitHub CLI) for PR workflows
- `bash`

## License

MIT — see [LICENSE](LICENSE).
