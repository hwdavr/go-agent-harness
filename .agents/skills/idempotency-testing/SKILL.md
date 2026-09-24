---
name: idempotency-testing
description: Plan deterministic HTTP or consumer retry and duplicate-suppression verification when a feature promises idempotency.
---

# Idempotency testing

Use this procedure only after the feature requirements matrix marks idempotency
`Required`. Read the Idempotency section in `testing-strategy.md` and
`docs/product/project-capabilities.json` first. This skill plans verification;
it does not retrofit business behavior, install infrastructure, or create
application tests by itself.

## Procedure

1. Declare the operation contract: key extraction and scope, request
   fingerprint, duplicate/in-flight/conflict responses, retention/expiry,
   persistent deduplication, completion point, and expected business,
   downstream, and event effect counts. For consumers, identify whether the
   identity is an event ID or business key.
2. Select only cases promised by that contract:

   | Scenario | Required observable assertions |
   | --- | --- |
   | Same identity/key and payload repeated | Permitted responses and expected business mutation/downstream/event effect counts. |
   | Same key with a different fingerprint | Declared conflict policy and no unintended mutation/effect. |
   | Different keys or identity scopes | Independent operations according to the declared scope. |
   | Response lost after commit, then retry | Contract-defined result recovery with no repeated business mutation. |
   | Restart, then retry | Durable deduplication survives restart when promised. |
   | Failure while in progress | Recovery policy with no unintended partial or duplicate state. |
   | Consumer redelivery | Expected business effects despite repeated delivery and acknowledgment-failure recovery where relevant. |
   | Key expiry | Declared retention behavior using controlled time or deterministic setup. |

3. Prefer real isolated persistence for persistence claims. Assert result
   identity/state, row or business counts, and relevant external/event effects.
   A matching HTTP response alone is insufficient. A controlled receiver can
   count attempts but does not prove downstream deduplication; record that
   boundary.
4. Use deterministic failure hooks at relevant points: before mutation, after
   commit before response or publish, and after processing before
   acknowledgment. Bound waits and avoid long expiry sleeps. Database-plus-
   broker atomicity requires a real recovery mechanism and its own evidence.
5. Map requirement → scenario → assertions → command or selector → evidence.
   Missing required tests, probes, or runtime are `BLOCKED`; dependent gates
   are `NOT_RUN`. Do not generate cases for behavior the contract does not
   promise.
