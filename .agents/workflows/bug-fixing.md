---
description: Reproduce, plan, fix, and verify a backend defect.
---

# Workflow: Bug fixing

Use this for a bug, regression, security defect, or failing test. Do not patch
the symptom before proving the failure.

1. Create `workspace=docs/product/YYYY-MM-DD-feature/`. Capture expected
   versus actual behavior and localize the fault in `spec_v<N>.md` there.
2. Add a focused reproduction test and run it RED. Record the exact command and
   failure in the spec and summary. If the defect cannot be reproduced,
   surface that fact instead of claiming a fix.
3. Write `implementation_plan_v<N>.md` in the same workspace with the root
   cause, minimal fix, and regression evidence. Stop for user approval before
   changing production code.
4. Implement the minimal fix, then run the reproduction GREEN, the relevant
   package tests, and `make check`.
5. Record the regression test and any remaining risk in `docs/changes/`.
