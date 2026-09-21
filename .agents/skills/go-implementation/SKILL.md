# Go implementation skill

Use this during the implementation stage after the approved plan is on disk.

1. Trace the existing route, handler, service, repository, model, and OpenAPI
   contract before editing.
2. Implement one vertical slice at a time and preserve the existing error and
   JSON conventions.
3. Keep transport code thin and put validation, authorization, conflict, and
   mutation rules in the domain service.
4. Add or update focused tests before broad verification. Keep fixtures
   deterministic and secrets-free.
5. Run `gofmt` on changed Go files and finish with `make check`.

Do not refactor unrelated legacy code while delivering a scoped feature.
