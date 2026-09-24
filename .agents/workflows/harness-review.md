---
description: Review an approved complex feature after all harness-generated slices are complete.
---

# Workflow: Harness review

Review the parent plan and the aggregate evidence from every generated slice.
This workflow is only for a complex feature created by `harness-planning.md`.

1. Read the approved parent `spec_v<N>.md`, `implementation_plan_v<N>.md`,
   `test_plan_v<N>.md`, and `feature_list.json`. Read every
   `summary_<slice-id>.MD` in the dated feature workspace. Treat a missing
   parent artifact or slice summary as a handoff finding. Confirm every slice is
   `passing`, every dependency is satisfied, and the lifecycle checker passes:
   `bash harness/scripts/check-feature-lifecycle.sh`.
2. Compare the feature list with the parent artifacts. Confirm every parent
   `REQ-*`, `AC-*`, and Required test case ID is assigned to one or more slices;
   every slice summary matches its approved scope and IDs; dependencies have no
   cycle; and no slice claims unapproved scope.
3. Inspect the aggregate diff and each slice's evidence for architecture,
   contract compatibility, SQL/transaction behavior, ownership, logging,
   migration, and error-mapping risks. Check that slice boundaries preserve
   the approved dependency order.
4. Review the parent test-plan matrix and each mapped test case. Confirm the
   required static → unit → component/API → integration → regression gates were
   executed for applicable slices, mandatory failures blocked dependent gates,
   and evidence identifies the changed source and runtime. Missing required
   tests or unavailable runtime evidence is not a pass.
5. Verify every parent acceptance criterion and every Required parent rule row
   through observable slice evidence. Require actual assertions for contract,
   database, event, retry, and resilience claims; plans and templates alone are
   not evidence. Use `harness/verification-evidence.md` for status semantics.
6. Write `code_review_v<N>.md`, `test_review_v<N>.md`, and the evaluator rubric
   in the parent dated feature workspace using the supplied templates. Stop and
   present findings; the user decides whether accepted findings need a fix.
