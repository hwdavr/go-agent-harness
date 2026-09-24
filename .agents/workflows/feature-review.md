---
description: Independently review a completed backend change before merge.
---

# Workflow: Feature review

Review from observable evidence, not from the implementer’s summary.

1. Read the approved spec, implementation plan, test plan, and summary. Treat
   missing artifacts as a handoff finding.
2. Inspect the diff for architecture, SQL/transaction, ownership, API
   compatibility, logging, migration, and error-mapping risks.
3. Run `make check`; run `make test-integration` for database-scoped claims.
4. Verify each acceptance criterion and each `Required` rule row. A skipped or
   unavailable runtime is not a pass.
5. Write `code_review_v<N>.md`, `test_review_v<N>.md`, and the evaluator rubric
   in the reviewed feature's `docs/product/YYYY-MM-DD-feature/` workspace using
   the supplied templates. Stop and present findings; the user decides whether
   accepted findings need a fix.
