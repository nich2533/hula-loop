# PR Review Process

This reference is invoked by `.claude/skills/pr/SKILL.md`. Customize it to match your team's PR review conventions.

## 1. Setup

- `gh pr checkout <N>` — check out the PR branch locally
- `gh pr diff <N>` — pull the full diff; check for truncation (large PRs may need `--patch`)
- Identify the base branch and list all changed files
- Read each changed file **in full** — do not rely on the diff alone; context outside the hunks often matters

## 2. Pre-Analysis

- Build a file-by-file checklist: what changed, what else in the file is affected, what's downstream
- Check `gh pr view <N> --comments` for prior review feedback — do not repeat points others already raised
- Cross-reference related files: if a function signature changed, find all callers

## 3. Verification

Before writing any finding, verify it against the actual file on disk. Do not cite code from memory. If a finding involves a line number, confirm the line still matches.

## 4. Review Checklist

For each changed file, evaluate:

- **Critical** — data loss, security vulns, broken production flows, regressions in safety-critical paths
- **High** — incorrect behavior, missing error handling, violations of project conventions that will cause bugs
- **Medium** — code smells, missing tests, duplicated logic, style violations
- **Low** — nits, minor readability, optional improvements

### Database Query Review (when DB code changes)

- Query patterns — prefer strict lookups over loose ones
- Index coverage — verify the query's WHERE/JOIN columns are indexed
- Migration safety — backwards compatibility, locking behavior, rollback plan
- Transaction boundaries — any new write should be evaluated for atomicity needs

## 5. UAT Recommendations

Map each substantive change to recommended manual test steps. Include:

- Primary user flow affected
- Edge cases the change introduces
- Viewports (mobile / desktop) if UI changes

## 6. Implicit Changes

Identify changes that aren't obvious from the diff:

- Architectural shifts (new dependencies, inverted control flow, new abstractions)
- Business logic changes (user-facing behavior differences, permission changes)
- Performance characteristics (new queries, N+1 risks, caching changes)
