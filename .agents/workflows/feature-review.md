---
description: Independently review a completed backend change before merge.
---

# Workflow: Feature review

Review from observable evidence, not from the implementer’s summary.

1. Read the approved spec, implementation plan, test plan, and summary. Treat
   missing artifacts as a handoff finding.
2. Inspect the diff for architecture, SQL/transaction, ownership, API
   compatibility, logging, migration, and error-mapping risks.
3. Inspect the project-wide capability inventory and the separate feature-wise
   Required/Not required matrix. Confirm the latter traces to feature acceptance
   criteria and every Required row has generated test cases. Review selectors, optional
   messaging/idempotency decisions, and evidence source identity. Verify ordered gate
   execution and stop on mandatory failure. Run `make check` and planned runtime
   checks for relevant claims; confirm isolation before `make test-integration`.
4. Verify each acceptance criterion and each `Required` rule row. A skipped or
   unavailable runtime is not a pass. Require actual assertions for contract,
   DB, event, and retry claims; configuration declarations and templates alone
   are not executable evidence. Use `harness/verification-evidence.md` to
   distinguish failures, blocked requirements, and justified inapplicability.
5. Write `code_review_v<N>.md`, `test_review_v<N>.md`, and the evaluator rubric
   in the reviewed feature's `docs/product/YYYY-MM-DD-feature/` workspace using
   the supplied templates. Stop and present findings; the user decides whether
   accepted findings need a fix.
