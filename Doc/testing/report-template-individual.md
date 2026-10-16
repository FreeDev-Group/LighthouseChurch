# Individual test report — lighthouse-church

Copy this file, rename it `report-<your-name>-<YYYY-MM-DD>.md`, fill it in and post it, with your screenshots, as a comment on **issue #9**. Do not commit reports to the repository.

Required for every tester: H-01 to H-09 and H-13. H-10, H-11 and H-12 only if they were assigned to you; otherwise write `N/A — assigned to another tester` (see the checklist, §C).

## 1. Tester

| Field | Value |
|-------|-------|
| Name | |
| Date(s) of testing | |
| Time spent | |

## 2. Environment

| Field | Value |
|-------|-------|
| Method | Local / WordPress Playground |
| WordPress version (`wp core version` or Tools › Site Health) | |
| PHP version | |
| Site language | |
| Theme reference commit | |
| SHA-256 of `lighthouse-church-0.1.0.zip` | |
| Checksum matches the reference? | Yes / No |
| Operating system and version | |
| Browser(s) and version(s) | |
| Screen reader and version (if H-12) | |
| Other plugins active | Theme Check only / other: |

## 3. Results

Status: `PASS`, `FAIL`, `BLOCKED`, `N/A`. Evidence: file names, copied error text, URLs on your test site.

| ID | Test | Observed result | Status | Evidence | Anomaly IDs |
|----|------|-----------------|--------|----------|-------------|
| H-01 | Install and activate | | | | |
| H-02 | Site Editor loads | | | | |
| H-03 | Global styles | | | | |
| H-04 | Header and footer | | | | |
| H-05 | Section styles | | | | |
| H-06 | Mobile navigation, keyboard, Escape, focus | | | | |
| H-07 | Keyboard walkthrough | | | | |
| H-08 | French display | | | | |
| H-09 | Responsive | | | | |
| H-10 | Theme Check | | | | |
| H-11 | Browser accessibility tools | | | | |
| H-12 | Screen reader | | | | |
| H-13 | Errors and logs | | | | |

## 4. Anomalies

One block per problem. ID format: `<your initials>-<number>`, e.g. `AB-01`.

### <ID> — <short title>

| Field | Value |
|-------|-------|
| Test | H-xx |
| Page / template / screen | |
| Width / device | |
| Steps to reproduce | 1. … 2. … 3. … |
| Expected | |
| Observed | |
| Severity | Blocking / Major / Minor / Cosmetic |
| Evidence | |
| Reproduced more than once? | Yes / No |

Severity guide:

- **Blocking**: the theme cannot be installed or used, the site breaks, content is lost, or a person using a keyboard or screen reader cannot use a main function.
- **Major**: a main function works badly or an accessibility requirement (WCAG 2.2 AA) is not met.
- **Minor**: a problem with a simple workaround.
- **Cosmetic**: visual detail only.

## 5. Comments

Anything else worth telling the coordinator (unclear instructions, ideas, questions).
