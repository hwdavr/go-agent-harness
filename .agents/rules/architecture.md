# Backend architecture rules

## Dependency direction

```text
cmd/server → http/handlers → domain service → repository → db/models → PostgreSQL
                  ↑
              middleware
```

`cmd/server` is the composition root. The current repository implementation is
kept in `internal/domain` for compatibility with the existing service; new
code must still keep its SQL behind repository methods and must not widen that
boundary into handlers or middleware.

## Layer responsibilities

### Transport (`internal/http` and `internal/http/handlers`)

- Parse and validate HTTP input shape.
- Read authenticated identity from request context.
- Call domain methods and map domain errors to stable HTTP responses.
- Own routing, CORS, authentication middleware, and transport logging.

Transport code must not import generated database models, build SQL strings, or
implement ownership, conflict, sharing, or persistence rules.

### Domain (`internal/domain`)

- Own domain models, validation, ownership/access decisions, conflict rules,
  and mutation semantics.
- Keep repository calls behind named methods with domain-level inputs and
  outputs.
- Return stable sentinel errors that handlers can map consistently.

### Persistence (`internal/domain` repository and `internal/db`)

- Own SQL, Bob query construction, transactions, and database row mapping.
- Keep generated Bob models inside the persistence boundary.
- Use context-aware database operations and return errors without leaking SQL
  or connection details to clients.

### Startup and configuration (`cmd/server`, `internal/config`, `internal/db`)

- Wire dependencies in one place.
- Read configuration from the environment with safe defaults only where the
  service already defines them.
- Fail closed when a required value such as `DATABASE_URL` is absent.

## Forbidden dependencies

- `internal/http/handlers` → `internal/db/models`, `database/sql`, Bob, or raw SQL.
- `internal/domain` service logic → `internal/http` or HTTP status codes.
- `internal/db/models` → handlers or domain services.
- `internal/pkg` → application feature packages unless the dependency is an
  explicit, documented boundary.

Run `bash harness/scripts/check-go-rules.sh` to enforce the mechanically
checkable subset. Reviewers still own semantic boundary and transaction review.
