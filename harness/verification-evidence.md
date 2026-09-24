# Verification evidence format

Copy `templates/verification-evidence-template.json` into the active dated
workspace or a referenced run artifact directory. Replace `kind` with
`verification_evidence`, fill run/source/plan/selection/environment identity,
copy check/scenario record templates into their arrays, and remove the two
`*_record_template` fields. The JSON is a manual format, not a formal JSON Schema
or installed evidence validator. Do not claim automatic generation/enforcement.

## Status semantics

| Status | Meaning |
| --- | --- |
| PASS | Executed verification satisfied the required observable assertions. |
| FAIL | Executed check/assertion contradicted the requirement or command failed for a code/test defect. |
| BLOCKED | A required test, tool, baseline, environment, or assertion probe is missing/unavailable; no passing claim possible. |
| NOT_RUN | Not executed, including dependent gates after an earlier failure. |
| NOT_APPLICABLE | Out of scope under the requirement, with a specific recorded reason. |

Classify a failed command from evidence; nonzero due to unavailable Docker is
blocked infrastructure, not proof of an application defect. A required skipped
test, empty selector, or missing assertion is blocked evidence even if Go exits
zero. Static commands have null test counts; test commands need known executed
and skipped counts. Record cached results honestly; they do not prove a fresh run.

## Records and aggregation

- Gates contain actual check records, and scenarios link check IDs. Use one
  business scenario with related API/contract/DB/event assertions. Do not infer
  assertion-level PASS from a command exit if that assertion never ran.
- Record exact argument arrays, working directory, exit, timestamp, duration,
  counts, and artifact paths. Keep secrets out of arguments/evidence. Use safe
  environment identities instead of raw DB URLs or tokens.
- Identify the source revision plus working tree content fingerprint/artifact;
  a commit ID alone is insufficient for uncommitted changes. If unavailable,
  disclose the gap rather than claim source-matched evidence.
- Record safe expected/actual values and diagnostic locations for failures.
  Avoid note content, emails, real user payloads, JWT claims, and credentials.
  Test-owned synthetic metadata can be recorded when safe.
- A scenario passes only if all required assertions pass. A gate passes only
  if required checks/scenarios pass. Final PASS needs every applicable gate and
  scenario complete, plus required cleanup; NOT_APPLICABLE entries need reasons.
  FAIL takes precedence over BLOCKED when both exist; retain both details.
  Pending mandatory work keeps the result NOT_RUN or BLOCKED, never PASS.
- For an excluded gate, set required false, result NOT_APPLICABLE, and reason.
  Do not use this to exclude missing tests for an actual requirement.
- Kafka negative event assertions include observation windows. Idempotency
  records distinguish request/delivery attempts from business/effect counts.
- Link repair runs and rerun earlier mandatory gates against changed source.
  Preserve failed evidence; do not overwrite it with a later successful receipt.

Versioned summaries record command, status, counts, and evidence links. Evidence
can be reviewed manually now; automated collection and schema enforcement are
future implementation tasks, not part of this environment enhancement.
