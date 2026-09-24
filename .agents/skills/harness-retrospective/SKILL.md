---
name: harness-retrospective
description: Repair harness workflow, gate, fixture, or evidence failures without changing backend application behavior.
---

# Harness Retrospective

## Purpose

Repair the backend harness when it allows incorrect evidence, hides unavailable
environments, or fails to catch a recurring workflow defect. Preserve the Go
application and OpenAPI contract while making the harness detect the problem
earlier and fail clearly.

## Scope Boundary

Work only on harness-environment concerns:

- `.agents/workflows/` and `.agents/rules/` instructions;
- `harness/templates/` and harness artifact schemas;
- `harness/scripts/` validators, environment probes, and contract tests;
- test fixtures that validate harness behavior; and
- `docs/knowledge/pitfalls/` and `docs/changes/` audit records.

Do not fix or reinterpret:

- Go application source defects, domain behavior, SQL queries, migrations, or
  API feature implementation;
- Auth0, Docker, PostgreSQL, or other external-service limitations; or
- lifecycle status transitions, feature selection, or implementation
  authorization.

If the root cause is outside the scope boundary, classify it, document the
evidence, and stop the repair. Improve only harness detection and handoff when
that is independently useful.

## Root-Cause Classification

Classify before editing. Use exactly one primary classification:

| Classification | Meaning | Skill action |
| --- | --- | --- |
| `HARNESS_ENVIRONMENT` | A workflow, gate, validator, fixture, environment probe, or evidence rule allowed a false pass or misleading result. | Repair and regression-test the harness. |
| `WORKFLOW_GAP` | The correct rule exists nowhere or is not attached to the required stage. | Add it to the authoritative workflow, template, or gate and test enforcement. |
| `TEST_EVIDENCE_GAP` | The test runner or evidence schema cannot prove the required HTTP, PostgreSQL, OpenAPI, or authentication boundary. | Add a mechanical evidence requirement; do not implement product behavior. |
| `SPEC_GAP` | Expected backend behavior or acceptance criteria are ambiguous, conflicting, or absent. | Repair the versioned spec, implementation plan, and test plan; then re-validate downstream artifacts. |
| `EXTERNAL_CAPABILITY` | Docker, PostgreSQL, Auth0, a required service, or the runtime environment cannot provide the requested capability. | Stop; route to an environment, product, or architecture decision. Add only fail-loud diagnostics if needed. |
| `APPLICATION_DEFECT` | The harness correctly exposed a defect in shipped backend behavior. | Stop; route to the application bug-fixing workflow. |

Never relabel an `EXTERNAL_CAPABILITY` or `APPLICATION_DEFECT` as a harness
issue just to keep working.

## Workflow

### 1. Orient and preserve state

1. Read `AGENTS.md`, `.agents/rules/architecture.md`, and
   `.agents/rules/testing-strategy.md` (skip only if already loaded this
   session).
2. Read the workflow, rule, template, or validator named by the incident in
   full before editing.
3. Run `bash harness/scripts/check-feature-lifecycle.sh` only when the
   incident concerns multi-slice work. Do not change the tracker or select a
   feature slice.
4. Collect the smallest raw evidence set: failing command, exit code, relevant
   log, artifact path, and the harness rule that should have caught it.
5. Check `git status --short` and preserve unrelated user changes.

### 2. Reproduce the harness failure

Create or identify a minimal fixture that demonstrates the incorrect behavior.
Prefer a contract test over an informal manual check.

The fixture must make the failure observable, for example:

- missing integration-test files are accepted;
- unavailable Docker or PostgreSQL is reported as passing;
- a mocked repository is accepted as the only evidence for a required
  PostgreSQL boundary;
- a route/OpenAPI mismatch is accepted by a contract check; or
- a validator reports a misleading error before reaching the intended
  assertion.

Do not alter application code to make the fixture pass.

### 3. Define the invariant

Write the intended invariant in one sentence before patching. Examples:

- “A required runtime that was not executed cannot produce passing evidence.”
- “A persistence claim requires a disposable PostgreSQL integration test; a
  mock-only test is supplemental.”
- “A public router operation must be represented consistently in the OpenAPI
  contract.”
- “A contract fixture must reach the condition it claims to test.”

The invariant must be enforceable by a script, test, or required artifact—not
only by reviewer memory.

### 4. Patch the authoritative source

Make the smallest change that closes the gap at its source:

- update the workflow, rule, gate, schema, or template that allowed the
  failure;
- add or tighten the validator or environment probe that enforces the
  invariant;
- add a focused regression fixture or contract test that reproduces the old
  false pass and proves rejection now; and
- add a knowledge pitfall only when the lesson is reusable beyond the
  incident.

Use `apply_patch` for file edits. Do not add suppressions, exclusions,
warning-only paths, silent skips, or broad “best effort” fallbacks. Do not
modify product code, product requirements, external-service behavior, or
platform capabilities while acting as this skill.

### 5. Repair specification artifacts (`SPEC_GAP` only)

When the classification is `SPEC_GAP`, repair the active versioned artifacts
under `docs/current/` (or the relevant multi-slice workspace under
`docs/product/`):

1. **Specification** — clarify the ambiguous, conflicting, or absent
   acceptance criteria while preserving unrelated requirements.
2. **Implementation plan** — update impacted layers, sequencing, and scope to
   match the corrected specification.
3. **Test plan** — update the required HTTP, database, contract, and
   authentication evidence to match the corrected specification.

After repairing, verify internal consistency: every changed acceptance
criterion must trace to an implementation step and at least one planned test.
Flag any remaining product decision that requires user confirmation before
proceeding.

### 6. Enforce fail-loud environment behavior

For every required Docker service, PostgreSQL database, Auth0-compatible JWKS
server, external service, or runtime capability, require one of these
outcomes:

1. The check runs and exits successfully with observable, source-fed evidence;
   or
2. The check exits nonzero and records `Blocked` or `Revise` with the missing
   prerequisite.

Missing, skipped, warning-only, empty, mock-only, or unexecuted evidence must
never be recorded as passing. A product-approved fallback is allowed only when
it is explicitly represented in the test plan and covered by a test. Keep
unsupported environments diagnosable instead of converting them into green
results.

### 7. Validate the harness change

Run the narrowest relevant checks, then the project gates affected by the
change. Typical checks are:

```bash
bash -n <changed-shell-scripts>
bash harness/scripts/check-feature-lifecycle.sh
bash harness/scripts/check-stage-artifacts.sh <workflow> <stage>
bash harness/scripts/check-go-rules.sh
bash harness/scripts/check-openapi.sh
bash harness/scripts/check-migrations.sh
bash harness/scripts/tests/<relevant-contract-test>.sh
make check
make test-integration
git diff --check
```

Expected negative cases must be asserted as expected failures in a contract
test; do not hide them with `|| true` or suppress their output. Run Go unit,
integration, contract, or vet checks when the harness change affects that
gate's behavior. Otherwise, state explicitly that no application source
changed and why those gates were not relevant.

### 8. Record and hand off

Create `docs/changes/harness-retro-<YYYY-MM-DD>-<short-slug>/retrospective.md`
with:

- incident: trigger, observed evidence, and affected stage;
- classification and root cause;
- the invariant added;
- harness change: workflow/rule/gate, validator/template, and regression
  fixture;
- verification commands and results;
- routed items intentionally outside harness scope; and
- remaining risk.

Quote exact artifact paths and one-line excerpts so a reviewer can verify the
change. If the incident is an external capability or application defect, route
it clearly and leave the harness unchanged except for an independently
justified fail-loud diagnostic or handoff improvement.

## Completion Criteria

The retrospective is complete only when:

- the failure has an explicit root-cause classification;
- the authoritative workflow, rule, gate, template, or validator is minimally
  repaired;
- a regression fixture proves the old false pass is rejected;
- required unavailable environments cannot pass silently;
- `SPEC_GAP` repairs are reflected consistently across the specification,
  implementation plan, and test plan;
- out-of-scope external and application concerns are routed rather than
  “fixed” here;
- relevant validators and contract tests pass, including expected negative
  cases; and
- the retrospective artifact records commands, results, paths, excerpts, and
  remaining risk while the working tree and lifecycle state remain accurate.
