# LightHouse Church theme — Test plan and procedures

This document describes how to validate the `lighthouse-church` theme (`development/lighthouse-church/`) before it can be considered ready to install on the public website. It covers automated checks, a full local WordPress test environment, and manual test procedures.

**Never run these tests on the public website, on Hostinger, or with Nova Mira.** All tests below use a disposable local WordPress installation (see `CLAUDE.md` §10 and `Doc/decisions.md` D-011, D-012).

## 1. Status summary

Last updated: 2026-10-13.

| Area | Status | Evidence / notes |
|------|--------|------------------|
| PHP syntax, JSON validity, theme headers, ZIP build | **Automated** | `development/check-theme.sh`, run by the "Theme checks" GitHub workflow on PHP 7.4 and 8.3 |
| Theme loads without errors; `theme.json` and section styles keep all keys after WordPress sanitization; templates, parts, patterns and section styles are registered | **Passed** (WordPress 6.6-RC3 only) | Local disposable test build, PHP 8.3 |
| axe-core (WCAG 2.0–2.2 A/AA + best practices), 9 pages × 375/768/1280 px | **Passed** (WordPress 6.6-RC3 only) | 0 violations, one H1 per page |
| Keyboard focus visibility and contrast | **Passed** (WordPress 6.6-RC3 only) | Skip link reached first; minimum focus outline contrast 6.89:1 |
| No horizontal scrolling at 375 px and at 200% zoom; no external requests | **Passed** (WordPress 6.6-RC3 only) | — |
| Released WordPress versions (6.6.x and current stable) | **To do** | §3, §4 |
| Mobile menu with keyboard (open, Escape, focus) | **To do** | §5.1 — could not be tested: the RC test build lacks WordPress interactivity scripts |
| Site Editor: loading and editing the theme | **To do** | §5.2 — could not be tested: the RC test build lacks admin assets |
| Global styles, section styles, header and footer editing | **To do** | §5.3 |
| WordPress in French | **To do** | §5.4 — the French language pack could not be downloaded in the test session |
| Theme Check plugin | **To do** | §5.5 — wordpress.org was not reachable in the test session |
| Screen reader quick pass | **To do — needs a person** | §5.6 |
| Production hosting versions (WordPress, PHP) | **To do — needs a person** | P-005, P-012: must be read from Hostinger by an authorized person |

"Passed (WordPress 6.6-RC3 only)" results must be repeated on released versions (§3) before they count for the final validation.

## 2. Automated checks

Run locally before committing theme changes:

```bash
development/check-theme.sh
```

It checks:

1. PHP syntax of every `.php` file in the theme (`php -l`).
2. Every `.json` file in the theme parses as JSON.
3. `style.css` declares the required headers and the `lighthouse-church` text domain.
4. `development/build-theme-zip.sh` builds `dist/lighthouse-church-<version>.zip`, the ZIP has a single `lighthouse-church/` folder, contains the required files and excludes the development `README.md`.

The GitHub workflow `.github/workflows/theme-checks.yml` runs the same script on pull requests and on pushes to `develop` and `main` that touch `development/`. It runs on PHP 7.4 and 8.3, reports failures as annotations on the pull request, and uploads the built ZIP as a workflow artifact (14 days). It never deploys.

`php -l` on PHP 7.4 only proves that the code parses on 7.4. It does not prove that the theme runs correctly on PHP 7.4.

## 3. Compatibility targets

| Item | Declared by the theme | Why | To verify |
|------|-----------------------|-----|-----------|
| WordPress minimum | 6.6 (provisional, P-012) | The theme uses `theme.json` version 3, section styles in `styles/sections/` (block style variations from JSON files) and `settings.spacing.defaultSpacingSizes`, all introduced in WordPress 6.6. | Test on the latest 6.6.x patch release and on the current stable release. |
| PHP minimum | 7.4 (provisional, P-012) | WordPress 6.6 itself supports PHP 7.2.24 and later; the theme's own PHP is small and uses no PHP 8-only syntax. 7.4 was chosen as a conservative floor, not because the project needs it. | Read the PHP version actually used on Hostinger (P-005). If it is PHP 8.x, the coordinator can decide to raise the declared minimum and drop 7.4 from the CI matrix. |
| Production versions | Unknown | Not yet read from Hostinger. | An authorized person reads them in hPanel and records them under P-005. |

Recommended test matrix for §4–§5:

1. The WordPress and PHP versions used on Hostinger, once known (highest priority).
2. Until then: the current stable WordPress release with PHP 8.3, plus the latest WordPress 6.6.x patch release (declared minimum).

Use **released** versions only, never release candidates or nightly builds.

## 4. Local test environment

Any of these options is acceptable. They run on a team member's computer and never touch the public site. None of them has been run yet; check each tool's own documentation and `--help` before use, as options change between versions.

### Option A — WordPress Playground CLI (Node.js only, no Docker)

Requires Node.js 20 or later and internet access to wordpress.org.

```bash
# From the repository root. Replace <wp-version> with a released version, e.g. the current stable.
npx @wp-playground/cli@latest server \
  --wp=<wp-version> \
  --php=8.3 \
  --mount=./development/lighthouse-church:/wordpress/wp-content/themes/lighthouse-church \
  --blueprint=./blueprint.local.json \
  --login
```

`blueprint.local.json` is a local file (do not commit it if it contains anything specific to one computer):

```json
{
  "$schema": "https://playground.wordpress.net/blueprint-schema.json",
  "steps": [
    { "step": "setSiteLanguage", "language": "fr_FR" },
    { "step": "activateTheme", "themeFolderName": "lighthouse-church" },
    { "step": "setSiteOptions", "options": { "permalink_structure": "/%postname%/" } },
    { "step": "installPlugin", "pluginData": { "resource": "wordpress.org/plugins", "slug": "theme-check" } }
  ]
}
```

The Theme Check plugin is installed **only** in this disposable environment. It must never be installed on the public website without approval (D-006).

### Option B — `@wordpress/env` (requires Docker)

```bash
npm -g install @wordpress/env
```

Create a local `.wp-env.json` (not committed) at the repository root:

```json
{
  "core": "WordPress/WordPress#<wp-version>",
  "phpVersion": "8.3",
  "themes": [ "./development/lighthouse-church" ]
}
```

Then `wp-env start`, activate the theme in Appearance › Themes, and set the language to Français in Settings › General.

### Option C — Local by Flywheel or another desktop tool

Create a new site with a released WordPress version, then install the ZIP from `development/build-theme-zip.sh` (or the workflow artifact) through Appearance › Themes › Add New › Upload Theme.

### Test content

Create a small set of content clearly marked as test content, for example "[Contenu de test — à supprimer]":

- pages: Accueil (set as front page), À propos, Ministères with two child pages, Événements, Ressources, Actualités (set as posts page), Galerie (use the template "Full width page (no title)"), Donner, Contact;
- categories: Actualités, Événements, Ressources; 7 or more posts across them (enough for pagination);
- a navigation menu for the header and one for the footer.

Never copy production data into the test environment.

## 5. Manual test procedures

Record each result (pass / fail, browser, WordPress and PHP versions, date, tester) in the pull request or in the GitHub Issue for the task.

### 5.1 Mobile menu with the keyboard

Setup: browser window narrower than 600 px (or the browser's device toolbar at 375 px). Use Firefox or Chrome, and Safari if available.

| Step | Expected result |
|------|-----------------|
| Load any page and press Tab | The first focus is the "Aller au contenu" (skip to content) link, with a visible outline. |
| Continue with Tab to the menu button | The "Ouvrir le menu" button shows a visible outline. |
| Press Enter (then repeat with Space) | The menu opens as an overlay in night blue; focus moves into the menu (close button or first link). |
| Press Tab and Shift+Tab repeatedly | Focus stays inside the open menu; every link and the close button have a visible amber outline. |
| Press Escape | The menu closes; focus returns to the "Ouvrir le menu" button. |
| Reopen and activate the close button with Enter | Same as Escape. |
| Reopen, activate a link | The target page loads; the menu is closed on the new page. |
| Check the page behind the open menu | The page does not scroll; no content is reachable behind the overlay. |

### 5.2 Site Editor: loading and editing

| Step | Expected result |
|------|-----------------|
| Appearance › Editor | The Site Editor opens without errors; the home page preview uses the theme's fonts and colors. |
| Templates list | Shows Index, Blog home (home), Archives, Search results, Pages, Full width page (no title), Single posts, 404. |
| Open each template | No "This block contains unexpected or invalid content" warning on any block; no "missing pattern" placeholder. |
| Patterns › Template parts | Header, Footer and Post meta are listed and open without warnings. |
| Browser console (F12) | No JavaScript errors coming from the theme. |

### 5.3 Global styles, section styles, header and footer

| Step | Expected result |
|------|-----------------|
| Styles › Colors › Palette | The theme palette (Cream, Sand, White, Ink, Slate, Night blue, Deep sea, Amber, Dark amber, Mist, Line) is shown. Change one color, save, and check the front end; then reset it. |
| Styles › Typography | Lora and Source Sans 3 are listed and render in the editor; changing the heading font updates headings; reset afterwards. |
| Insert a Group block in a page, then Styles | "Night section", "Sand section" and "Card" are offered and render as on the front end. Inside a Night section, a default button and an "Outline" button are readable at rest and on hover. |
| Edit the header template part (e.g. change the Donner button link) and save | The front end shows the change. |
| Edit the footer template part (e.g. add a real social link URL in a test value) and save | The icon appears on the front end only once a URL is set. |
| Template part › "Reset" / "Clear customizations" | The theme's original header and footer come back. |

### 5.4 WordPress in French

Settings › General › Site language: Français, then save.

| Check | Expected result |
|-------|-----------------|
| Post dates, "Laisser un commentaire" form, search results title, pagination ("Page suivante") | In French (WordPress core strings). |
| Theme texts (header button, footer headings, 404 page, "Aucun résultat") | In French (written in French in the theme). |
| Accented letters, « guillemets » and "œ" | Rendered with the theme fonts, no fallback glyphs. |

### 5.5 Theme Check

In the disposable environment only: Appearance › Theme Check › select "LightHouse Church" › Check it.

- Record every **REQUIRED** item; each one must be fixed or explicitly accepted by the Project Coordinator.
- Record **RECOMMENDED** and **INFO** items with a short decision (fix / accept and why).
- Known expected item: no `screenshot.png` yet (planned after the homepage).

### 5.6 Screen reader quick pass (needs a person)

Use NVDA with Firefox (Windows) or VoiceOver with Safari (macOS/iOS). About 15 minutes.

| Check | Expected result |
|-------|-----------------|
| Landmarks list | Banner (header), two navigation regions with distinct names ("Menu principal", "Menu du pied de page"), main, content info (footer). |
| Headings list on a page, the posts page, an archive, search and 404 | Exactly one level-1 heading; logical order below it. |
| Skip link | Announced first; moves to the main content. |
| Mobile menu | The button is announced with its name and state; the open menu is announced as a dialog; Escape closes it. |
| Links and buttons | Every link and button has a meaningful name; empty social links are not announced. |
| Search form | The field is announced as "Rechercher" even though the label is visually hidden. |

## 6. Who does what

| Task | Can be automated or done by Claude Code | Needs a person |
|------|------------------------------------------|----------------|
| §2 automated checks | Yes (CI) | Review failures |
| §4 environment set-up | Partly (instructions) | Run it on a computer with Node.js or Docker and internet access to wordpress.org |
| §5.1–§5.5 | Partly, if a full environment is reachable (browser automation) | Final visual judgement |
| §5.6 screen reader | No | Yes |
| Production versions (P-005, P-012) | No (no access to Hostinger) | Yes, an authorized person |
