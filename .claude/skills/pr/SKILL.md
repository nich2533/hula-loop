---
name: pr
description: Review a pull request with structured analysis — fetches the diff, reads actual files, evaluates safety
---

Review the specified pull request using the full PR review process defined in `.claude/skills/pr/reference/pr_process.md`.

## Process

Follow the complete process in `.claude/skills/pr/reference/pr_process.md`, which covers:

1. **Setup** — Checkout branch, pull diff, check for truncation, read actual files
2. **Pre-Analysis** — Read ALL changed files in full, build file-by-file checklist, check prior reviews, cross-reference pass
3. **Verification** — Verify understanding against actual files before writing findings
4. **Review Checklist** — Critical/High/Medium/Low issues including database query review
5. **UAT Recommendations** — Map changes to recommended UI test suites
6. **Implicit Changes** — Identify architectural and business logic changes

Run specialized agents as needed:
- `code-qa` agent for bugs, style, and maintainability
- `security-auditor` agent for auth, PII, and data access

**Safety**: Assess privacy and user-safety impact on every PR. Customize the threshold for your product — flag flows that touch auth, payments, sensitive data, or other high-risk areas.

## UX Audit Integration

After completing the code review, check whether the PR touches UI files. If paths matching your UI layout appear in the diff, recommend a UX audit.

Configure the paths that indicate UI changes for your project — examples:
- Frontend component directories
- Page/route/view files
- Stylesheets (`.css`, `.scss`, style module files)
- Template files

When UI changes are detected:
1. Add a `### UX Audit` section to the review output (before the Decision section)
2. List the affected pages/routes based on the changed files
3. Recommend running `/ux-audit` with the specific URLs
4. If any changes touch safety-critical UI (auth flows, payments, privacy controls, emergency features), flag the UX audit as **required** rather than recommended

Format:
```
### UX Audit

**UI changes detected** — UX audit recommended.
- Changed routes: [list routes affected by the file changes]
- Safety-critical UI: [yes/no — and what]
- Suggested command: `/ux-audit <url> --mobile`
```

## Output Format

**IMPORTANT**: Output the review as a single message using EXACTLY this template. Do NOT summarize, reformat, or restructure the output. The review must end with the Decision section.

```
## AI Code Review — PR #<number>

### Summary

- **Scope**: [UI/Backend/Database]
- **Risk**: [Low/Medium/High]
- **Testing**: [Manual UAT required / Pass / Fail]

### Issues Found

#### Critical
[list or "No Critical Issues"]

#### High
[list or "No High Issues"]

#### Medium
[numbered list or "No Medium Issues"]

#### Low
[numbered list or "No Low Issues"]

### Implicit Changes

1. [Architectural changes — how key components work differently]
2. [Business logic changes — user-facing behavior differences]

### Database Query Review

- [x] **No query changes in this PR** (skip this section)
OR
- [ ] **Query changes reviewed:**
  - Queries modified: [list files and line numbers]
  - Index verification: [PASS/FAIL — list indexes used]
  - Unsafe query patterns: [NONE / JUSTIFIED / ⚠️ NEEDS REVIEW]

### Feature / Environment Flags

- [x] No feature-flag or environment conditionals detected
OR
- [ ] **Feature-flag / environment conditionals detected**
  - Location: [file:line]
  - Purpose: [reason]
  - Removal plan: [issue number]

### UAT Recommendations

- [ ] [Specific test steps based on what changed]
- [ ] Test on DESKTOP viewport (if applicable)
- [ ] Test on MOBILE viewport (if applicable)

### UX Audit

- [x] **No UI changes in this PR** (skip this section)
OR
- [ ] **UI changes detected** — UX audit [recommended | required]
  - Changed routes: [list affected pages/routes]
  - Safety-critical UI: [yes/no — details]
  - Suggested command: `/ux-audit <url> --mobile`

### Decision: [✅ APPROVE / ⚠️ CONDITIONAL / ❌ REQUEST CHANGES / 🚫 FAIL]

[Brief justification for the decision]
```
