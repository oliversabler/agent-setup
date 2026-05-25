---
name: review-this
description: Perform a deep code review of changes between two branches
---

# Review

Review diff between a fixed point the user provieds and `HEAD`. Do not proceed without the fixed point, ask until you have it.

## Workflow

### 1. Triage

Start by analyzing and triage the diff. Use General agent for this task.

- Run: `git diff <fixed-point>...HEAD --stat` for overview
- Run: `git diff <fixed-point>...HEAD` for full diff
- Run: `git log <fixed-point>...HEAD --oneline` for commit history

For each changed file, assess:
- **Risk**: logic changes, new control flow, error handling modifications
- **Complexity**: large diffs, many interdependencies, subtle state changes
- **Impact**: public API changes, database migrations, security-sensitive code

Prioritize logic changes over formatting/renaming.

Flag any changes to error handling, auth, or data validation.

Note if test coverage appears missing for new logic.

Structure the output as:

```markdown
# Triage
## Overview
- Branch: `feature/x` vs `develop`
- Commits: N commits, M files changed
- Lines: +X / -Y

## Focus Areas (ordered by review priority)

For each high-priority area:
- **File(s)**: path and line ranges
- **Why**: what changed and why it matters
- **Watch for**: specific things to verify

## Low-risk changes
- List files that are routine (tests, formatting, deps) and need less scrutiny
```

### 2. Act on triage findings

Read the entire high-priority file(s) being modified to understand the full context.

Code that looks wrong in isolation may be correct given surrounding logic—and vice versa.

Use Explore agent to find how existing code handles similar problems. Check patterns, conventions, and prior art before claiming something doesn't fit.

If you're uncertain about something and can't verify it with these tools, say "I'm not sure about X" rather than flagging it as a definite issue.

### 3. Analyze each focus area through these lenses:

**Bugs** - Your primary focus.
- Logic errors, off-by-one mistakes, incorrect conditionals
- If-else guards: missing guards, incorrect branching, unreachable code paths
- Edge cases: null/empty/undefined inputs, error conditions, race conditions
- Security issues: injection, auth bypass, data exposure
- Broken error handling that swallows failures, throws unexpectedly or returns error types that are not caught.

**Structure** - Does the code fit the codebase?
- Does it follow existing patterns and conventions?
- Are there established abstractions it should use but doesn't?
- Excessive nesting that could be flattened with early returns or extraction

**Performance** - Only flag if obviously problematic.
- O(n²) on unbounded data, N+1 queries, blocking I/O on hot paths

**Behavior Changes** - If a behavioral change is introduced, raise it (especially if it's possibly unintentional).

### 4. Present findings

```markdown
# Review
- Verdict: Approve / Request changes / Needs discussion
- Risk level: Low / Medium / High
- Key concerns (1-3 bullet points)

## Findings (ordered by severity)

For each finding:
- **Severity**: Critical / Warning / Suggestion
- **Category**: Correctness | Security | Performance | Design | Maintainability
- **Location**: `file_path:line_number`
- **Issue**: What's wrong
- **Suggestion**: How to fix (with code snippet if helpful)

## Positive observations
- Note well-written code, good patterns, thorough tests
```
