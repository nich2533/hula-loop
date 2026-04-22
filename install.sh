#!/usr/bin/env bash
#
# Install hula_loop into a target project directory.
#
# Usage:
#   ./install.sh /path/to/your/project
#
# Copies .claude/ and scripts/ into the target without overwriting existing files.
#

set -euo pipefail

TARGET="${1:?Usage: install.sh /path/to/your/project}"

if [ ! -d "$TARGET" ]; then
  echo "Error: target directory '$TARGET' does not exist"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing hula_loop into ${TARGET}..."

# -R recursive, -n no-clobber (never overwrites files the user has already customized)
mkdir -p "${TARGET}/.claude" "${TARGET}/scripts"
cp -Rn "${SCRIPT_DIR}/.claude/." "${TARGET}/.claude/"
cp -Rn "${SCRIPT_DIR}/scripts/." "${TARGET}/scripts/"

chmod +x "${TARGET}/scripts/loop.sh"

# Ensure the target's .gitignore excludes the runtime worklog directory
GITIGNORE="${TARGET}/.gitignore"
if [ ! -f "$GITIGNORE" ] || ! grep -qxF 'documentation/working_log/' "$GITIGNORE"; then
  {
    echo ""
    echo "# hula_loop runtime output"
    echo "documentation/working_log/"
  } >> "$GITIGNORE"
  echo "Added documentation/working_log/ to ${GITIGNORE}"
fi

echo ""
echo "Installed. Next steps:"
echo "  1. Review and customize .claude/agents/*.md for your team"
echo "  2. Review and customize scripts/loop-templates/*.md for your workflows"
echo "  3. Try: cd ${TARGET} && ./scripts/loop.sh test 3"
