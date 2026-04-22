# Customizing hula_loop for your project

The shipped agents and templates are generic starters. Here's how to adapt them.

## Agents (`.claude/agents/`)

The `code-qa` and `security-auditor` agents are invoked by the PR skill. Edit their system prompts to reflect what you care about most. Add new agents for domains that matter to your product (e.g., `accessibility-reviewer.md`, `performance-reviewer.md`).

## PR Process (`.claude/skills/pr/reference/pr_process.md`)

This is where your team's PR review conventions live. The shipped version is a reasonable default, but you'll want to capture:

- How you identify the base branch
- What counts as Critical vs High vs Medium for your product
- Team-specific cross-checks (design review, accessibility audit, legal review)

## Templates (`scripts/loop-templates/`)

Copy an existing template and edit it to create a new recurring workflow:

```bash
cp scripts/loop-templates/pr.md scripts/loop-templates/security-audit.md
# edit security-audit.md to describe the task
./scripts/loop.sh security-audit 1234
```

Use `{{PR_NUMBER}}` as a placeholder if your template operates on a specific PR.

## UX Audit paths (in `.claude/skills/pr/SKILL.md`)

The PR skill has a UX Audit section that triggers when UI files change. Update the path patterns to match your project's layout. Examples:

- React/Next.js: `apps/web/components/**`, `apps/web/app/**/*.tsx`
- Vue: `src/components/**`, `src/views/**`
- Django: `templates/**`, `static/**/*.css`
- Rails: `app/views/**`, `app/assets/**`

## Working log location

The loop writes to `documentation/working_log/`. If your project uses a different docs layout, edit `scripts/loop.sh` to change the `WORKLOG=` line.
