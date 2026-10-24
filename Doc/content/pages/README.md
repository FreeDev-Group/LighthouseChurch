# Initial pages of the website

Starting content for the nine pages of the main menu (`Doc/website-navigation.md` §2, French labels in `Doc/decisions.md` D-018). Each `.html` file holds the block markup of one page, made only of native WordPress blocks, so the pages stay editable in the block editor (D-004, D-005).

The text is in French, the website's primary language. Client text from `Doc/LightHouse Church Documentation, Yusse/` is used word for word. Everything else is provisional:

- `[Texte provisoire]` marks a neutral placeholder to be replaced by validated content.
- `[À CONFIRMER]` marks information that is not validated yet (address, service times, e-mail, phone, motto and affiliation, P-008, P-013).

No address, phone number, e-mail address, service time, leader, event, photo, or payment detail has been added. The "Donner" page states that giving information will be communicated by the Church (D-019).

## Pages

| Order | Title | Slug | Template | File | Content |
|-------|-------|------|----------|------|---------|
| 1 | Accueil | `accueil` | Full width page (no title) | `01-accueil.html` | Hero (title, Philippiens 2:15–16, two buttons from the client file), "Qui sommes-nous ?" and "Notre Mission" (client text), events and ministries (provisional), latest posts (automatic), giving and visit (provisional) |
| 2 | À propos | `a-propos` | Default (Pages) | `02-a-propos.html` | Client "About us" text, sections 1–7; affiliation and motto `[À CONFIRMER]`; history provisional |
| 3 | Ministères | `ministeres` | Default | `03-ministeres.html` | Provisional |
| 4 | Événements | `evenements` | Default | `04-evenements.html` | Provisional, links to Actualités and Contact |
| 5 | Ressources | `ressources` | Default | `05-ressources.html` | Provisional |
| 6 | Actualités | `actualites` | Default | `06-actualites.html` | Posts page: WordPress lists the posts here; the page text is not displayed |
| 7 | Galerie | `galerie` | Default | `07-galerie.html` | Provisional, no images |
| 8 | Donner | `donner` | Default | `08-donner.html` | Provisional, no payment method (D-019); target of the header "Donner" button |
| 9 | Contact | `contact` | Default | `09-contact.html` | E-mail, phone, address and service times `[À CONFIRMER]` |

Internal links are relative (`/a-propos/`, `/contact/`, …). They require WordPress at the root of the domain and pretty permalinks (Settings › Permalinks › "Post name").

## Creating the pages

Create them as **drafts**, check them, then publish. Two methods give the same result.

### Method A — WordPress admin (no server access needed)

For each row of the table:

1. Pages › Add New. Title: as in the table.
2. Editor menu ⋮ › **Code editor**. Paste the whole content of the `.html` file. Back to the **Visual editor**: no block may show "This block contains unexpected or invalid content".
3. Page panel › **Slug**: as in the table. **Template**: "Full width page (no title)" for Accueil only. **Order**: as in the table.
4. Save draft.

### Method B — WP-CLI over SSH (if available on the hosting)

Copy `development/deploy/create-pages.php` and this folder to the server, then, from the WordPress root:

```bash
wp eval-file create-pages.php                              # dry run: lists what would be created
wp eval-file create-pages.php pages /path/to/pages-folder  # creates the missing pages as drafts
```

The script never changes or deletes an existing page: a page whose slug already exists is skipped and reported.

## After the pages are published

1. **Settings › Reading:** "Your homepage displays" = A static page; Homepage = **Accueil**; Posts page = **Actualités**.
2. **Main menu:** Appearance › Editor › Navigation: create "Menu principal" with the nine pages in the table order. Or with WP-CLI: `wp eval-file create-pages.php menu` (refuses to run until all nine pages are published). The header and the footer of the theme use this menu.
3. Check that each menu entry opens its page.

## Editing the content later

- Text: Pages › choose the page › click the text and type. Replace each `[Texte provisoire]` and `[À CONFIRMER]` only with content validated by the Content Coordinator.
- Images and gallery: add an **Image** or **Galerie** block and upload approved photos to the Media Library. Free-licensed stock photos may be used temporarily if their licence is recorded with the file; never present them as photos of the Church.
- Events, news and resources: publish **posts** in the categories "Événements", "Actualités" and "Ressources" (D-017). The latest posts appear automatically on the homepage and on the Actualités page.
- Footer and header (contact lines, social links, "Donner" button): Appearance › Editor › Patterns › Template parts.
