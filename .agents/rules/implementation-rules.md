# Backend implementation rules

- Use `gofmt`, standard library types, and explicit error handling.
- Accept `context.Context` at every I/O boundary and honor cancellation.
- Prefer small interfaces at the consumer boundary. Do not introduce a mock
  framework when a small hand-written fake or `httptest` server is sufficient.
- Validate and normalize user input at the domain boundary; do not rely on a
  handler to protect domain callers.
- Use parameterized SQL only. Never interpolate user input into SQL, shell
  commands, log formats, or file paths.
- Preserve API compatibility intentionally. If a response or status changes,
  update OpenAPI and the affected client scenario in the same change.
- Use sentinel/domain errors for expected cases and wrap unexpected errors with
  context while preserving `errors.Is` behavior.
- Keep generated code changes separate from hand-authored logic where possible.
- Do not hide failures with broad test skips, ignored errors, or `|| true` in
  quality gates.
- Do not add deployment, destructive database, or credential-rotation commands
  to the harness without explicit user authorization.
