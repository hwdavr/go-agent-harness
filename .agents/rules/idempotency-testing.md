# Idempotency testing policy

Load this policy when an endpoint or consumer promises safe retries,
duplicate suppression, or durable replay behavior. Load the companion skill at
`.agents/skills/idempotency-testing/SKILL.md` for test-case design and execution
planning.

Idempotency is `Required` only for the operation and retry guarantees stated in
the feature contract. If it is required, missing persistence, failure-injection,
or runtime evidence is `BLOCKED`. If the contract makes no idempotency promise,
record `Not required` with a feature-specific reason; do not infer a
guarantee from a generic checklist.

The plan must identify key extraction and scope, request fingerprint,
duplicate/in-flight/conflict responses, retention or expiry, persistence,
completion point, and expected business, downstream, and event effect counts.
Consumer identity must be explicit, such as event ID or business key.

Matching HTTP responses alone do not prove idempotency. Evidence must assert
observable state and effect counts, distinguish transport duplicates from
business duplicates, use deterministic failure points, and record real versus
mocked boundaries.
