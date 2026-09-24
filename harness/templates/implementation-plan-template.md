# Implementation plan

## Feature context

- Request, issue, or feature reference:
- Scope and exclusions:
- Impacted layers, requirements, and acceptance criteria (use stable `REQ-*` and `AC-*` IDs for complex features):
- Parent spec (complex harness-planning only):

## Implementation approach

Describe the one coherent feature change, including its impacted files or
layers, observable behavior, and planned verification. Do not split an ad hoc
`feature-delivery` plan into slices; the parent `harness-planning` workflow is
the only workflow that creates independently tracked slices.

## Verification environment

- Project capability profile and triggered optional rules:
- Existing executable checks vs new verification work explicitly in scope:
- Missing required tooling/tests/infrastructure and resolution:
- Gate ordering, targeted selectors, and final regression (see test plan):

For a complex feature, link the parent spec's required rule rows. For an ad hoc
feature or bug fix, record only the constraints triggered by this change.

Do not install a broker, implement an adapter, or add product behavior solely
because it appears in a generic capability checklist.

## Approval

- Status: Awaiting implementation approval
- Approved by/date:
