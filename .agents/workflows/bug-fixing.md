---
description: Reproduce, plan, fix, and verify a backend defect.
---

# Workflow: Bug fixing

Use this for a bug, regression, security defect, or failing test. Do not patch
the symptom before proving the failure.

1. Create `workspace=docs/product/YYYY-MM-DD-feature/`. Create
   `implementation_plan_v<N>.md`, `test_plan_v<N>.md`, and `summary_v<N>.md`.
   Capture expected versus actual behavior, affected code, and the root-cause
   hypothesis in the implementation plan.
2. Add a focused reproduction test and run it RED. Record the exact command and
   failure in the implementation plan and summary. If the defect cannot be reproduced,
   surface that fact instead of claiming a fix.
   Add a `## Reproduction` section to the implementation plan, then run
   `bash harness/scripts/check-stage-artifacts.sh bug-fixing bug-reproduction "$workspace"`.
3. Complete the implementation plan with the root cause, minimal fix, and
   regression evidence. Complete the test plan with the feature requirements
   matrix and generated required cases. Stop for user approval before changing
   production code.
   Use the test-plan template and project capability profile for selectors,
   optional messaging/idempotency rules, fixtures, and missing evidence. Derive
   the test requirements matrix from the defect's expected/actual behavior, then
   generate the exact regression and related cases for its Required rows.
   Run `bash harness/scripts/check-stage-artifacts.sh bug-fixing implementation-plan "$workspace"`.
4. Implement the minimal fix, rerun the failed scenario and directly related
   tests, then revalidate mandatory static/unit gates for the changed source
   before proceeding to component/integration and broader regression. Run
   `make check` at handoff. Stop progression on failure; preserve receipts with
   safe expected/actual details using `harness/verification-evidence.md`.
   Missing required tests/runtime are BLOCKED, never a passing fix. Do not
   weaken tests unless requirements changed or the test is demonstrably wrong.
5. Record the regression test and any remaining risk in `docs/changes/`.
