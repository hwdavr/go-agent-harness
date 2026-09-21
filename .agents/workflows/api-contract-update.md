---
description: Safely change the backend API contract shared with NotesTakingApp clients.
---

# Workflow: API contract update

Use this whenever a public path, method, request, response, status, or auth
requirement changes.

1. Read `api-contract.md`, the relevant OpenAPI section, router, handler, and
   client scenario.
2. Write a spec with compatibility impact and a complete Rule Applicability
   table. Identify whether the change is additive, behavior-preserving, or
   breaking.
3. Write and obtain approval of the implementation/test plan before changing
   code when the change is non-trivial.
4. Update OpenAPI, handler/domain implementation, and focused contract tests in
   one vertical slice. Keep JSON naming and error semantics explicit.
5. Run `bash harness/scripts/check-openapi.sh` and `make check`. Record the
   contract receipt in the summary.
