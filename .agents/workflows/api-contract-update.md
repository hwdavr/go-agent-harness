---
description: Safely change the backend API contract shared with NotesTakingApp clients.
---

# Workflow: API contract update

Use this whenever a public path, method, request, response, status, or auth
requirement changes.

1. Read `api-contract.md`, the relevant OpenAPI section, router, handler, and
   client scenario.
2. Create `workspace=docs/product/YYYY-MM-DD-feature/`. Write a spec there
   with compatibility impact and a complete Rule Applicability table. Identify
   whether the change is additive, behavior-preserving, or breaking.
3. Write and obtain approval of the implementation/test plan in the same
   workspace before changing code when the change is non-trivial.
   Identify the contract baseline and tools for static compatibility and actual
   response conformance separately. Use the Go testing skill to complete the
   feature requirements matrix and generate the required contract test cases.
4. Update OpenAPI, handler/domain implementation, and focused contract tests in
   one vertical slice. Keep JSON naming and error semantics explicit.
5. Follow static → targeted unit → component/API → affected integration →
   regression, stopping after mandatory failure. Run
   `bash harness/scripts/check-openapi.sh` and `make check` as applicable source
   gates, but do not call the path-string check schema compatibility or runtime
   validation. Execute the planned contract tools/scenarios; missing required
   verification is BLOCKED. Record baseline, commands, counts, and actual
   assertions using `harness/verification-evidence.md` in the summary.
