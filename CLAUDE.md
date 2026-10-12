# CLAUDE.md — Instructions for Claude Code

These rules apply to every Claude Code conversation in this repository. The team shares one Claude account across separate conversations, so **follow the repository documentation, not conversation memory**.

## 1. Project identity and scope

- **Project and church name:** LightHouse Church Bujumbura. Maintained by the FreeDEV team.
- **CMS:** WordPress. Parent theme Twenty Twenty-Five (`twentytwentyfive`), custom child theme `lighthouse-child`, planned at `development/lighthouse-child/`.
- **Hosting:** a single WordPress production environment on Hostinger. Development, testing and deployment take place in this environment. Separate DEV and STAGING environments will not be used (see `Doc/decisions.md`, D-009). Follow §10 for every change.
- **Key documents:**
  - `README.md` — project overview and workflow
  - `Doc/LightHouse-Church-Website-Project-Requirements.pdf` — requirements (draft v0.1)
  - `Doc/website-navigation.md` — navigation principles
  - `Doc/decisions.md` — decision register (**check it before any technical choice**)
  - `Doc/LightHouse Church Documentation, Yusse/` — client content provided by the Content Coordinator
- `Doc/` is the current documentation directory. Do not rename or move it.

## 2. Team and authority

| Person  | Role |
|---------|------|
| Salomon | Mentor and Project Coordinator: technical decisions, reviews, approval of architectural changes |
| Yusse   | Content Coordinator: client content and its validation |
| Alain   | Team Member |
| David   | Team Member |

Task ownership is assigned through GitHub Issues.

## 3. Language policy

- **Conversation:** communicate with Salomon in French, including progress reports, explanations, questions and completion reports.
- **Repository:** write everything in English. This covers documentation, `CLAUDE.md`, `Doc/decisions.md`, GitHub Issues and Pull Requests, commit messages, and code comments.
- **Exception:** content written for the church's website audience stays in French (the primary website language). Never translate client website content into English just to follow this rule.

## 4. Decisions and conflicts

- Only entries marked **Confirmed** in `Doc/decisions.md` are approved. Your own suggestions are proposals, never decisions.
- Do not change the approved website structure or navigation without approval.
- When documents conflict (for example the requirements PDF vs. the README vs. the navigation document), **name the conflict and ask the coordinator**. Do not silently pick a version.
- If information is missing, document the question rather than inventing an answer.

## 5. Git and branch safety

- Work only on the branch assigned for the task. Check `git status` before starting. If the working tree is not clean, stop and report.
- Never reset, rebase, force-push, merge, or delete branches unless explicitly instructed.
- Do not commit, push, or open a pull request unless the task explicitly asks for it.
- Never change repository settings, branch protection, or milestones.
- Never delete, overwrite, or move existing work (including the content files and the requirements PDF) without explicit authorization.

## 6. Task scope and reporting

- **One task = one owner = one active editor** for the affected element. Do not edit a file, template, or WordPress element that another team member is responsible for.
- Stay inside the task's scope and don't touch unrelated files.
- At the end of each task, report: files created / modified / removed, important technical choices and assumptions, open questions, and branch and working-tree status.

## 7. WordPress development approach

- Use Full Site Editing: block templates (`templates/`), template parts (`parts/`), block patterns (`patterns/`), with global styles and settings in `theme.json`.
- Prefer native WordPress blocks. Keep custom CSS minimal and custom PHP small and documented.
- Never modify the parent theme. All customization goes in `lighthouse-child`.
- **No page builders** without explicit coordinator approval.
- **No plugins** until they have been evaluated and approved (record the outcome in `Doc/decisions.md`).
- Write accessible, responsive and maintainable code:
  - semantic headings
  - keyboard navigation and visible focus
  - sufficient color contrast
  - meaningful alt text and link text
  - layouts that work on mobile, tablet and desktop

## 8. Website content

- French is the primary language and English the secondary one. Kirundi may be considered for a later phase.
- Mark any unverified information with **`[À CONFIRMER]`**.
- **Never invent:**
  - the address, telephone numbers, email addresses or social media accounts
  - payment, bank or mobile-money details
  - leadership names, service times or historical facts
- Never rewrite doctrinal statements or Bible references. Use the client-provided text as is, unless the Content Coordinator has supplied a validated version.
- Do not enable online payments without explicit approval.

## 9. Security

- Never commit credentials, passwords, API keys, `wp-config.php`, `.env` files with secrets, database dumps, backups, WordPress uploads, production data, or generated installation ZIPs.
- Never put credentials in code, documentation, issues, or commit messages.

## 10. Production workflow and safety

All development, testing and deployment happen on the public production website. That is **not** permission to make unreviewed or uncontrolled changes to it.

1. **GitHub is the source of truth** for code and technical documentation. Any code changed in WordPress must be synchronized back to GitHub.
2. **Back up first.** Before any significant change, back up the WordPress files **and** the database, and confirm the backup completed.
3. **Review before deploying.** Code is reviewed in GitHub (pull request approved by Salomon) before it is deployed.
4. **Have a recovery path.** A practical recovery procedure (how to restore the backup or revert the change) must be agreed before the first deployment. Until it is documented in `Doc/decisions.md`, do not deploy.
5. **Keep changes small and controlled.** Deploy one reviewed change at a time, within the scope of one task.
6. **Verify immediately after deploying.** At minimum, check:
   - the affected pages and the homepage
   - navigation
   - the mobile view
   - that there are no PHP errors or blank pages

   If anything is broken, recover at once and report it.
7. **Nothing unapproved.** Do not install or activate themes or plugins, change settings, or deploy unless the task explicitly calls for it and Salomon has approved it.
8. **Nova Mira:** no access to, and no automated modification of, the production website without a separate explicit approval from Salomon **and** an agreed safety procedure. Any code changed through Nova Mira must then be reviewed and synchronized back to GitHub before the task counts as complete.
9. **Never claim** that Hostinger, WordPress, backups, or deployment mechanisms are configured or working unless you have actually verified it. If you cannot access an environment, say so.
