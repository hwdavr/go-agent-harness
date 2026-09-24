---
name: messaging-testing
description: Plan deterministic Kafka or event producer and consumer verification when a feature requires messaging behavior.
---

# Messaging testing

Use this procedure only after the feature requirements matrix marks messaging
`Required`. Read the Messaging section in `testing-strategy.md` and
`docs/product/project-capabilities.json` first. This skill plans verification;
it does not install Kafka, add adapters, or create application tests by itself.

## Procedure

1. Declare the event contract: version, producer or consumer, topic, key and
   partition policy, schema or registry, required metadata, correlation
   identity, business effects, and delivery policy.
2. Record implemented retry, acknowledgment/offset, poison-message,
   dead-letter, ordering, deduplication, transaction, and outbox behavior. Do
   not plan cases for guarantees the feature does not promise.
3. Select only the scenarios that cover the contract:

   | Scenario | Required observable assertions |
   | --- | --- |
   | Successful publish | Topic, key, type, payload/schema, metadata, correlation, and expected business state. |
   | Rejected or rolled-back operation | Expected state/error and no unintended event within a documented observation window. |
   | Successful consume | Expected database/business changes, acknowledgment/offset outcome, and downstream events. |
   | Invalid event | Declared rejection/retry/dead-letter policy, no unintended mutation, and safe diagnostics. |
   | Duplicate or redelivery | Contract-defined business-effect counts; load idempotency skill when promised. |
   | Processing or broker failure | Bounded retries/timeouts, recovery/error behavior, and no unintended partial or duplicate state. |
   | Ordering, transactions, or outbox | Only when required: ordering scope, commit/abort visibility, and recovery across database/event failure boundaries. |

4. Prefer disposable real Kafka with pinned broker/client versions, unique
   topics and consumer groups, readiness checks, bounded waits, and cleanup.
   Configure transaction and replication settings for the claim. A local
   single-broker test does not prove production failover or durability.
5. Establish an observing consumer before the trigger when needed. Use
   correlation IDs and processing signals. Record mocked boundaries for unit or
   failure-injection cases.
6. Map each selected requirement to a scenario, assertions, exact command or
   selector, environment, and structured evidence. Required broker checks that
   cannot run are `BLOCKED`; dependent gates are `NOT_RUN`.

## Evidence limits

Assert business effects separately from transport deliveries. Repeated delivery
is not automatically a defect. Negative event evidence must state its bounded
observation window and must not claim that no event can ever arrive.
