# Theme test checklist — lighthouse-church

Common checklist for the FreeDEV test campaign of issue #9. Each tester runs the human tests (H-xx) assigned in §C on their own local site, set up with `Doc/testing/local-setup-guide.md`, and records the results in their own copy of `Doc/testing/report-template-individual.md`, posted as a comment on issue #9.

**Scope:** local test sites only. Never run these tests on the public website, on Hostinger or with Nova Mira.

**Target:** WordPress 7.1.3, PHP 8.3, the reference ZIP announced in issue #9. The expected results below describe the intended behavior of the theme; the earlier preliminary checks (WordPress 6.6-RC3, see `Doc/theme-testing.md`) do not replace these tests.

## How to record a result

For each test, write in your report:

| Field | What to write |
|-------|---------------|
| **Observed result** | What actually happened, in one or two sentences. |
| **Status** | `PASS` (matches the expected result), `FAIL` (does not match), `BLOCKED` (could not run the test; say why), or `N/A` (not applicable; say why). |
| **Evidence** | File names of screenshots or screen recordings, error messages copied as text, and the page URL on your test site. Name screenshots `<test-id>-<your-name>-<short-description>.png`, e.g. `H-06-alain-menu-ouvert.png`. |
| **Anomaly** | For each FAIL: open an entry in the "Anomalies" section of your report (see the template). |

Never put passwords, personal data or anything from the public website in screenshots.

## A. Automated checks (no action needed from testers)

These run on GitHub for every push to the pull request. The coordinator copies their result into the collective summary.

| ID | Check | Tool | Expected result | Evidence to keep |
|----|-------|------|-----------------|------------------|
| A-01 | PHP syntax of all theme files on PHP 7.4 and 8.3 | GitHub workflow "Theme checks" | Both jobs green | Link to the workflow run |
| A-02 | All theme JSON files are valid | Same | Green | Same |
| A-03 | `style.css` has the required headers and text domain | Same | Green | Same |
| A-04 | The ZIP builds with a single `lighthouse-church/` folder and the required files | Same | Green; artifact `lighthouse-church-theme` available | Link + SHA-256 of the inner ZIP |

PHP 7.4 stays in the CI for now as a provisional floor; it is **not** a confirmed requirement (P-012). Production uses PHP 8.3.

## B. Human tests

Run them in this order. Unless stated otherwise, use Firefox or Chrome on a computer, with the browser window at full width.

### H-01 — Install and activate the theme

| | |
|---|---|
| Steps | Follow guide §5–§6: check the checksum, upload the inner ZIP, activate. |
| Expected | Checksum matches the reference. Upload succeeds. "LightHouse Church 0.1.0" is the active theme. No error or warning on the Themes screen. The front page opens without a blank page or PHP error. |
| Evidence | Checksum output (text). Screenshot of Apparence › Thèmes with the active theme. |

### H-02 — Site Editor loads

| | |
|---|---|
| Steps | Apparence › Éditeur. Open **Modèles** and open each template one after the other. Open **Compositions › Parties de modèle** and open Header, Footer, Post meta. Keep the browser console open (F12 › Console). |
| Expected | The editor opens with the theme's colors and fonts. The template list contains the 8 theme templates: index, home (blog home), archive, search, page, page-full-width (shown as "Full width page (no title)"), single and 404; WordPress may show them with French names. Every template opens. No block shows an "unexpected or invalid content" warning. No "pattern missing" placeholder. No red error in the browser console coming from the theme. |
| Evidence | Screenshot of the template list. Screenshot of any warning. Console errors copied as text. |

### H-03 — Edit and save global styles

| | |
|---|---|
| Steps | Éditeur › Styles. (1) Couleurs › Palette: change "Night blue" to another color, save, open the front page in a new tab. (2) Typographie: change the heading font, save, check the front page. (3) Reset both changes (Styles › ⋮ › Réinitialiser) and save. |
| Expected | The palette lists: Cream, Sand, White, Ink, Slate, Night blue, Deep sea, Amber, Dark amber, Mist, Line. Lora and Source Sans 3 are offered and display correctly. Each change appears on the front end after saving. After reset, the original design comes back. |
| Evidence | Screenshots before / after / after reset of the same page. |

### H-04 — Edit the header and the footer

| | |
|---|---|
| Steps | Éditeur › Compositions › Parties de modèle › Header: change the "Donner" button text to "Donner (test)", save, check the front end. Footer: add a test URL `https://example.com` to the Facebook social link, save, check the front end. Then use **Réinitialiser** / "Clear customizations" on both parts. |
| Expected | Changes appear on the front end. The Facebook icon only appears once a URL is set. After reset, the theme's original header and footer return (button "Donner", no social icons). |
| Evidence | Screenshots of each step. |

### H-05 — Apply section styles

| | |
|---|---|
| Steps | Edit a test page. Add a **Groupe** block with a heading, a paragraph with a link, a default button and a button with the **Contour / Outline** style. In the block's Styles panel, apply **Night section**, then **Sand section**, then **Card**. Save and view the page. Hover over and Tab to each button. |
| Expected | The three styles are offered and render the same in the editor and on the front end. In Night section: light text, amber links, both buttons readable at rest and on hover, visible focus outline. |
| Evidence | One screenshot per style (editor and front end). |

### H-06 — Mobile navigation with the keyboard

| | |
|---|---|
| Setup | Browser window narrower than 600 px, or the browser's device mode (F12 › responsive mode, 375 × 800). |
| Steps | (1) Reload the page and press **Tab**. (2) Tab to the menu button and press **Enter**. (3) Press **Tab** and **Shift+Tab** many times. (4) Press **Escape**. (5) Reopen with **Space**, then activate the close button with Enter. (6) Reopen and choose a link. |
| Expected | (1) The first focus is the "skip to content" link, visibly outlined. (2) The menu opens over the page in night blue; focus moves into the menu. (3) Focus stays inside the open menu; every item shows a visible amber outline. (4) The menu closes and focus returns to the menu button. (5) Same as (4). (6) The chosen page opens with the menu closed. |
| Evidence | Short screen recording (preferred) or screenshots of steps 2, 3 and 4. |

### H-07 — Keyboard walkthrough (desktop)

| | |
|---|---|
| Steps | On the front page, an article, the Actualités page, a category, a search result page and a 404 page (e.g. `/page-inexistante/`), go through the whole page with **Tab** only. Use Enter on the skip link. |
| Expected | Every link, button and field is reachable in a logical order. Focus is always visible (night blue outline on light backgrounds, amber on dark backgrounds). The skip link moves focus to the main content. No keyboard trap. |
| Evidence | Screenshots of focus on the header, a card, the footer. Note any element with no visible focus. |

### H-08 — French display

| | |
|---|---|
| Steps | Check that Réglages › Général › Langue du site = Français. Visit an article, the Actualités page, a search result page, the 404 page and the comment form of an article. |
| Expected | WordPress texts (dates, comment form, search results title, pagination, menu button) are in French. Theme texts (Donner, footer headings, 404 page, "Aucun résultat") are in French. Accented letters, « guillemets » and "œ" display with the theme fonts. |
| Evidence | Screenshots of the article, the search page and the 404 page. Note any English text. |

### H-09 — Responsive display

| | |
|---|---|
| Steps | Using the browser's responsive mode, view the front page, a page, an article, the Actualités page and the Galerie page at widths **375**, **768** and **1280** px. Then at 1280 px, zoom the browser to **200%** (Ctrl/Cmd and +). |
| Expected | At every width: no horizontal scroll bar, no text cut off or overlapping, every link and button reachable. Cards stack to one column at 375 px. The mobile menu button replaces the menu below 600 px. At 768 px the menu may wrap to two lines: this is a PASS if nothing overlaps and every item stays readable and clickable; attach a screenshot either way. At 200% zoom, all content stays usable without horizontal scrolling. |
| Evidence | One screenshot per width for the front page and the Actualités page; one at 200% zoom. |

### H-10 — Theme Check (test site only)

| | |
|---|---|
| Steps | Apparence › Theme Check › choose "LightHouse Church" › **Check it!** |
| Expected | No **REQUIRED** item. RECOMMENDED / INFO items are listed for the coordinator to decide. Known expected item: no `screenshot.png` yet. |
| Evidence | Copy the full result as text into the report (or save the page as PDF). |

### H-11 — Accessibility spot checks (browser)

| | |
|---|---|
| Steps | On the front page, an article and the Actualités page: open the browser's accessibility tools (Firefox: F12 › Accessibilité › Vérifier les problèmes; Chrome: Lighthouse › Accessibility) and run them. |
| Expected | No contrast or "missing name" problem caused by the theme. Exactly one level-1 heading per page. |
| Evidence | Screenshot or copied list of issues. |

### H-12 — Screen reader quick pass (needs NVDA or VoiceOver)

Only for testers with a screen reader. About 15 minutes.

| | |
|---|---|
| Steps | NVDA + Firefox (Windows) or VoiceOver + Safari (macOS). On the front page, an article and the 404 page: list the landmarks (NVDA: Insert+F7; VoiceOver: VO+U), list the headings, use the skip link, open the mobile menu (narrow window) and close it with Escape, move to the search field. |
| Expected | Landmarks: banner, two navigation regions with different names ("Menu principal" and "Menu du pied de page"), main, contentinfo. One level-1 heading, logical order below it. Skip link announced first. Menu button announced with its name and state; the open menu is announced as a dialog. Search field announced as "Rechercher". Empty social links are not announced. |
| Evidence | Written notes of what was announced; optional audio/screen recording. |

### H-13 — Errors and logs

| | |
|---|---|
| Steps | During all tests, keep the browser console open. In Local, also enable debug logging before you start (site shell: `wp config set WP_DEBUG true --raw` and `wp config set WP_DEBUG_LOG true --raw`), then at the end open `wp-content/debug.log` (in Local, open the site folder from the site menu, then `app/public/wp-content/`). In Playground, only check the browser console and write "debug.log not available" in your report. |
| Expected | No PHP warning or error mentioning `lighthouse-church`. No JavaScript error caused by the theme. |
| Evidence | Relevant lines of `debug.log` and console errors, as text. |

## C. Who runs what

| Test | Who | Notes |
|------|-----|-------|
| H-01 to H-09, H-13 | **Every tester** | Required in every individual report. |
| H-10 Theme Check | At least one tester | One result is enough because everyone uses the same reference ZIP. |
| H-11 browser accessibility tools | At least one tester | |
| H-12 screen reader | One tester who has NVDA or VoiceOver | Named by the coordinator in issue #9. |

Testers who do not run H-10, H-11 or H-12 mark them `N/A — assigned to another tester` in their report. The campaign is complete when every tester has reported H-01 to H-09 and H-13, and H-10, H-11 and H-12 each have at least one valid result.
