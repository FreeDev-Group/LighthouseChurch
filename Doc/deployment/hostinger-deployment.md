# First deployment on Hostinger — procedure and checklist

Procedure for installing the `lighthouse-church` theme and the initial pages on the single production WordPress site (D-009). It follows `CLAUDE.md` §10 and `Doc/decisions.md` (D-011, D-018 to D-020, P-005 to P-009).

**Nothing in this document has been done yet.** Each step is done by a person with access to Hostinger and WordPress, who fills in the "Done by / date / evidence" column. Do not tick a step that was not actually done and checked.

**Gate:** the deployment itself (Part C onward) needs the explicit approval of the Project Coordinator (Salomon), given after Parts A and B are complete. `CLAUDE.md` §10.4 also requires the recovery procedure (Part E) to be agreed and recorded in `Doc/decisions.md` (P-009) before the first deployment.

## What is deployed

| Item | Value |
|------|-------|
| Theme file | `lighthouse-church-0.1.0.zip`, inner ZIP of the `lighthouse-church-theme` artifact of CI run 2 — https://github.com/FreeDev-Group/LighthouseChurch/actions/runs/38962132740 (artifact available until 2026-11-15) |
| Commit | `752833c8b846ae7d76038de0cfd0dabb0cce4d55` |
| Size | 170,231 bytes |
| SHA-256 | `289EF6A5FD505E1EAA01B2E7674DC481C0279E025482D5F895DA72148A489AFA` |
| Pages | `Doc/content/pages/` (nine pages, created as drafts) |
| Menu | "Menu principal", nine entries (D-018) |
| Plugins | None. No plugin is installed or activated (D-006). |

Use only this ZIP. Do not use a ZIP rebuilt locally or from a later workflow run. If the artifact expires before the deployment, re-run the workflow on the same commit and record the new checksum on issue #9 before using it.

## Part A — Identify the target and its current state

| # | Step | Expected | Done by / date / evidence |
|---|------|----------|---------------------------|
| A1 | hPanel › Websites: note the website, the domain it serves and the hosting plan | Domain and plan recorded (P-005) | |
| A2 | Open the WordPress admin from hPanel and note its address | The admin belongs to the same website as A1. Expected address: `https://linen-viper-933608.hostingersite.com/` or `https://lighthousechurchbujumbura.org/` (P-005) | |
| A3 | Tools › Site Health › Info: WordPress, PHP, site URL, home URL | WordPress 7.1.3, PHP 8.3.x; WordPress installed at the root of the domain (no sub-folder) | |
| A4 | HTTPS: open the site address with `https://` | Padlock, no certificate warning | |
| A5 | Appearance › Themes: note the **active theme** and its version | Recorded (needed for rollback) | |
| A6 | Pages, Posts, Media, Plugins: note counts, titles of existing pages, active plugins | Recorded. Check whether pages with the slugs `accueil`, `a-propos`, `ministeres`, `evenements`, `ressources`, `actualites`, `galerie`, `donner`, `contact` already exist | |
| A7 | Settings › General, Reading, Permalinks: note current values | Recorded (needed for rollback) | |
| A8 | Users: list accounts and roles | Recorded; no shared administrator account (issue #4) | |
| A9 | Screenshots of the homepage, desktop and mobile | "Before" state kept with the evidence | |

**Stop** if the WordPress admin of A2 does not belong to the website of A1, or if the domain or instance is not certain.

## Part B — Backup and restore test

| # | Step | Expected | Done by / date / evidence |
|---|------|----------|---------------------------|
| B1 | Make a full backup of the **files** and the **database**. Use the backup tool available on the plan (hPanel › Websites › Backups, to be verified), or download the files (hPanel › File Manager, compress `public_html`) and export the database (hPanel › Databases › phpMyAdmin › Export) | Two files (or one Hostinger backup) with date, time and size | |
| B2 | Store a copy of the backup outside Hostinger, in a place agreed by the Project Coordinator (not in GitHub, `CLAUDE.md` §9) | Location recorded (without credentials) | |
| B3 | Restore the backup on a **local copy in Local** (D-020): new Local site, replace `wp-content` with the backup files, import the database, replace the site URL with the Local address | The local copy opens and shows the same pages as production | |
| B4 | Record the result of B1–B3 on issue #4 | Date, who, result | |

**Stop** if the backup cannot be made, cannot be downloaded, or if the restore test fails. Do not continue without a working backup.

## Part C — Protection during preparation

| # | Step | Expected | Done by / date / evidence |
|---|------|----------|---------------------------|
| C1 | Decide with the Project Coordinator whether to tick Settings › Reading › "Discourage search engines from indexing this site" until launch | Decision recorded | |
| C2 | Choose a time with little traffic; one person deploys, one person checks | Names and time recorded | |

## Part D — Install, prepare and activate

| # | Step | Expected | Done by / date / evidence |
|---|------|----------|---------------------------|
| D1 | Verify the SHA-256 of the ZIP on the computer used: `Get-FileHash .\lighthouse-church-0.1.0.zip -Algorithm SHA256` | Matches the value above | |
| D2 | Appearance › Themes › Add New › Upload Theme › choose the ZIP › Install now. **Do not activate.** | "LightHouse Church 0.1.0" installed, no error | |
| D3 | Create the nine pages **as drafts** (`Doc/content/pages/README.md`, method A or B). Skip any slug that already exists and report it | Nine drafts; no existing page changed | |
| D4 | Appearance › Themes › LightHouse Church › **Live Preview** | Preview opens; the public site is unchanged | |
| D5 | Settings › General: Site title "LightHouse Church Bujumbura" (D-000); Site language **Français** (D-007) | Saved | |
| D6 | Settings › Permalinks: "Post name" | Saved | |
| D7 | Publish the nine pages | Nine published pages | |
| D8 | Settings › Reading: static homepage **Accueil**, posts page **Actualités** | Saved | |
| D9 | Appearance › Themes › LightHouse Church › **Activate** | Theme active | |
| D10 | Create the main menu (`Doc/content/pages/README.md`, "After the pages are published") | Nine entries in the order of D-018, in the header and the footer | |

## Part E — Check right after activation

| # | Check | Expected | Done by / date / evidence |
|---|-------|----------|---------------------------|
| E1 | Homepage, logged out (private window) | Hero, sections, footer; no blank page or PHP error | |
| E2 | Each of the nine menu entries, header and footer | Each opens its page (no 404) | |
| E3 | Links inside the pages (buttons and text links) | No broken link | |
| E4 | Mobile (phone, or browser responsive mode at 375 px) | Menu button opens and closes the menu; no horizontal scrolling; text readable | |
| E5 | Actualités page, one post, a search, a missing page (`/page-inexistante/`) | Posts list, post, results page, 404 page display | |
| E6 | Donner page | Only the provisional text; no account number, phone number, payment link, wallet or transfer instruction | |
| E7 | Contact page and footer | No unconfirmed contact details; placeholders `[À CONFIRMER]` only | |
| E8 | Edit one page as an editor, change a word, update, check, undo | The text can be edited from WordPress | |
| E9 | HTTPS on every page checked | Padlock on every page | |
| E10 | Record the result on issue #4 with screenshots | Done | |

If any check fails in a way that affects visitors, roll back at once (Part F) and report on issue #4.

## Part F — Rollback (proposal for P-009)

| Situation | Action |
|-----------|--------|
| The new theme displays badly but the admin works | Appearance › Themes › reactivate the theme noted in A5. Restore the Reading settings noted in A7. Pages created in D3 can stay as drafts (Pages › Quick Edit › Status: Draft); nothing is deleted. |
| The admin is not reachable (fatal error, blank page) | hPanel › File Manager › `public_html/wp-content/themes/`: rename `lighthouse-church` to `lighthouse-church-off`. WordPress falls back to another installed theme; then reactivate the theme noted in A5. |
| Content or settings are damaged | Restore the backup of B1 with the same tool, then re-check E1–E3. |

## Part G — Sign-off

| # | Step | Done by / date |
|---|------|----------------|
| G1 | Results of Parts A–E recorded on issue #4 | |
| G2 | P-005 (hosting information), P-006 (method: manual ZIP upload) and P-007 (this checklist) updated in `Doc/decisions.md` after approval | |
| G3 | Project Coordinator approves the deployment as complete | |
