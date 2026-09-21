# Go testing skill

Choose the lowest test layer that proves the behavior. Use `httptest` for real
router/handler behavior, hand-written fakes for service seams, and the
disposable Postgres compose file for repository semantics that SQL must prove.

Tests must assert meaningful fields and status/error behavior. Avoid sleeps,
live Auth0 calls, shared developer databases, time-dependent assertions without
a tolerance, and tests that pass when zero cases execute.

Record the exact command, exit code, and test count in the active summary when a
workflow requires evidence.
