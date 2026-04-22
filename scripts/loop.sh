#!/usr/bin/env bash
#
# Automated loop using headless Claude Code.
#
# Usage:
#   ./scripts/loop.sh <template|instruction> [PR_NUMBER] [ITERATIONS]
#
# Named templates (stored in scripts/loop-templates/):
#   ./scripts/loop.sh pr 3492            # PR review (10 iterations)
#   ./scripts/loop.sh test 3             # No PR — run test template 3 times on current branch
#
# Ad-hoc instructions:
#   ./scripts/loop.sh "Look for bugs" 3492 3
#   ./scripts/loop.sh "Check for accessibility issues" 3492
#
# To add a new template, create scripts/loop-templates/<name>.md
# Use {{PR_NUMBER}} as a placeholder — it gets replaced automatically.
#

set -euo pipefail

for cmd in claude git; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command '$cmd' not found in PATH"
    exit 1
  fi
done

if ! GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "Error: not inside a git repository. Run from a git-tracked project."
  exit 1
fi
cd "$GIT_ROOT"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/loop-templates"

TEMPLATE_OR_INSTRUCTION="${1:?Usage: loop.sh <template|instruction> [PR_NUMBER] [ITERATIONS]}"
PR_NUMBER=""
ITERATIONS="10"

# If arg 2 looks like a number and arg 3 is empty, it could be either a PR number
# or an iteration count (when no PR is needed). Disambiguate:
#   loop.sh test 3        → no PR, 3 iterations
#   loop.sh pr 3492       → PR 3492, 10 iterations
#   loop.sh pr 3492 5     → PR 3492, 5 iterations
if [ -n "${2:-}" ] && [ -n "${3:-}" ]; then
  PR_NUMBER="$2"
  ITERATIONS="$3"
elif [ -n "${2:-}" ]; then
  # Single numeric arg: PR number if template uses {{PR_NUMBER}}, otherwise iterations
  TEMPLATE_FILE_CHECK="${TEMPLATE_DIR}/${TEMPLATE_OR_INSTRUCTION}.md"
  if [ -f "$TEMPLATE_FILE_CHECK" ] && ! grep -q '{{PR_NUMBER}}' "$TEMPLATE_FILE_CHECK"; then
    ITERATIONS="$2"
  else
    PR_NUMBER="$2"
  fi
fi

if ! [[ "$ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "Error: ITERATIONS must be a number, got '${ITERATIONS}'"
  exit 1
fi

if [ -n "$PR_NUMBER" ] && ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "Error: PR_NUMBER must be numeric, got '${PR_NUMBER}'"
  exit 1
fi

if [ -n "$PR_NUMBER" ] && ! command -v gh >/dev/null 2>&1; then
  echo "Error: 'gh' CLI required for PR workflows but not found in PATH"
  exit 1
fi

# Resolve the instruction block: named template or ad-hoc string
TEMPLATE_FILE="${TEMPLATE_DIR}/${TEMPLATE_OR_INSTRUCTION}.md"
if [ -f "$TEMPLATE_FILE" ]; then
  LABEL="${TEMPLATE_OR_INSTRUCTION}"
  INSTRUCTIONS=$(sed "s|{{PR_NUMBER}}|${PR_NUMBER}|g" "$TEMPLATE_FILE")
else
  LABEL=$(echo "$TEMPLATE_OR_INSTRUCTION" | tr '[:upper:] ' '[:lower:]-' | tr -cd '[:alnum:]-' | cut -c1-40)
  if [ -n "$PR_NUMBER" ]; then
    TASK="${TEMPLATE_OR_INSTRUCTION} for PR ${PR_NUMBER}."
  else
    TASK="${TEMPLATE_OR_INSTRUCTION}"
  fi
  INSTRUCTIONS="${TASK}

## Do not do these things

- Commit your changes. I will commit them.
- Expand the scope of this project.
- Run linting, TypeCheck, or Build. I will do that.

## Working Log
"
fi

# Check for uncommitted changes before doing anything destructive
if [ -n "$(git status --porcelain)" ]; then
  echo "WARNING: You have uncommitted changes. Stash or commit before running."
  exit 1
fi

# Checkout the PR branch if a PR number was given
if [ -n "$PR_NUMBER" ]; then
  echo "=== Checking out PR #${PR_NUMBER} branch ==="
  gh pr checkout "$PR_NUMBER"
  git pull
fi
echo "=== On branch: $(git branch --show-current) ==="

# Build worklog filename
if [ -n "$PR_NUMBER" ]; then
  WORKLOG="documentation/working_log/${PR_NUMBER}-${LABEL}.md"
else
  WORKLOG="documentation/working_log/${LABEL}.md"
fi

# Create the working log if it doesn't exist (after checkout so we don't conflict with pulled files)
# Templates are expected to end with their own "## Working Log" heading; ad-hoc instructions get
# one appended above when INSTRUCTIONS is built.
if [ ! -f "$WORKLOG" ]; then
  mkdir -p "$(dirname "$WORKLOG")"
  printf '%s\n' "$INSTRUCTIONS" > "$WORKLOG"
  echo "Created ${WORKLOG}"
else
  echo "Using existing ${WORKLOG}"
fi

# Run the review loop
for i in $(seq 1 "$ITERATIONS"); do
  echo "=== Run ${i} of ${ITERATIONS} [${LABEL}] ==="
  claude -p "Read ${WORKLOG} and follow those instructions." \
    --dangerously-skip-permissions \
    --allowedTools "Read,Grep,Glob,Edit(./...),Write(./...),Bash,Task"
  echo "=== Run ${i} complete ==="
done

echo "=== All ${ITERATIONS} runs complete [${LABEL}] ==="
