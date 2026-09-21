# Rule Applicability

Every spec must decide every row using exactly `Required`, `Not applicable —
<feature-specific reason>`, or `Exception — approved by <user/date>`.

| ID | Rule | Decision | Evidence / reason |
| --- | --- | --- | --- |
| ARCH | Layer boundaries and dependency direction |  |  |
| API | OpenAPI and client contract |  |  |
| DB | Persistence and transaction semantics |  |  |
| MIG | Migration and rollback safety |  |  |
| TEST | Unit, HTTP, and integration tests |  |  |
| SEC | Authentication, authorization, and data handling |  |  |
| OBS | Logging, errors, and operational signals |  |  |
| PERF | Query and runtime performance |  |  |
| DEP | Dependency and build reproducibility |  |  |
| DOC | Documentation and delivery records |  |  |
