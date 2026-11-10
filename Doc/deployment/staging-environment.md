# Shared development environment (staging)

Implements D-021. Created on 2026-11-10 by Claude Code for the Project Coordinator, through the Hostinger API and the server step script `development/deploy/lhc-steps.sh` (`LHC_SITE=staging`). Tracked in #13.

**No password is written in this document or anywhere in GitHub.** Where to find each secret is given below.

## 1. Summary

| Item | Staging | Production (unchanged) |
|---|---|---|
| Address | `https://staging.lighthousechurchbujumbura.org/` | `https://lighthousechurchbujumbura.org/` |
| Hostinger website | separate website (type "addon") on the same hosting account `u628308143` (plan `hostinger_premium_v6`) | main website |
| Document root | `/home/u628308143/domains/staging.lighthousechurchbujumbura.org/public_html` | `/home/u628308143/domains/lighthousechurchbujumbura.org/public_html` |
| WordPress installation (Hostinger id) | 31508844 | 31057790 |
| Database | `u628308143_lhcstaging`, user `u628308143_CmGpe` | `u628308143_XE2Co`, user `u628308143_9rLea` |
| `wp-config.php` | its own, in the staging document root | its own |
| WordPress / PHP | 7.1.4, `fr_FR` / PHP 8.3 | 7.1.4 / PHP 8.3 |
| Theme | LightHouse Church 0.1.0 (36 files identical to the reference ZIP, commit `752833c`) | the same |
| Site title | `[DEV] LightHouse Church Bujumbura`, tagline "Environnement de développement — ce site n’est pas le site officiel" | `LightHouse Church Bujumbura` |
| Accounts | Salomon (Administrator), Yusse, Alain, David (Editor): section 4 | separate accounts; none was copied |
| Access | HTTP login for the whole site, then WordPress login | public |
| Indexing | blocked: "Discourage search engines" ticked and `X-Robots-Tag: noindex, nofollow` | indexed |
| Automatic synchronisation | **none**, in either direction | — |

## 2. What was installed

- **Website and folder.** Created with the Hostinger API as its own website, so its folder sits next to the production folder, not inside the production `public_html`. It does not share the production `.htaccess` and is not in the production backups.
- **DNS.** Hostinger added four records for the subdomain in the zone `lighthousechurchbujumbura.org`: `staging` A `31.170.164.130`, `staging` AAAA `2a02:4780:a:806:0:2573:38af:3`, `www.staging` CNAME `staging…`, `ftp.staging` A `31.170.164.130`. The three production records (`@` ALIAS to the Hostinger CDN, `www` CNAME, `ftp` A) were compared before and after: **unchanged**. Checked from the server with the system resolver and Google DNS (8.8.8.8): `staging…` and `www.staging…` resolve to the server.
- **SSL.** Certificate issued automatically by Hostinger (Let's Encrypt), for `staging…` and `www.staging…`, valid 2026-11-10 to 2027-02-08, renewed by Hostinger; HTTP is redirected to HTTPS.
- **WordPress.** New installation with a new database and a new administrator `salomon` (not `admin`), French, automatic minor core updates. No production content, user or personal data was imported.
- **Theme.** The reference ZIP was no longer on the server and the GitHub artifact could not be fetched from the Claude Code session. The theme folder deployed on production was checked file by file against the SHA-256 list of the reference ZIP 0.1.0 (`development/deploy/theme-0.1.0.sha256`, 36 files, commit `752833c`), copied to staging, and the copy was checked again: all 36 files match, no extra file. Activated.
- **Pages.** The nine pages from `Doc/content/pages/` (commit `9f88395`), created with `create-pages.php`, then published; front page Accueil, posts page Actualités, permalinks `/%postname%/`, categories Actualités, Événements, Ressources, "Menu principal" with the nine entries (D-018). The production footer (`development/deploy/drafts/footer-final.html`) was applied, so staging looks like production. The sample post was moved to the trash.
- **Images.** The homepage uses the absolute URLs of the six CC0 placeholder photos stored on production (`https://lighthousechurchbujumbura.org/wp-content/uploads/…`). They display on staging, and the markup stays identical to `Doc/content/pages/01-accueil.html`, so a page copied back from staging to Git keeps working on production. New photos uploaded on staging get staging URLs: they must be uploaded again on production during the transfer.
- **Plugins.** The Hostinger installer added its default plugins: Hostinger Tools, Hostinger Easy Onboarding, Hostinger Reach, Hostinger AI Assistant (and inactive Hostinger helpers). They were left as installed and are **not** approved under D-006: Salomon decides whether to keep or deactivate them. LiteSpeed Cache is not installed on staging.

## 3. Access protection

1. **HTTP login (first layer).** Every address of the site asks for a login before anything is shown, including `wp-admin` and `wp-login.php`. It is a single team login, `lhc-equipe`, which is not a WordPress account. Only `/.well-known/acme-challenge/` (certificate renewal) and `wp-cron.php` (WordPress scheduled tasks) stay reachable without it.
   - Rules: the block `# BEGIN LHC staging protection … # END LHC staging protection` at the top of the staging `.htaccess`.
   - Password hash: `/home/u628308143/domains/staging.lighthousechurchbujumbura.org/.htpasswd` (outside the document root).
   - **Password: only in `/home/u628308143/lhc-secrets/staging-http-login.txt`** (folder `700`, file `600`). Salomon reads it in hPanel › File Manager and gives it to the team through a private channel, never in GitHub.
   - To change it: delete `staging-http-login.txt` and run the `protect` step again with a new step name (for example `protect.2`).
   - Checked from the server: without login `/` and `/wp-admin/` answer **401**; with a wrong password **401**; with the login the nine pages and `wp-login.php` answer **200**; the ACME path answers 404 (not 401).
2. **WordPress login (second layer).** Individual accounts (section 4).
3. **No indexing.** Settings › Reading › "Discourage search engines from indexing this site" is ticked (`blog_public = 0`) and every response carries `X-Robots-Tag: noindex, nofollow`. This is not access protection; the HTTP login is.
4. **Visible marker.** The site title starts with `[DEV]` and the tagline says it is not the official site.

hPanel › Advanced › "Password Protect Directories" was not used because the Hostinger API does not offer it; the `.htaccess` rules above do the same thing. If Salomon prefers to manage the login from hPanel, protect the folder `domains/staging.lighthousechurchbujumbura.org/public_html` there and remove the LHC block from `.htaccess` (keep the `X-Robots-Tag` lines).

## 4. Accounts

| Person | Staging login | Role | Password |
|---|---|---|---|
| Salomon | `salomon` | Administrator | set by Salomon through the reset link sent by e-mail |
| Yusse | `yusse` | Editor | set by Yusse through the WordPress "new account" e-mail |
| Alain | `alain` | Editor | the same |
| David | `david` | Editor | the same |

- The e-mail addresses are those of each person's production account, read on the server at creation time; they are not written in Git.
- The password given to the Hostinger installer for `salomon` was replaced on the server by an unknown random value; Salomon chooses his own through the reset link.
- No shared WordPress account. No production account exists on staging, and no staging account exists on production.
- On production the four accounts (`admin`, Alain, David, Yusse) are all Administrators (seen on 2026-11-10): to review separately (#13).
- Editors can edit all pages, posts and media, not the theme, plugins, menus or settings. "Only your three pages" is a team rule (#10 to #12), not enforced by WordPress.

To sign in: open `https://staging.lighthousechurchbujumbura.org/wp-admin/`, enter the team HTTP login, then your own WordPress login. If the e-mail did not arrive: "Mot de passe oublié ?" on the login page, or ask Salomon.

## 5. Backups and restore test

- **Hostinger backups.** Whether the hPanel automatic backups cover the staging website (it is a separate website on the same account) could not be checked: the Hostinger API has no backup operation. To check by Salomon in hPanel › Websites › `staging…` › Files › Backups.
- **Server backup** (`backup` step), folder `/home/u628308143/lhc-backups-staging/` (`700`, files `600`):

  | Folder | `db.sql.gz` | `files.tar.gz` | Content |
  |---|---|---|---|
  | `20261110-162323` | 36,095 bytes, SHA-256 `1bf7946f634676079ee78980321693e0419fda31a62a745a0305ef1f044bd5ff` | 71,391,065 bytes, SHA-256 `b5ad23f44c6d72ab3b71e042c8bdfab9b05b0723ac4ef9eb06a6cfa77ab3d627` | WordPress files with `wp-config.php`, `.htaccess`, theme, `wp-content/uploads` (empty so far), and `.htpasswd`; database: 19 of 19 tables, pages, menu, footer, the four accounts |

  Checks: `mysqldump` and `tar` exit 0, `gzip -t` OK, dump complete, `SHA256SUMS` OK, 9,291 site files on disk = 9,291 in the archive (plus `.htpasswd`).

- **Restore test (2026-11-10, staging only).** Step `restore-full`: simulated incident (a "marker" page added, the Galerie page deleted, a marker file added in `wp-content`), then the backup above was restored over staging: database imported, document root moved aside and the archive extracted with its permissions.
  - First attempt (16:23 UTC) **failed** and was caught by the checks: the dump was imported without a database name (`ERROR 1046`), so only the files were restored. Script fixed (commit `60c5caa`): the import names the database, and the step stops before touching the files if the import fails.
  - Second attempt (16:28 UTC) **passed**: import exit 0, extract exit 0, restore time **5 seconds**; marker page gone, Galerie page back (ID 11), marker file gone, 9,291 files = archive, WordPress core checksums verified, theme LightHouse Church active, front and posts pages right; without login 401, with login the nine pages and `wp-login.php` 200, `X-Robots-Tag` present, marker address 404. The moved-aside folders were deleted afterwards.
  - This also shows the production procedure works on this hosting (same dump and archive format, same commands); a production restore through hPanel is described in `Doc/deployment/backup-and-restore.md` §4.
- **Before each risky change on staging** (theme 0.1.1, plugin test, bulk edits): run `backup.<date>`. Restoring staging is decided by Salomon and announced to the team, because it erases changes made after the backup.

## 6. Rules of use

- Staging is for building and testing. Nothing reaches production automatically.
- Workflow (D-021): edit on staging → copy the block markup (⋮ › Code editor) into `Doc/content/pages/<file>.html` on a branch → pull request with desktop and mobile screenshots → review by Salomon → Salomon applies the page on production, after a fresh production backup.
- A change that exists only in the staging database is not done: staging can be restored or rebuilt at any time.
- Mark test content `[Contenu de test — à supprimer]`. No personal data, no unvalidated contact or payment details, even on staging.
- Do not install plugins or themes on staging without Salomon's approval (D-006).

## 7. Server operations (for Salomon)

All steps run from short-lived cron jobs (see the header of `lhc-steps.sh` and `Doc/deployment/backup-and-restore.md` §2). Staging steps refuse to run if the staging folder is inside production, if the staging database is the production one, or if the site address is not the staging address; production-only steps refuse to run on staging and the other way round.

| Step | What it does |
|---|---|
| `inventory` | read-only state: versions, plugins, settings, pages, users, tables, DNS, headers, certificate |
| `check` | read-only: core checksums, pages, reading settings, HTTP codes with and without login, `X-Robots-Tag` |
| `protect` | HTTP login and `X-Robots-Tag` (idempotent) |
| `theme-copy`, `pages`, `setup`, `footer` | initial build (done on 2026-11-10) |
| `accounts` | Editor accounts of the mentees (existing accounts are not changed) |
| `backup` | files and database backup into `~/lhc-backups-staging/` |
| `restore-full` | full restore test of the latest staging backup over staging |

Rebuilding staging from scratch: delete the staging website in hPanel (never the production one), then repeat section 2 with the same steps.
