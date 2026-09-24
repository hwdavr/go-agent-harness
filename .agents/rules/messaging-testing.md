# Optional messaging and Kafka test planning

Load when a project produces/consumes events or a change affects messaging.
This is reusable guidance, not a Kafka installation or executable suite. Notes
App does not declare Kafka support. Required future messaging checks need an
implementation plan; missing brokers/tests cannot become a scope exemption.

## Declare the contract

Record event version, producer/consumer, topic, key/partition policy, required
metadata, schema/registry if used, correlation identity, business effects, and
delivery policy. Specify retries, acknowledgment/offsets, poison-message handling,
dead-letter routing, ordering, and deduplication only where implemented.

| Scenario | Related observable assertions |
| --- | --- |
| Successful publish | Topic, key, type, payload/schema, metadata, correlation, expected business state. |
| Rejected/rolled-back operation | Expected state/error and no unintended event within a documented window after a known completion point. |
| Successful consume | Expected DB/business changes, applicable acknowledgment/offset outcome, downstream events. |
| Invalid event | Declared rejection/retry/dead-letter policy, no unintended mutation, safe diagnostics. |
| Duplicate/redelivery | Contract-defined business effect counts; load idempotency rules where promised. |
| Processing/broker failure | Bounded retries/timeouts, recovery/errors, no unintended partial or duplicate state. |
| Ordering/transactions/outbox | When required: ordering scope, commit/abort visibility, recovery across DB/event failure boundaries. |

Broker transactions do not by themselves establish DB-plus-event atomicity.
That claim requires an implemented coordination mechanism and failure evidence.
Assert business effects separately from transport deliveries; repeated delivery
is not automatically a defect.

## Determinism and isolation

Prefer disposable real Kafka with pinned broker/client versions, unique topics
and consumer groups, readiness, bounded waits, and cleanup. Configure transaction
and replication settings for the claim; local single-broker tests do not prove
production failover/durability. Record mocked boundaries for unit/failure tests.

Establish observing-consumer readiness before the trigger when needed. Use
correlation IDs and processing signals; collect safe event assertion receipts.
Negative event evidence must state its observation window, not claim proof that
no event will ever arrive. A mocked producer does not prove broker publishing.
Unavailable required broker checks are `BLOCKED`; dependent gates are `NOT_RUN`.
Do not start/install Kafka for projects without messaging requirements. New
adapters, example services, and suites are separate implementation work.
