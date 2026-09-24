---
description: Deliver a backend feature through requirements, approved planning, implementation, testing, and quality gates.
---

# Workflow: Feature delivery

Use this for a new endpoint, domain capability, persistence change, or
meaningful enhancement.

Pipeline: context → requirement/spec → implementation and test plan → user
approval → implementation → tests → quality gate → delivery record.

1. Read `AGENTS.md`, `architecture.md`, and `testing-strategy.md`. Load
   `api-contract.md`, `security.md`, or database guidance when triggered.
2. Create `workspace=docs/product/YYYY-MM-DD-feature/` before writing
   artifacts. Create `spec_v<N>.md` and `summary_v<N>.md` there. Record scope,
   exclusions, impacted layers, acceptance criteria, and the complete Rule
   Applicability table from `harness/templates/rule-applicability-template.md`.
3. Create `implementation_plan_v<N>.md` and `test_plan_v<N>.md` in the same
   workspace. Read `docs/product/project-capabilities.json` as a project-wide
   tooling inventory only. Derive the feature-wise Required/Not required
   verification matrix and generated test cases from this feature's spec and
   acceptance criteria using the Go testing skill. The test-plan template records
   those results. The workflow controls the static → unit → component →
   integration → regression sequence. Separate installed verification from missing
   tooling/tests; a declared capability does not prove runtime support. Run:
   `bash harness/scripts/check-stage-artifacts.sh feature-delivery implementation-plan "$workspace"`.
4. Stop for explicit user approval before implementation for non-trivial work.
5. Implement the smallest vertical slice: contract/handler, domain behavior,
   persistence, then tests as required by the plan.
6. Execute the planned gates in order; mandatory failure blocks later gates.
   Use the failure/repair/revalidation sequence in `testing-strategy.md`.
   Run `make check` at handoff and `make test-integration` when PostgreSQL
   evidence is required, after confirming isolated fixture ownership and cleanup.
   Do not treat the existing broad gate as a complete five-gate runner. Record
   commands, exits, counts, source identity, and scenario/assertion receipts using
   `harness/verification-evidence.md` in `summary_v<N>.md`. Missing required
   runtime or tests are BLOCKED; later dependent gates are NOT_RUN.
7. Update `docs/product/product.md` and add a durable note under
   `docs/changes/` when the change is delivered.
