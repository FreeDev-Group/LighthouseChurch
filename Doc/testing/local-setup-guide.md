# Local WordPress setup guide for theme testing

For: every FreeDEV team member taking part in the theme test campaign (issue #9).
Level: beginner. No Docker, no command line experience required.
Time: about 45 minutes the first time.

> **Safety rules — read first**
>
> - Everything in this guide happens **on your own computer**, in a private test site.
> - **Never** log in to, test on, or change the public website, the Hostinger dashboard, or Nova Mira.
> - **Never** install the test plugins (Theme Check) on the public website.
> - Never copy real data from the public website into your test site.
> - Your test site's username and password are for your computer only. Do not share them in GitHub, screenshots or chat.

## 1. Target versions

All testers use the same versions, so that results can be compared:

| Item | Version | Why |
|------|---------|-----|
| WordPress | **7.1.3** | Version used on the production hosting (communicated by the Project Coordinator) |
| PHP | **8.3** (latest 8.3.x offered by the tool) | Production uses PHP 8.3.35 |
| Theme | The **reference ZIP** announced by the coordinator in issue #9 (see §5) | Everyone tests the exact same build |
| Site language | Français | Primary website language |

## 2. What you need

- A computer with Windows 10/11, macOS 12 or later, or Ubuntu/Debian Linux.
- About 3 GB of free disk space.
- Internet access (to download Local, WordPress and the French language pack).
- A recent browser: Firefox or Chrome. Safari too if you use a Mac.
- A GitHub account with access to `FreeDev-Group/LighthouseChurch` (to download the reference ZIP).
- For the screen reader test (§ checklist T-12): NVDA (free, Windows) or VoiceOver (built into macOS).

## 3. Method A (recommended): Local

[Local](https://localwp.com/) is a free desktop application that runs WordPress on your computer with one click. It does not need Docker.

### 3.1 Install Local

1. Go to https://localwp.com/ and download Local for your system. (The site asks for a name and e-mail; you can use your FreeDEV e-mail.)
2. Install it like any other application and open it.

### 3.2 Create the test site

1. Click **+ Create a new site** › **Create a new site** › Continue.
2. Site name: `lighthouse-test` › Continue.
3. Choose **Custom**:
   - PHP version: the highest **8.3.x** in the list. If Local offers no 8.3.x, choose the closest 8.x, write the version in your report and tell the coordinator in issue #9.
   - Web server: nginx (default is fine).
   - Database: MySQL (default is fine).
4. WordPress username: `admin` (or your choice). Choose a password you only use for this test site. E-mail: any address, e.g. `test@example.test`.
5. Click **Add site** and wait until the site shows as running.

### 3.3 Set WordPress to exactly 7.1.3

Local installs the newest WordPress by default, which may not be 7.1.3.

1. In Local, select the site, then click **Open site shell** (a terminal window opens, already in the right folder).
2. Type these commands one by one, pressing Enter after each:

   ```text
   wp core version
   ```

   If the answer is not `7.1.3`, run:

   ```text
   wp core update --version=7.1.3 --force
   wp core update-db
   wp core version
   ```

   The last command must print `7.1.3`.

3. Install and activate French:

   ```text
   wp language core install fr_FR --activate
   ```

4. Turn off automatic WordPress updates for this test site, so the version stays at 7.1.3:

   ```text
   wp config set WP_AUTO_UPDATE_CORE false --raw
   ```

5. Write down the exact PHP version:

   ```text
   wp eval "echo PHP_VERSION;"
   ```

### 3.4 Open the site

In Local, click **WP Admin** to open the dashboard (log in with the username and password from step 3.2) and **Open site** to see the front end.

## 4. Method B (backup): WordPress Playground in the browser

Use this only if Local cannot be installed on your computer. Nothing is installed, but the site **disappears when you close the tab** unless you save it in the browser.

1. Open `https://playground.wordpress.net/?wp=7.1.3&php=8.3`.
2. Check the WordPress version under Tools › Site Health › Info. If Playground did not load 7.1.3, write the version you got in your report and tell the coordinator in issue #9.
3. Settings › General › Site Language: choose Français and save.
4. Continue with §5 and §6 in the same tab. Steps that use the site shell (`wp ...` commands) are not available in Playground; use the WP Admin alternatives given in each step.

Playground runs PHP in the browser, so a few results (performance, e-mail, some server errors) can differ from a real server. Say in your report that you used Playground.

## 5. Get the reference theme ZIP

Everyone must test **the same file**. Building the ZIP yourself is not allowed for the test campaign, because two builds of the same commit produce different files.

1. The coordinator announces in a comment on **issue #9**:
   - the **reference commit**;
   - the **link to the GitHub Actions run** for that commit;
   - the **SHA-256 checksum** of `lighthouse-church-0.1.0.zip`.
2. Open the Actions run link, scroll to **Artifacts**, and download `lighthouse-church-theme`. GitHub gives you a file named `lighthouse-church-theme.zip`.
3. **Unzip it once.** Inside is `lighthouse-church-0.1.0.zip`. This inner file is the theme. Do **not** unzip the inner file.
4. Check the checksum of the inner file:
   - Windows (PowerShell): `Get-FileHash .\lighthouse-church-0.1.0.zip -Algorithm SHA256`
   - macOS / Linux (Terminal): `shasum -a 256 lighthouse-church-0.1.0.zip`

   The result must match the checksum announced by the coordinator. If it does not, stop and tell the coordinator.

GitHub keeps workflow artifacts for 30 days. If the link has expired, ask the coordinator in issue #9 for a new reference build. **Never build the ZIP yourself for the campaign.**

## 6. Install and activate the theme

1. WP Admin › **Apparence › Thèmes › Ajouter un thème › Téléverser un thème**.
2. Choose `lighthouse-church-0.1.0.zip` › **Installer maintenant** › **Activer**.
3. Check: Apparence › Thèmes shows **LightHouse Church 0.1.0** as the active theme.

## 7. Basic settings and test content

1. **Réglages › Permaliens**: choose **Titre de la publication** › Enregistrer.
2. Create the test content below. Put **[Contenu de test — à supprimer]** in every text you write, so test content can never be mistaken for real content.

| Type | Items |
|------|-------|
| Pages | Accueil, À propos, Ministères, Événements, Ressources, Actualités, Galerie, Donner, Contact |
| Child pages of "Ministères" | Ministère test 1, Ministère test 2 |
| Categories | Actualités, Événements, Ressources |
| Posts | At least 10 posts spread across the three categories (to get two pages of results). Give some of them a featured image (any free test image). |

3. **Réglages › Lecture**: "Une page statique"; page d'accueil = Accueil; page des articles = Actualités › Enregistrer.
4. For the "Galerie" page, choose the template **Full width page (no title)** in the page settings.
5. **Menus**: in Apparence › Éditeur › Navigation, create a menu "Menu principal (test)" with the pages À propos, Ministères, Événements, Ressources, Actualités, Galerie, Contact.

Optional shortcut (Local only), in the site shell, to create 10 test posts quickly (then assign their categories in Articles › Tous les articles):

```text
wp post generate --post_type=post --count=10 --post_title="[Contenu de test — à supprimer]"
```

## 8. Install Theme Check (test site only)

In the site shell:

```text
wp plugin install theme-check --activate
```

Or WP Admin › Extensions › Ajouter › search "Theme Check" › Installer › Activer.

**Never install it on the public website.**

## 9. Record your versions and start testing

1. Copy `Doc/testing/report-template-individual.md` and fill in its "Environment" section: WordPress version, PHP version, method (Local or Playground), theme reference commit and checksum, browser and version, operating system.
2. Run the tests in `Doc/testing/test-checklist.md`.
3. When you are done, post your completed report and your screenshots as a comment on **issue #9**.

## 10. Troubleshooting

| Problem | What to do |
|---------|------------|
| Local does not start the site | Restart Local; on Windows, allow it through the firewall when asked. |
| `wp core update --version=7.1.3` fails | Check your internet connection, then try again. If it still fails, write the error in your report and tell the coordinator. |
| Upload fails: "The package could not be installed. The theme is missing the style.css stylesheet." | You uploaded the outer `lighthouse-church-theme.zip`. Unzip it once and upload the inner `lighthouse-church-0.1.0.zip`. |
| The site is in English | Run `wp language core install fr_FR --activate`, or Réglages › Général › Langue du site. |
| Something else | Write what you did, what happened and a screenshot in your report, and ask in issue #9. Do not try to fix theme code yourself during the test campaign. |

## 11. After the test campaign

You may delete the test site in Local (right-click › Delete). Do not keep test passwords in shared places.
