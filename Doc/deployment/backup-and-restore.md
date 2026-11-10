# Backups and restore — production and staging

Proposal for P-009 (backup and recovery procedure). Written on 2026-11-10 from what was actually run and checked on the server; it becomes the agreed procedure only once the Project Coordinator approves it in `Doc/decisions.md`.

No password, database credential or backup file is stored in Git (`CLAUDE.md` §9). Backups contain `wp-config.php` (database password) and the user table (e-mail addresses, password hashes): treat them as secrets.

## 1. What exists

| Source | Covers | State on 2026-11-10 |
|---|---|---|
| Hostinger automatic backups (hPanel › Websites › Manage › Files › Backups) | files and databases of the hosting account, restorable from hPanel | **Not verified**: the Hostinger API used by Claude Code has no backup operation. To check in hPanel by Salomon: frequency, date of the latest backup, files and database listed separately, "Restore" and "Generate new backup" buttons. |
| Server backups made by `development/deploy/lhc-steps.sh` (`backup` step) | full copy of the WordPress folder (`public_html`, including `wp-config.php`, `.htaccess`, `wp-content/uploads`) and a `mysqldump` of the site database | **Working and verified** (section 2). |
| Copy outside Hostinger | — | **Not done.** Manual step for Salomon (section 6). |

## 2. Server backups

Location: outside every website folder, not reachable over the web, folders `700`, files `600`.

| Site | Folder | Files |
|---|---|---|
| Production `lighthousechurchbujumbura.org` | `/home/u628308143/lhc-backups/<UTC date>-<time>/` | `db.sql.gz`, `files.tar.gz` (`public_html/…`), `SHA256SUMS` |
| Staging `staging.lighthousechurchbujumbura.org` | `/home/u628308143/lhc-backups-staging/<UTC date>-<time>/` | the same, and `.htpasswd` (hash of the team HTTP login) inside `files.tar.gz` |

### Production backups on the server

| Folder | `db.sql.gz` | `files.tar.gz` | Note |
|---|---|---|---|
| `20261025-202602` | — | 55,955,136 bytes | files only (first attempt) |
| `20261025-202803` | 31,564 bytes, SHA-256 `33d968ae…8a697` | 55,955,136 bytes, SHA-256 `92aba312…eb09b` | before theme activation; restore-tested on 2026-10-26 (isolated database and folder) |
| `20261025-224104` | 173,517 bytes, SHA-256 `70a34ff4…582a3` | 59,984,801 bytes, SHA-256 `03b36774…d5cddb5d10` | before the new homepage and footer |
| `20261026-130109` | 175,977 bytes, SHA-256 `6228d044…42256` | 59,986,066 bytes, SHA-256 `a5b804df…5f8ec` | before the LiteSpeed update |
| **`20261110-160505`** | **41,351 bytes**, SHA-256 `f4e512a4d5542a44f0426b5aa9e6f138bd86794913b582e0cb71dca37920b5ea` | **59,878,302 bytes**, SHA-256 `64ece33cb3055727d3848cc7ec3912763b4c1f9f53b3f6e3e9f0d5b4e8f36adb` | **before the staging environment was created (latest)** |

Checks of `20261110-160505` (log `~/lhc-ops/logs/backup.20261110.log`), all passed: `mysqldump` exit 0, `tar` exit 0; both archives pass `gzip -t`; 6,263 files in the archive = 6,263 files on disk; `wp-config.php`, `.htaccess`, `wp-includes/version.php` and `wp-content/themes/lighthouse-church/style.css` present; 32 upload files; 21 tables in the dump = 21 tables in the database; the dump ends with `-- Dump completed on 2026-11-10 16:05:08`; `sha256sum -c SHA256SUMS` OK. All older archives still pass `gzip -t` and keep the checksums recorded in #13.

The database dump is smaller than on 2026-10-26 (41 KB instead of 176 KB) while the site content is the same (nine published pages, menu, footer, six images, four accounts). The cause was not checked table by table; the likely source is plugin data (cache URL lists, scheduled-action logs, transients), which is not site content. The nine pages answered HTTP 200 from the server right after the backup.

### Making a backup

Two short-lived cron jobs (hPanel › Advanced › Cron Jobs, or the Hostinger API), one simple command each, deleted as soon as the step is finished:

```text
curl -sSf --stderr - -o /home/u628308143/lhc-ops/lhc-steps.sh https://raw.githubusercontent.com/FreeDev-Group/LighthouseChurch/<commit>/development/deploy/lhc-steps.sh
env LHC_SITE=prod LHC_REF=<commit> bash /home/u628308143/lhc-ops/lhc-steps.sh backup.<date>
```

Use `LHC_SITE=staging` for staging. Each run needs a new step name (`backup.<date>`), otherwise the script only prints the earlier log. The cron output shows the checks listed above; `backups-check` re-checks every archive of the site later.

Limits found on this hosting: hPanel runs each command as `timeout <n> <command>` (the first word must be a program, hence `env`), logs only the output of the last command, treats `%` as the end of the command (crontab rule), and the API firewall refuses some command shapes (`; curl`, `bash -c "… curl …"`).

## 3. Who can restore, and how long it takes

- **Who:** Salomon, the only person with hPanel access (hPanel login and the WordPress `admin` account). Mentees never restore production.
- **When:** only after a decision by Salomon, and after a fresh backup of the current (even broken) state, so that the restore itself can be undone.
- **Duration:** the full restore of staging, database and files, took the time recorded in section 5; a production restore through hPanel takes longer (upload and extraction in File Manager): plan 30 minutes, with the checks.

## 4. Restoring production (procedure for Salomon)

Before starting: write down the backup folder to use and the reason; tell the team that production is being restored.

1. **Backup of the current state.** Run the `backup` step for `prod` (section 2) and check its output. If the server cannot be reached, use hPanel › Files › Backups › "Generate new backup" if offered.
2. **Check the archive to restore.** File Manager › go up to `/home/u628308143/lhc-backups/<folder>/`. Compare the sizes with section 2. Optional: run `backups-check` for `prod` and check that the folder shows `OK`.
3. **Database.** hPanel › Databases › phpMyAdmin › open `u628308143_XE2Co` (the production database; the staging database has another name) › Import › `db.sql.gz` (download it from File Manager first). The dump drops and recreates each of its tables; tables that are not in the dump are left as they are.
4. **Files.** File Manager › `/home/u628308143/domains/lighthousechurchbujumbura.org/`:
   1. rename `public_html` to `public_html.before-restore-<date>`;
   2. copy `files.tar.gz` from the backup folder into this folder, and extract it here: it recreates `public_html` with the saved files and permissions;
   3. delete the copied `files.tar.gz` from this folder (keep the one in `lhc-backups`).
5. **Cache.** WordPress admin › LiteSpeed Cache › Toolbox › Purge All (or hPanel › Websites › Clear cache).
6. **Checks** (`Doc/deployment/hostinger-deployment.md`, Part E): homepage and the nine pages, menu, mobile view, no PHP error, HTTPS, login to wp-admin.
7. If everything is right, delete `public_html.before-restore-<date>` after a few days. If not, rename the folders back and re-import the database dump of step 1.
8. Record the restore in #13: date, who, backup used, reason, result.

**Smaller incidents:**

| Situation | Action |
|---|---|
| One page damaged | Pages › the page › Revisions › restore the previous revision (no backup needed). |
| Theme displays badly, admin works | Appearance › Themes › activate Twenty Twenty-Five (installed), then restore Settings › Reading. Or step `rollback` of `lhc-steps.sh`. |
| Admin not reachable after a theme change | File Manager › `public_html/wp-content/themes/`: rename `lighthouse-church` to `lighthouse-church-off`; WordPress falls back to an installed theme. |
| Footer customisation lost | Site Editor › Patterns › Footer, paste `development/deploy/drafts/footer-final.html` in the code editor. |

The script has no production restore step on purpose: a production restore is a decision taken and carried out by Salomon, step by step.

## 5. Staging backups and restore test

See `Doc/deployment/staging-environment.md`, section "Backups and restore test", for the staging backup folders and the result of the full restore test.

## 6. Copy outside Hostinger (manual, Salomon)

Claude Code cannot download files from the hosting account (its network cannot reach the Hostinger file service), so this step stays manual:

1. hPanel › File Manager › `/home/u628308143/lhc-backups/20261110-160505/` › download `db.sql.gz`, `files.tar.gz` and `SHA256SUMS`.
2. Check the SHA-256 on your computer (PowerShell: `Get-FileHash <file> -Algorithm SHA256`) against section 2.
3. Keep them in a private, encrypted place agreed by Salomon (never in GitHub, never in a shared chat).

## 7. Retention (proposal)

- Production: keep the latest backup made before each production change, plus the two previous ones; delete older server backups only after a copy outside Hostinger exists, with Salomon's approval.
- Staging: keep the three latest backups; staging can always be rebuilt from Git (`Doc/content/pages/`, theme 0.1.0).
- Disk use on 2026-11-10: `lhc-backups` 279 MB; hosting disk not near its limit.
