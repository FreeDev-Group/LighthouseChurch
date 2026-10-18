# LightHouse Church theme — Testing overview

Overview of how the `lighthouse-church` theme (`development/lighthouse-church/`) is tested before the foundation can be validated (issue #9).

**Never run tests on the public website, on Hostinger or with Nova Mira.** All manual tests use a disposable local WordPress site on a team member's computer (`CLAUDE.md` §10, `Doc/decisions.md` D-011, D-012).

## 1. Documents

| Document | Purpose | Used by |
|----------|---------|---------|
| `Doc/testing/local-setup-guide.md` | Step-by-step local WordPress set-up (Local, or WordPress Playground as a fallback), reference ZIP download and checksum, test content | Every tester |
| `Doc/testing/test-checklist.md` | Automated checks A-01 to A-04 and human tests H-01 to H-13, with expected results, evidence and who runs what | Every tester |
| `Doc/testing/report-template-individual.md` | One report per tester, posted on issue #9 | Every tester |
| `Doc/testing/report-template-summary.md` | Collective summary and the Project Coordinator's decision, posted on issue #9 | Project Coordinator |

## 2. Test targets

| Item | Target | Source |
|------|--------|--------|
| WordPress | 7.1.3 | Production version communicated by the Project Coordinator (issue #4, P-005) |
| PHP | 8.3 | Production uses PHP 8.3.35 |
| Theme build | One reference ZIP from the "Theme checks" workflow, identified by its commit and SHA-256 | §4 |
| Site language | Français | D-007 |

The theme declares WordPress 6.6 and PHP 7.4 as minimums. Both are provisional (P-012): WordPress 6.6 is set by the features the theme uses (`theme.json` version 3, section styles in `styles/sections/`, `defaultSpacingSizes`); PHP 7.4 is a conservative floor kept in the CI for now, not a confirmed requirement.

## 3. Status

Last updated: 2026-10-16.

| Area | Status | Notes |
|------|--------|-------|
| Automated checks A-01 to A-04 (PHP syntax on 7.4 and 8.3, JSON, theme headers, ZIP build) | **Passing** | "Theme checks" workflow on every push to the pull request |
| Preliminary local checks | **Done, preliminary only** | WordPress 6.6-RC3 / PHP 8.3 in a disposable build: theme loads, `theme.json` keeps all keys, axe-core WCAG A/AA with 0 violations on 9 pages × 3 widths, one H1 per page, focus contrast ≥ 6.89:1, no horizontal scrolling at 375 px or 200% zoom, no external requests. **This is not a validation**: it must be confirmed by the campaign on WordPress 7.1.3. |
| Human tests H-01 to H-13 on WordPress 7.1.3 / PHP 8.3 | **Not started** | Test campaign of issue #9 |
| Collective summary and validation of the foundation | **Not started** | Project Coordinator |

## 4. Reference build (Project Coordinator)

Every tester must test the same file. Two builds of the same commit produce different ZIP files, so testers never build the ZIP themselves during the campaign.

1. Pick the reference commit on the pull request branch (normally the latest commit with a green "Theme checks" run).
2. Open that commit's workflow run, download the artifact `lighthouse-church-theme`, unzip it once and compute the SHA-256 of the inner `lighthouse-church-<version>.zip`:
   - Windows (PowerShell): `Get-FileHash .\lighthouse-church-0.1.0.zip -Algorithm SHA256`
   - macOS / Linux: `shasum -a 256 lighthouse-church-0.1.0.zip`
3. Post on issue #9: the commit, the link to the workflow run, the checksum, and the name of the tester for H-12 (screen reader).
4. Artifacts are kept for 30 days. If the campaign lasts longer, re-run the workflow on the same commit and announce the new link and checksum.

### Current reference build

The reference ZIP for this campaign is the file `lighthouse-church-0.1.0.zip` inside the official `lighthouse-church-theme` artifact of **CI run 2**. Artifacts produced by later workflow runs (including the run triggered by the commit that added this table) must **not** replace it for this campaign.

| Item | Value |
|------|-------|
| File | `lighthouse-church-0.1.0.zip` (inner ZIP of the `lighthouse-church-theme` artifact of CI run 2) |
| CI run | Run 2 — https://github.com/FreeDev-Group/LighthouseChurch/actions/runs/38962132740 |
| Commit | `752833c8b846ae7d76038de0cfd0dabb0cce4d55` |
| Size | 170,231 bytes |
| SHA-256 | `289EF6A5FD505E1EAA01B2E7674DC481C0279E025482D5F895DA72148A489AFA` |
| Checksum source | Computed by the Project Coordinator with `Get-FileHash` on the inner ZIP extracted from the official artifact |
| Artifact available until | 2026-11-15 |

`shasum` on macOS and Linux prints the same checksum in lowercase; compare the values without regard to letter case.

## 5. Who runs what

| Tests | Who |
|-------|-----|
| H-01 to H-09 and H-13 | Every tester |
| H-10 Theme Check, H-11 browser accessibility tools | At least one tester each |
| H-12 screen reader | One tester who has NVDA or VoiceOver |

## 6. Automated checks

Run locally before committing theme changes:

```bash
development/check-theme.sh
```

It checks PHP syntax (`php -l`), JSON validity, the required `style.css` headers and text domain, and builds the ZIP (`development/build-theme-zip.sh`) with a single `lighthouse-church/` folder, the required files and no development `README.md`. The workflow `.github/workflows/theme-checks.yml` runs the same script on PHP 7.4 and 8.3 for pull requests and pushes to `develop` and `main` that touch `development/`, reports failures as annotations, and uploads the ZIP as an artifact. It never deploys.

## 7. Known limits

- The ZIP build is not byte-for-byte reproducible (file timestamps); the reference ZIP and its checksum are the source of truth during the campaign. A reproducible build is a later improvement.
- Theme Check and the screen reader pass depend on the testers' environments.
- Validating the foundation does **not** authorize installing the theme on the public website (D-011, P-009, issue #4).
