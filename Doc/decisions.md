# LightHouse Church Bujumbura — Decision Register

This register records project decisions and pending questions. Only entries with status **Confirmed** are approved project directions. Everything else must not be treated as decided.

Status values:

- **Confirmed**: approved project direction.
- **Provisional**: approved by the Project Coordinator as a working direction, subject to a condition stated in the notes. It may still change.
- **Pending confirmation**: unresolved, needs a decision.
- **Superseded**: replaced by a later decision (reference the new ID).

To add or change a decision, open or reference a GitHub Issue and have the Project Coordinator (Salomon) confirm it. Never back-date entries or invent approvals. Leave the date as "—" when it is not known.

---

## 1. Decisions

Source: instructions from the Project Coordinator (Salomon). D-000 to D-013 were recorded on 2026-10-12; their original decision dates are not documented. D-014 to D-017 and the changes to D-002 and D-003 were approved on 2026-10-13.

| ID | Topic | Decision or proposed direction | Status | Date | Notes or required confirmation |
|----|-------|--------------------------------|--------|------|-------------------------------|
| D-000 | Project and church name | The official project and church name is **LightHouse Church Bujumbura**. | Confirmed | — | The requirements PDF (v0.1) uses "LePhare Bujumbura". Whether the PDF's shared LePhare multi-site structure still applies is pending (see P-001). |
| D-001 | CMS | WordPress is the planned CMS. | Confirmed | — | The requirements PDF (v0.1, §26) only says WordPress "may be considered". This register reflects the coordinator's later decision. |
| D-002 | Parent theme | Twenty Twenty-Five (directory `twentytwentyfive`) is the planned parent theme. | Superseded | 2026-10-13 | Superseded by D-014. A standalone block theme avoids depending on a parent theme whose updates could change the site's design, and gives the project full control over templates, patterns and styles. |
| D-003 | Child theme | `lighthouse-child` is the planned custom child theme, located at `development/lighthouse-child/`. | Superseded | 2026-10-13 | Superseded by D-014 for the same reason. The child theme was never created. |
| D-004 | Development approach | Full Site Editing with `theme.json` for global settings. Native blocks preferred and custom CSS kept to a minimum. | Confirmed | — | |
| D-005 | Page builders | No page builder without explicit approval from the Project Coordinator. | Confirmed | — | |
| D-006 | Plugins | Every plugin must be evaluated and approved before installation. | Confirmed | — | Record each approved plugin as a new entry in this register. |
| D-007 | Languages | French primary, English secondary. Kirundi may be considered for a later phase. | Confirmed | — | The implementation method is pending (see P-004). |
| D-008 | Source of truth | GitHub is the source of truth for source code and technical documentation. WordPress holds the editable website content. | Confirmed | — | GitHub is not used to store the WordPress database. |
| D-009 | Environments | A single WordPress production environment on Hostinger. Development, testing and deployment take place in this environment. Separate DEV and STAGING environments will not be used. | Confirmed | — | Supersedes the DEV → STAGING → PRODUCTION workflow described in `README.md` (README not yet updated, see P-010). Safeguards are in D-011. |
| D-010 | Repository language | Repository content (documentation, decisions, Issues, PRs, commit messages, code comments) is written in English. Conversations with the Project Coordinator are in French. | Confirmed | — | French content written for the church's website audience is kept in French and is not translated for this rule. |
| D-011 | Production workflow safeguards | Because all work happens on the live website: (1) back up WordPress files and the database before significant changes; (2) review code in GitHub before deploying it; (3) have a practical recovery procedure for failures; (4) make small, controlled changes; (5) verify the website immediately after each deployment; (6) never expose credentials or secrets in the repository; (7) never claim Hostinger, WordPress, backups or deployment mechanisms are configured unless verified. | Confirmed | — | The concrete backup and recovery procedure (P-009) and the post-deployment checklist (P-007) are not yet defined. No deployment until P-009 is resolved. |
| D-012 | Nova Mira | No Nova Mira access to, or automated modification of, the production website without a separate explicit approval from the Project Coordinator **and** an agreed safety procedure. Any code changed through Nova Mira must be reviewed and synchronized back to GitHub. | Confirmed | — | Approval and the safety procedure are pending (see P-011). |
| D-013 | Documentation directory | `Doc/` remains the current documentation directory. Renaming it is not a priority and is not authorized. | Confirmed | — | `README.md` and `Doc/website-navigation.md` still refer to `docs/` (see P-010). |
| D-014 | Theme architecture | A standalone, original Full Site Editing block theme named **LightHouse Church** (slug and text domain `lighthouse-church`), located at `development/lighthouse-church/` and installable as a ZIP. No parent theme, no page builder. | Confirmed | 2026-10-13 | Approved in principle by the Project Coordinator, subject to technical review and the corrections listed in the theme audit. Replaces D-002 and D-003. Minimum versions are provisional (P-012). |
| D-015 | Visual direction | Direction A, "Lighthouse and shore": night blue, amber and cream palette; Lora for headings and Source Sans 3 for body text. | Provisional | 2026-10-13 | Subject to final validation of the palette and of the screenshots. All global styles remain editable in the Site Editor. |
| D-016 | Fonts | Fonts are self-hosted in the theme (variable WOFF2, Latin subset, SIL Open Font License 1.1). No calls to external font services. | Confirmed | 2026-10-13 | Confirmed by the Project Coordinator on 2026-10-13 after license verification. Verified files: Lora 3.008 (npm `@fontsource-variable/lora` 5.3.0, Latin subset, weights 400–700, normal and italic; embedded copyright: "Copyright 2011 The Lora Project Authors, with Reserved Font Name “Lora”"); Source Sans 3 3.052 (npm `@fontsource-variable/source-sans-3` 5.3.1, Latin subset, weights 200–900, normal and italic; embedded copyright: "© 2023 Adobe, with Reserved Font Name 'Source'"). Copyright and license read from each WOFF2 file's name table; OFL 1.1 texts shipped in `assets/fonts/*/OFL.txt`. This decision covers fonts and licensing only; it is not a validation of the theme's accessibility or compatibility. |
| D-017 | Theme content model | No custom post types in the theme. Ministries are pages; news, events and resources are posts organized by category. | Provisional | 2026-10-13 | Working approach. Do not create custom post types without a validated need. Known limit: events are ordered by publication date, not event date; an events plugin would need approval (D-006). |

---

## 2. Pending confirmation

| ID | Topic | Decision or proposed direction | Status | Date | Notes or required confirmation |
|----|-------|--------------------------------|--------|------|-------------------------------|
| P-001 | Shared LePhare structure | Unresolved: does the requirements PDF's "common LePhare website structure" (shared with Bukavu and Goma) still apply to LightHouse Church Bujumbura? | Pending confirmation | — | Determines whether the theme must be reusable across several sites. |
| P-002 | Requirements approval | Unresolved: has the requirements PDF received formal stakeholder approval? | Pending confirmation | — | The PDF is v0.1, "Draft, Pending Stakeholder Review". `Doc/website-navigation.md` §12 states that the structure "has already been reviewed and confirmed". No approval record exists in the repo. |
| P-003 | Navigation labels | Unresolved: final French and English menu labels. | Pending confirmation | — | Labels differ between the PDF ("Sermons & Resources", "Give / Donations"), `website-navigation.md` ("Sermons / Resources", "Giving / Support") and the coordinator's brief ("Ressources / Resources", "Donner / Give"). French labels are not yet documented in the repo. |
| P-004 | Multilingual implementation | Unresolved: how English (and possibly Kirundi later) will be delivered. | Pending confirmation | — | Options include a translation plugin (requires approval per D-006), WordPress Multisite, or deferring English to a later phase. |
| P-005 | Hostinger configuration | Unresolved: exact Hostinger plan and production environment configuration. | Pending confirmation | — | To confirm: plan, domain, PHP version, SSL, available backup tools, and who has hPanel and WordPress administrator access. Nothing has been verified on Hostinger yet. |
| P-006 | Deployment method | Unresolved: how reviewed theme code moves from GitHub to the production website. | Pending confirmation | — | Options include Hostinger Git deployment, SFTP/SSH, or manual ZIP upload. |
| P-007 | Post-deployment verification and change window | Unresolved: the exact verification checklist to run after each deployment, and whether changes should be made at low-traffic times. | Pending confirmation | — | `CLAUDE.md` §10 lists a minimum check: affected pages, homepage, navigation, mobile view, no PHP errors or blank pages. |
| P-008 | Contact number | Unresolved: is the WhatsApp number in the content files correct, and may it be published? | Pending confirmation | — | The number in `Doc/LightHouse Church Documentation, Yusse/Contact/` uses the +243 country code (DR Congo), not +257 (Burundi). To be validated by the Content Coordinator with the church before publication. |
| P-009 | Backup and recovery procedure | Unresolved: the concrete backup and recovery procedure for the production website. | Pending confirmation | — | To define: backup tool (e.g. Hostinger backups or another approved method), where backups are stored, who can restore, how a restore is tested, and how a failed code deployment is reverted. Required before the first deployment (D-011). |
| P-010 | README alignment | Unresolved: when to update `README.md` and `Doc/website-navigation.md` to match the confirmed decisions. | Pending confirmation | — | `README.md` still describes DEV and STAGING environments, says the production host is not yet selected, and refers to `docs/`. `Doc/website-navigation.md` refers to `docs/`. Not changed in this task. |
| P-011 | Nova Mira approval | Unresolved: whether and when Nova Mira may access the production website, and the safety procedure it must follow. | Pending confirmation | — | Requires a separate explicit approval from the Project Coordinator (D-012) and depends on P-009. |
| P-012 | Minimum WordPress and PHP versions | Unresolved: the theme currently declares WordPress 6.6 and PHP 7.4 as minimums. | Pending confirmation | — | Provisional until the WordPress and PHP versions on Hostinger are confirmed (P-005). Testing so far: WordPress 6.6-RC3 with PHP 8.3 in a local, disposable environment only. |
| P-013 | Footer motto and affiliation | Unresolved: may the motto "Une Église au service de la ville de Bujumbura pour la gloire de Dieu" and the REACH-SA affiliation be published on the website? | Pending confirmation | — | Both come from the Content Coordinator's draft "About us" file. They are shown in the theme footer marked `[À CONFIRMER]` until validated. |
