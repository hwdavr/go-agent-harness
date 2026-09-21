# API contract rules

- `openapi.yaml` is the public HTTP source of truth.
- Route paths, verbs, auth requirements, request fields, response fields, and
  status codes must match the router and handlers.
- Every new or changed operation has a stable `operationId` and documents
  success plus expected 4xx responses.
- Keep JSON names in camelCase and preserve omission/null semantics.
- Do not expose database-specific errors, SQL fragments, JWT claims, or stack
  traces in API responses.
- Contract changes include a focused handler test and a client-facing scenario
  or an explicit documented reason no client scenario is applicable.
