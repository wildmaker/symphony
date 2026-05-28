# Learning

Reusable lessons only. Add a lesson when it is actionable, likely to recur, and has a concrete trigger and check.

## Orders

Compact priority index. Keep sorted by priority, then recurrence.

Format:

```md
- <Lesson title> [count] {domain} {severity}
```

Domains can include: coding, testing, build, generated-code, tool-harness, API, architecture, UI, data, security, performance, docs.

Severity:

- `high`: correctness, build, data loss, security, release, or major regression risk.
- `medium`: behavior drift, flaky tests, maintainability, integration failure.
- `low`: style, clarity, small local convention.

## Refinements

Expanded rule bodies keyed by titles in `Orders`.

```md
## <Lesson title>

- Domain:
- Scope:
- Trigger:
- Rule:
- Anti-pattern:
- Why:
- Check:
- Evidence:
- Last seen:
- Confidence:
```

## Candidates

Raw lessons not yet promoted. Promote only after confirming reuse value.

```md
## <Candidate title>

- Episode:
- Symptom:
- Fix:
- Why this may recur:
- Proposed check:
```

## Scoring

Use this simple model when ordering lessons:

```text
priority = recurrence + severity + blast_radius + preventability + freshness - narrowness_penalty
```

Rules:

- Increment `[count]` when a lesson is rediscovered or reused.
- Promote high-severity lessons even before recurrence when they have a clear check.
- Merge duplicates under the clearest title and preserve the strongest check.
- Rewrite a refinement when one title hides multiple rules.
- Move stale lessons to `Retired` with a reason.

## Retired

Lessons no longer applicable, kept to prevent accidental revival.
