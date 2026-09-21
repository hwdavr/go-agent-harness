# Backend testing strategy

## Test pyramid

```text
       HTTP / database boundary tests
      Domain and repository integration tests
             Domain unit tests
```

Start at the lowest layer that proves the behavior. Do not replace a required
PostgreSQL or HTTP boundary with a mock-only test.

## Test layers

- **Unit tests** (`*_test.go`): validation, conflict decisions, mappers, error
  mapping, and pure domain behavior. They must be deterministic and not need
  Docker or Auth0.
- **HTTP tests**: use `httptest` with real routers and deterministic fake
  services where the handler boundary is the claim. Assert status, headers,
  and response fields—not only that a request returned.
- **Integration tests**: use PostgreSQL 16 from
  `build/docker-compose.test.yml` and the real repository/migrations. Mark
  them with `//go:build integration` and run them with `make test-integration`.
- **Contract tests**: every changed public endpoint keeps `openapi.yaml` and
  client scenarios aligned. Record request method/path/status receipts.

## Evidence rules

- A passing command must exit zero and execute a non-zero test count when it is
  a test command.
- A missing database, skipped test, or live Auth0 dependency is `Blocked`, not
  passing evidence.
- Integration tests must use a disposable database and deterministic fixtures;
  never point them at a developer or production database.
- Tests must not print access tokens, note bodies, emails, or connection URLs.

## Coverage and regression policy

New domain behavior must include unit tests. New persistence behavior must
include an integration test or a documented reason it can be proven without a
database. Every bug fix includes a regression test. Coverage is reported with
the standard Go tooling when a feature plan sets a numeric target.
