# Optional idempotency test planning

Load when an endpoint/consumer promises safe retries or deduplication. This is an
operation-level contract, not a guarantee for every endpoint. HTTP retries need no Kafka.

## Declare the operation contract

Record key extraction and scope (such as tenant/operation), request fingerprint,
duplicate/in-flight/conflict responses, retention/expiry, persistent deduplication,
completion point, and expected business/downstream effect counts. A fixed HTTP
status or identical replay response is required only if specified. For consumers,
declare whether the identity is an event ID or a business key.

| Scenario | Related observable assertions |
| --- | --- |
| Same identity/key/payload repeated | Permitted responses, expected business mutation and downstream/event effect counts. |
| Same key, different fingerprint | Declared conflict policy and no unintended mutation/effect. |
| Different keys/identity scopes | Independence according to the declared scope. |
| Lost response after commit, retry | Contract-defined result recovery; no unintended repeated mutation. |
| Restart, retry | Durable deduplication survives restart when promised. |
| Failure while in progress | Recovery policy; no unintended partial or duplicate state. |
| Consumer redelivery | Expected business effects despite repeated delivery; acknowledgment-failure recovery where relevant. |
| Key expiry | Declared retention behavior using controlled time or deterministic setup. |

Use real isolated persistence for persistence claims. Assert result identity/state,
row/business counts, and relevant external/event effects; matching
HTTP responses alone is insufficient. A controlled external receiver can count
attempts but does not prove actual downstream deduplication; record that boundary.
Separate transport duplicates from duplicate business effects.

Use deterministic hooks for relevant failure points: before mutation,
after commit before response/publish, after processing before acknowledgment.
DB and broker atomicity require a real recovery mechanism and its tests. Bound
waits and avoid long expiry sleeps.

Map requirement → scenario → assertions → command → evidence. Missing required
tests/probes/runtime are `BLOCKED`; absence of an idempotency guarantee can be
`NOT_APPLICABLE` with a reason. Do not retrofit business behavior merely to satisfy
this generic checklist.
