# Test plan

## Feature context

- Request, issue, or feature reference:
- Parent spec (complex harness-planning only):
- Acceptance criteria source: implementation plan or parent spec

## Feature verification requirements matrix

Derive this matrix from this feature's acceptance criteria. The project profile
at `docs/product/project-capabilities.json` provides context about available
tools and gaps; it does not decide these rows.

For each verification type, write `Required` or `Not required — <feature-specific
reason>`. A required check that cannot run remains required and is recorded as
`BLOCKED` during execution. Every Required row must link to generated test cases.

| Verification type | Required for this feature? | Acceptance criterion(s) / reason | Generated test case ID(s) |
| --- | --- | --- | --- |
| Static quality checks | | | |
| Unit and business-rule tests | | | |
| Component/API behavior | | | |
| API contract checks | | | |
| Database state and constraints | | | |
| Transaction commit/rollback | | | |
| Kafka producer/consumer behavior | | | |
| Idempotency/retry behavior | | | |
| Dependency failure/resilience | | | |
| Broader regression | | | |

## Generated required test cases

Generate one or more concrete test cases for every Required matrix row. Every
test case listed here is required evidence for the feature. A single business
scenario may cover multiple matrix rows when it has related assertions.

When idempotency is Required, generate cases only for retry behavior promised by
the feature contract. Use `idempotency-testing.md` to determine the relevant
cases. Load `messaging-testing.md` when Kafka behavior is Required.

| ID | Matrix row(s) | Acceptance criterion | Scenario and required assertions | Exact command/selector |
| --- | --- | --- | --- | --- |
| | | | | |

For a complex feature, link the parent spec's required rule rows. For an ad hoc
feature or bug fix, record only the constraints triggered by this change.
