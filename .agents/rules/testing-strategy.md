# Backend development-loop testing strategy

## Objective and scope

Answer: “Is there sufficient deterministic evidence that the changed behavior is
correct?” Trace requirement → business scenario → implementation → observable
assertions → structured evidence. Run cheap relevant checks first. Release
performance, production security scans, deployment validation, and full-system
E2E are outside this loop.

This is agent workflow policy. Inspect `docs/product/project-capabilities.json` for
current executable checks and gaps. A declaration or plan does not implement a
test. The existing `make check` is a broad source gate, not an automated five-gate
runner. Required checks missing from current tooling must be planned and reported
truthfully, not assumed to pass.

## Ordered gates

| Gate | Applicable verification | Boundary |
| --- | --- | --- |
| 1 Static | Formatting/imports, forbidden dependencies, configured lint, `go build ./...`, `go vet ./...`, migration safety, static contract validity/compatibility | No integration environment. |
| 2 Unit | Changed-package then affected dependent-package tests; business rules, boundaries, negative cases | Deterministic; no external runtime. |
| 3 Component/API | Startup, happy path, API input/auth/errors, actual response contract conformance | Prefer real HTTP/application wiring; record in-process vs separate-process execution. |
| 4 Integration | Persistence, transactions, messaging, retries, and resilience when required | Only dependencies needed by selected scenarios. |
| 5 Regression | `go test ./...`, relevant broader integration suite, repository-required `make check` | After earlier applicable gates pass. |

A mandatory failure blocks subsequent gates. Record dependent gates as `NOT_RUN`;
do not start infrastructure after an earlier failure. Existing scripts may
aggregate checks; a final failure cannot authorize progression. Avoid broad suites
after every edit. Unavailable or unimplemented required verification is `BLOCKED`,
never `NOT_APPLICABLE`. The latter requires an explicit scope-based reason.

Run configured lint; do not silently disable it or presume another project's
linter is installed. Check formatting without rewriting source during validation.
Existing architecture scripts enforce only part of the rules; semantic review
and uncovered boundaries must remain explicit.

## Targeted selection

Record changed files/packages, affected dependents, scenario IDs, selectors, exact
commands, and the reason they cover the change in the versioned test plan.
Progress: changed package → dependents → affected integration → broad regression.
Explicit selectors are acceptable; do not claim automated selection when absent.
Shared configuration/schema/contracts, deleted files, or uncertain impact may
require broader selection; record why.

Use `go test -json -count=1 <packages> -run '<selector>'` for fresh test execution
evidence. Count tests and report skips; zero matching tests cannot prove a claim.
A package without tests is a coverage gap for a requirement that needs them.
Cached output is not fresh execution evidence. Integration selectors need the
project's build tags and isolated runtime setup.

## Unit and API scenario design

Test business rules primarily at their lowest layer: normal values, limits,
invalid inputs, transformations, transitions, and errors. Do not duplicate every
business boundary through HTTP. New domain behavior needs unit tests; every bug
fix needs regression evidence. Use numeric coverage thresholds only when planned.

API negatives focus on malformed JSON, missing fields, types/enums, auth,
permissions, missing resources, conflicts, and payload limits according to the
actual contract. Do not invent endpoint behavior from this checklist. One business
scenario can assert status/body, contract, DB state, audit, and events together.
Separate different behaviors: success, invalid input, unauthorized, duplicate,
dependency failure. Handler fakes prove only handler claims. Prefer running real
application wiring for component claims and describe the boundary accurately.

## Contracts

Separate static contract validity/compatibility from actual response conformance.
Record baseline revision and compatibility policy. Check removed/renamed fields,
changed types, required inputs, enums, and structures in their request/response
direction. Validate runtime responses against the chosen contract. A path-string
check is not schema compatibility or runtime validation. Missing required tooling
or baseline is blocked. Do not alter a contract simply to silence failing tests.

## Persistence, isolation, and mocks

Use real disposable persistence for DB claims. Scenarios own synthetic fixtures,
seed data, assert observable state, and clean up. No execution-order dependencies,
manual rows, shared mutable environments, or developer/production DB URLs. Require
bounded readiness/deadlines and cleanup. Isolate parallel runs and record the
environment identity. Notes App uses PostgreSQL 16 and `integration` build tags;
inspect its profile and existing Compose setup before running tests.

Assert applicable insert/update/delete, unchanged records, unique/foreign-key
constraints, and no unintended duplicates. Multi-write operations need successful
commit and injected-failure rollback scenarios showing no partial state. Do not
change production behavior solely to inject a failure.

Mocks suit unit seams, impractical third-party services, and failure injection.
Prefer real project-controlled PostgreSQL/Kafka/Redis for important integration
claims when those capabilities exist. Record every mocked boundary explicitly.

## Optional capabilities

Every test plan decides applicability for transactions, Kafka producers/consumers,
idempotency, and resilience. Absence of tests is not a reason to mark a required
capability irrelevant. Load only triggered additional rules:

- Messaging/Kafka: `messaging-testing.md`.
- HTTP/consumer retry guarantees: `idempotency-testing.md`.

### Idempotency cases to include in feature plans

When a feature promises safe retries or duplicate suppression, mark idempotency
Required in its requirements matrix. Generate a concrete test case with scenario,
command/selector, and expected result for each retry behavior the contract
promises. Do not generate cases for behavior the contract does not promise.

| Case | Expected observable result |
| --- | --- |
| Repeat the same key and request | Contract-defined responses; one intended business mutation/effect. |
| Reuse a key with different request data | Declared conflict behavior; no unintended additional effect. |
| Use distinct keys/scopes | Independent operations according to the key contract. |
| Retry after the response is lost | Recover the committed result without repeating the business effect. |
| Redeliver a message (consumer only) | Consumer contract holds; business-effect count is as specified. |
| Retry after restart (when durability is promised) | Deduplication survives restart. |
| Fail and retry (when recovery is promised) | Declared recovery without unintended partial or duplicate effects. |
| Expire a key (when specified) | Behavior follows the expiry contract using controlled time/setup. |

These are case-design guidance for the Go testing skill, not a second selection
table in the feature test plan.

For implemented resilience, inject relevant unavailability, timeout, 5xx, invalid
response, or connection loss; assert deadlines, declared retries/fallbacks,
controlled errors, rollback, and expected effect counts. Do not multiply every
failure across every endpoint.

## Evidence and repair

Use `harness/templates/verification-evidence-template.json` with the semantics in
`harness/verification-evidence.md`. This is a manual format, not an installed
collector/validator. Capture command, exit, counts, duration, source identity
(including working changes), selection, environment, and safe expected/actual
assertions. Link logs and likely affected code. Never log tokens, private data,
note bodies, emails, or raw connection URLs.

Failure → evidence → identify affected implementation → repair → rerun failed
scenario → related scenarios → earlier mandatory gates for the changed source
→ dependent gates. Focused reruns are diagnostic and cannot bypass mandatory
gates for completion. Old receipts cannot certify changed source. Change tests
only for changed requirements/specifications or a demonstrable test defect;
never automatically regenerate tests because implementation fails.

Final `PASS` needs executed evidence for all applicable mandatory claims. Required
skips, missing tests/runtime, and empty selections are not passing. Run `make check`
at handoff and additional planned runtime checks for claims it cannot establish.
