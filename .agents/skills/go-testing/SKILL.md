# Go testing skill

Read `testing-strategy.md` and `docs/product/project-capabilities.json` before
selecting verification. The profile is a project-wide tooling inventory; it does
not decide the test needs of a feature.

## Prepare a feature test plan

1. Derive the feature verification requirements matrix from the feature spec and
   acceptance criteria. Mark each verification type `Required` or `Not required`
   with a feature-specific reason.
2. Generate concrete test cases for every Required row. Each case needs a matrix
   row, acceptance criterion, scenario/assertions, and exact command/selector.
   Every generated case is required evidence for the feature.
3. Use changed packages and affected dependents to choose the smallest relevant
   tests. Expand to component, integration, or regression only when a Required
   row needs that evidence. Record unavailable required tooling as `BLOCKED`.
4. When idempotency is Required, load `idempotency-testing.md` and generate only
   cases promised by that operation's retry contract. When messaging is Required,
   load `messaging-testing.md`.

Keep these instructions out of the test-plan artifact. The artifact records only
the completed requirements matrix and generated cases. Stop after an earlier
mandatory failure; broader suites belong at final regression.

Load `messaging-testing.md` for producer/consumer changes and
`idempotency-testing.md` for declared HTTP/consumer retry guarantees. These are
planning rules, not installed broker adapters or suites. Do not implement tests
or infrastructure when the task only requests harness environment configuration.

Choose the lowest test layer that proves the behavior. Use `httptest` for real
router/handler behavior, hand-written fakes for service seams, and the
disposable Postgres compose file for repository semantics that SQL must prove.

Tests must assert meaningful fields and status/error behavior. Avoid sleeps,
live Auth0 calls, shared developer databases, time-dependent assertions without
a tolerance, and tests that pass when zero cases execute.

Record the exact command, exit code, and test count in the active summary when a
workflow requires evidence.

Use the structured evidence template and `harness/verification-evidence.md` for
source identity, real/mocked boundaries, assertion outcomes, and repair receipts.
Required absent/skipped/zero-test verification is BLOCKED. Preserve failed
evidence; rerun the failed/related scenarios and earlier mandatory gates for new
source before continuing. Only change tests for changed requirements or a proven
test defect.
