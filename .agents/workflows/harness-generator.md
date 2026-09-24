---
description: Deliver one approved slice from a parent multi-slice backend feature plan.
---

# Workflow: Harness generator

Use this only for a slice listed in a parent workspace created by
`harness-planning.md`. The parent plan is created and approved once; this
workflow does not create a second feature plan for each slice.

1. Read the parent `spec_v<N>.md`, `implementation_plan_v<N>.md`,
   `test_plan_v<N>.md`, and `feature_list.json`. Resolve exactly one slice:
   use a requested slice ID only when its status is `not_started` or `needs_fix`
   and every `depends_on` slice is `passing`; otherwise choose one slice with
   those same conditions whose numeric `priority` is lowest (break a tie by
   slice ID). Stop when no slice is ready. Confirm the selected slice has a
   non-empty `scope`, `requirement_ids`, `acceptance_ids`, and `test_case_ids`.
   Confirm every mapped ID exists in the parent artifacts.
2. Create `<workspace>/summary_<slice-id>.MD` from
   `harness/templates/slice-summary-template.md`, directly in the dated
   feature workspace. Copy the slice's approved
   scope, requirement IDs, acceptance IDs, test case IDs, and dependencies from
   the parent files. Record slice selection and mapping validation in its
   workflow record. Do not invent scope, requirements, or test cases.
3. Mark the slice `in_progress` in `feature_list.json`; set the parent tracker
   to `In Progress` if it is not already. Preserve unrelated slices.
4. Implement only the selected slice's approved scope and mapped requirements.
   Use the Go testing skill to run the parent test cases mapped to this slice in
   the required gate order. Update the slice summary as each workflow step
   completes, including commands, exits, and evidence.
5. If every mapped test case passes, mark the slice `passing`. If a required
   check cannot run, mark it `blocked`; if behavior needs repair, mark it
   `needs_fix`. Do not mark it passing on skipped, missing, or unrelated tests.
6. When all slices are `passing`, set the parent tracker status to `To be
   reviewed`, run `bash harness/scripts/check-feature-lifecycle.sh`, and invoke
   `harness-review.md`. Otherwise, invoke this workflow again for the next
   requested or ready slice.

An approved parent plan authorizes delivery of its recorded slices. Revise the
parent specification, implementation plan, test plan, and feature list when a
slice's scope, requirements, acceptance criteria, dependencies, or required
tests need to change. Obtain approval for a non-trivial revision before
implementing it.
