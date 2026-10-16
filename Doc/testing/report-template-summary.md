# Test campaign summary — lighthouse-church

Filled in by the Project Coordinator (or a designated team member) once all individual reports have been posted on issue #9. The completed summary is posted as a comment on issue #9.

## 1. Campaign

| Field | Value |
|-------|-------|
| Campaign period | |
| Reference commit | |
| GitHub Actions run (reference ZIP) | |
| SHA-256 of `lighthouse-church-0.1.0.zip` | |
| Target versions | WordPress 7.1.3, PHP 8.3 |
| Testers | |
| Individual reports received | n / n |

## 2. Automated checks

| ID | Check | Result | Run link |
|----|-------|--------|----------|
| A-01 | PHP syntax (7.4, 8.3) | | |
| A-02 | JSON validity | | |
| A-03 | Theme headers | | |
| A-04 | ZIP build and layout | | |

## 3. Environments actually used

| Tester | Method | WordPress | PHP | OS | Browser | Checksum OK |
|--------|--------|-----------|-----|----|---------|-------------|
| | | | | | | |

Reports with a different WordPress version or a checksum mismatch are listed here but **not** counted in §4.

## 4. Results by test

Count of PASS / FAIL / BLOCKED / N/A from valid reports.

| ID | Test | PASS | FAIL | BLOCKED | N/A | Overall | Notes |
|----|------|------|------|---------|-----|---------|-------|
| H-01 | Install and activate | | | | | | |
| H-02 | Site Editor loads | | | | | | |
| H-03 | Global styles | | | | | | |
| H-04 | Header and footer | | | | | | |
| H-05 | Section styles | | | | | | |
| H-06 | Mobile navigation, keyboard, Escape, focus | | | | | | |
| H-07 | Keyboard walkthrough | | | | | | |
| H-08 | French display | | | | | | |
| H-09 | Responsive | | | | | | |
| H-10 | Theme Check | | | | | | |
| H-11 | Browser accessibility tools | | | | | | |
| H-12 | Screen reader | | | | | | |
| H-13 | Errors and logs | | | | | | |

Overall rule: `PASS` only if no valid report has FAIL for that test; `FAIL` if at least one reproducible FAIL; `INCOMPLETE` if the test was not run by the testers required in the checklist, §C (every tester for H-01 to H-09 and H-13; at least one valid result for H-10, H-11 and H-12).

## 5. Consolidated anomalies

Merge duplicates reported by several testers under one entry.

| Ref. | Title | Test | Severity | Reported by | Reproduced | Proposed action | GitHub Issue |
|------|-------|------|----------|-------------|------------|-----------------|--------------|
| | | | | | | Fix before validation / Fix later / Accept / Not a theme issue | |

Every anomaly marked "Fix before validation" or "Fix later" gets its own GitHub Issue that references #9. An anomaly marked "Accept" needs a one-line reason from the Project Coordinator.

## 6. Decision

| Question | Answer |
|----------|--------|
| Any open Blocking or Major anomaly? | Yes / No |
| Foundation validated for the homepage step? | Yes / No / With conditions |
| Conditions or follow-up Issues | |
| Decided by | Salomon (Project Coordinator) |
| Date | |

Validating the theme foundation does **not** authorize installing the theme on the public website. That needs a separate approval and the backup and recovery procedure (D-011, P-009).
