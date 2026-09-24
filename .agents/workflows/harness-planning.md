---
description: Plan a complex backend feature once, split it into approved slices, and prepare slice delivery and final review.
---

# Workflow: Harness planning

Use this for a complex feature that cannot be delivered as one ad hoc vertical
slice. This workflow creates the parent feature plan once; it does not implement
product code.

1. Read `AGENTS.md`, architecture, testing strategy, the product capability
   profile, and rules triggered by the feature. Ask the user the concise
   questions needed to resolve scope, acceptance criteria, exclusions,
   dependencies, contract/schema impact, and any testing promises. Do not draft
   a specification while material questions remain open.
2. Create `workspace=docs/product/YYYY-MM-DD-feature/` and write only the
   parent `spec_v<N>.md`. Present it for user review and resolve any feedback.
   Do not create the implementation plan, test plan, feature list, or a parent
   summary until the specification has no open issues.
3. After the specification is accepted, write the parent
   `implementation_plan_v<N>.md` and `test_plan_v<N>.md`. The parent test plan
   contains the feature requirements matrix and generated required test cases.
4. Create `feature_list.json` from `harness/templates/feature_list_template.json`.
   Give parent requirements `REQ-*` IDs and acceptance criteria `AC-*` IDs.
   Split the feature into independently deliverable slices. For each slice record
   its concise scope, `depends_on`, `requirement_ids`, `acceptance_ids`, and
   required `test_case_ids` from the parent artifacts. Do not create a slice for
   a technical layer alone; each slice must deliver observable behavior or a
   necessary verified foundation.
5. Validate that each mapping ID exists in the parent artifacts; every parent
   requirement and acceptance criterion belongs to one or more slices; every
   Required test case belongs to a slice; dependencies have no cycle; and no
   slice overlaps another slice's ownership without an explicit reason.
   Run `bash harness/scripts/check-stage-artifacts.sh harness-planning implementation-plan "$workspace"`.
6. Update the parent feature tracker to `Awaiting implementation approval` and
   obtain approval of the parent plan. That approval authorizes only the slices
   recorded in the approved parent artifacts.
7. After approval, use `harness-generator.md` once for each unblocked slice. Do
   not return to this workflow for normal slice delivery.
8. When every slice is `passing`, set the parent tracker to `To be reviewed`,
   run `bash harness/scripts/check-feature-lifecycle.sh`, and invoke
   `harness-review.md`.

Revise this parent workflow when a slice's scope, requirements, acceptance
criteria, dependencies, or required test cases need to change. Obtain approval
for a non-trivial plan revision before affected slice implementation resumes.
