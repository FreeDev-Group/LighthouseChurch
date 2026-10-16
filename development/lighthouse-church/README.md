# LightHouse Church — WordPress block theme

Standalone Full Site Editing block theme for the LightHouse Church Bujumbura website (decision D-014 in `Doc/decisions.md`). Version 0.1.0, in development, not deployed.

## Requirements

| Item | Value | Status |
|------|-------|--------|
| WordPress | 6.6 or later | Provisional (P-012): Hostinger version not yet confirmed |
| PHP | 7.4 or later | Provisional (P-012): only tested with PHP 8.3 |
| Plugins | None | — |

Features that set the 6.6 minimum: `theme.json` version 3, section styles in `styles/sections/`, `defaultSpacingSizes`.

## Checks

```bash
development/check-theme.sh
```

Runs PHP syntax, JSON validity, theme header and ZIP build checks. The same script runs in the "Theme checks" GitHub workflow (`.github/workflows/theme-checks.yml`) on PHP 7.4 and 8.3. The full test plan, including the manual tests that need a complete WordPress installation, is in `Doc/theme-testing.md`.

## Build and install

```bash
development/build-theme-zip.sh
# -> dist/lighthouse-church-<version>.zip (git-ignored)
```

Install through **Appearance › Themes › Add New › Upload Theme**. Do not install on the production website without following `CLAUDE.md` §10 (backup, review, recovery procedure, verification).

## Structure

```text
lighthouse-church/
├── style.css            Theme header
├── theme.json           Global settings and styles (palette, fonts, sizes, spacing, blocks)
├── functions.php        Pattern categories, block styles, stylesheet
├── assets/css/theme.css Rules theme.json cannot express (focus, screen-reader text, reduced motion)
├── assets/fonts/        Self-hosted Lora and Source Sans 3 (WOFF2 + OFL licenses)
├── assets/images/       Original lighthouse mark (SVG, not used yet)
├── templates/           index, home, archive, search, page, page-full-width, single, 404
├── parts/               header, footer, post-meta
├── patterns/            header, footer and hidden helper patterns
└── styles/sections/     Section styles: night, sand, card
```

The header and footer template parts load the `lighthouse-church/header` and `lighthouse-church/footer` patterns, so their text is translatable. Once a part is edited in the Site Editor, WordPress stores the edited copy in the database and the theme file is no longer used for it.

## Customization (Site Editor)

- **Colors, fonts, sizes:** Appearance › Editor › Styles.
- **Section styles:** select a Group or Columns block, then Styles › *Night section*, *Sand section* or *Card*.
- **Block styles:** *Beam* (Separator), *Eyebrow* (Heading, Paragraph).
- **Menus:** edit the Navigation block in the header and footer. Without a menu, WordPress lists all pages automatically.
- **Templates:** *Full width page (no title)* is available for pages.

## Content model (provisional, D-017)

No custom post types. Ministries are pages (children of a "Ministères" page). News, events and resources are posts in the categories "Actualités", "Événements" and "Ressources".

## Provisional content

All of the following are placeholders and are **not validated**:

| Text or link | Location | Status |
|--------------|----------|--------|
| "Donner" button linking to `/donner/` | Header pattern | The page address is an assumption; edit the link once the Give page exists |
| Motto « Une Église au service de la ville de Bujumbura pour la gloire de Dieu » | Footer pattern | `[À CONFIRMER]` (P-013) |
| "Affiliée à REACH-SA" | Footer pattern | `[À CONFIRMER]` (P-013) |
| Address, e-mail, phone / WhatsApp, service times | Footer pattern | `[À CONFIRMER]` (P-008) |
| Social links (Facebook, YouTube, Instagram, WhatsApp) | Footer pattern | No URLs, so they are hidden on the site; choice of networks to confirm |
| "© LightHouse Church Bujumbura", footer headings | Footer pattern | Provisional wording |
| 404 and "no results" texts | Hidden patterns | Provisional wording |

## Translation

Pattern text is written in French (the primary website language) and wrapped in translation functions with the `lighthouse-church` text domain, so an English translation can be added later (P-004). Text typed directly into the Site Editor is content and is not translated by the theme.

## Fonts and licenses

| Font | Files | Copyright (read from the font files) | License | Provenance |
|------|-------|--------------------------------------|---------|------------|
| Lora 3.008 | `assets/fonts/lora/*.woff2` (weights 400–700, normal and italic) | Copyright 2011 The Lora Project Authors, with Reserved Font Name "Lora" | SIL OFL 1.1 (`OFL.txt`) | npm `@fontsource-variable/lora` 5.3.0, Latin subset |
| Source Sans 3 3.052 | `assets/fonts/source-sans-3/*.woff2` (weights 200–900, normal and italic) | © 2023 Adobe, with Reserved Font Name 'Source' | SIL OFL 1.1 (`OFL.txt`) | npm `@fontsource-variable/source-sans-3` 5.3.1, Latin subset |

The copyright lines were read from the `name` table inside each WOFF2 file. The Fontsource package for Source Sans 3 ships an incorrect attribution line ("Google Inc."); the theme's `OFL.txt` uses the copyright embedded in the font instead. The Latin subset covers French, including accented letters and « œ ».

## Known limits

- Events are ordered by publication date, not by event date; there is no calendar (no plugin, D-017).
- No language switcher (P-004).
- No logo or official photos yet; the site title is shown instead of a logo.
- `screenshot.png` is not included yet; it will be made once the homepage exists.
