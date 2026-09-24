# Messaging testing policy

Load this policy when a feature produces or consumes events. Load the companion
skill at `.agents/skills/messaging-testing/SKILL.md` for test-case design and
execution planning.

Messaging verification is `Required` only when the feature contract or
architecture promises producer, consumer, event, outbox, ordering, retry, or
broker behavior. If it is required, missing broker tooling, fixtures, or runtime
evidence is `BLOCKED`; it is not a scope exemption. If the feature has no
messaging behavior, record `Not required` with a feature-specific reason.

The plan must identify the event version, producer/consumer, topic, key and
partition policy, schema, required metadata, correlation identity, business
effects, delivery policy, retry/acknowledgment behavior, poison-message
handling, dead-letter behavior, ordering, and deduplication when implemented.

Evidence must distinguish transport delivery from business effects. A mocked
producer does not prove broker publishing, and broker transactions alone do not
prove atomicity with a database. Negative event claims must include a bounded
observation window. Required claims need observable receipts and safe source
identity in the standard evidence format.
