#!/bin/bash
# LightHouse Church operations on the Hostinger server, one or more steps per run.
#
#   LHC_SITE=prod|staging LHC_REF=<commit SHA> bash lhc-steps.sh <step> [<step> ...]
#
# LHC_SITE chooses the WordPress installation; there is no default, so a command can never reach
# production by omission. LHC_REF is the commit (7 to 40 hex characters) whose repository files are used.
# Started from a short-lived hPanel cron job (commands are limited to 255 characters), for example:
#   cd ~/lhc-ops&&curl -sSfO <raw URL of this file at LHC_REF>&&LHC_SITE=staging LHC_REF=<sha> bash lhc-steps.sh inventory
# A finished step only prints its log again, so the cron job can fire more than once safely. A failed step
# stops the run and stays failed: re-run it under a new name ("backup.2" runs "backup" with a new log).
# Steps are listed in the case statement below (see Doc/deployment/).
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin"
PROD_DOMAIN="lighthousechurchbujumbura.org"; STAGING_DOMAIN="staging.lighthousechurchbujumbura.org"
PROD_WP="$HOME/domains/$PROD_DOMAIN/public_html"
case "$LHC_SITE" in
prod)    WP="$PROD_WP"; URL="https://$PROD_DOMAIN"; S="$HOME/lhc-ops"; BK="$HOME/lhc-backups" ;;
staging) WP="$HOME/domains/$STAGING_DOMAIN/public_html"; URL="https://$STAGING_DOMAIN"; S="$HOME/lhc-ops-staging"; BK="$HOME/lhc-backups-staging" ;;
*) echo "refused: set LHC_SITE=prod or LHC_SITE=staging"; exit 1 ;;
esac
[[ "$LHC_REF" =~ ^[0-9a-f]{7,40}$ ]] || { echo "refused: set LHC_REF to a commit SHA"; exit 1; }
[ $# -gt 0 ] || { echo "usage: LHC_SITE=prod|staging LHC_REF=<sha> bash lhc-steps.sh <step> ..."; exit 1; }
SRC="https://raw.githubusercontent.com/FreeDev-Group/LighthouseChurch/$LHC_REF"
SRC_DEPLOY="$SRC/development/deploy"
UA="LighthouseChurchBujumbura/1.0 (https://lighthousechurchbujumbura.org; website setup)"
PAGES="01-accueil 02-a-propos 03-ministeres 04-evenements 05-ressources 06-actualites 07-galerie 08-donner 09-contact"
SLUGS="accueil a-propos ministeres evenements ressources actualites galerie donner contact"
# Reference theme ZIP 0.1.0 (CI run 2, commit 752833c), kept on the server by the production "theme" step.
THEME_ZIP="$HOME/lhc-ops/work/a/lighthouse-church-0.1.0.zip"
THEME_SHA="289ef6a5fd505e1eaa01b2e7674dc481c0279e025482d5f895da72148a489afa"
# Staging HTTP login (not a WordPress account): the hash next to the document root, the plain value in a private file.
HTPASSWD="$(dirname "$WP")/.htpasswd"; HTLOGIN="$HOME/lhc-secrets/staging-http-login.txt"
# Staging Editor accounts of the mentees (#10 to #12): <production login>:<staging login>:<display name>.
STAGING_EDITORS=""

w() { wp --path="$WP" --skip-themes=lighthouse-church "$@"; }
wprod() { wp --path="$PROD_WP" --skip-themes=lighthouse-church --skip-plugins "$@"; }  # read-only use only

# Guard: the staging paths, database and address must never be those of production.
if [ "$LHC_SITE" = staging ]; then
  case "$(readlink -m "$WP")/" in "$(readlink -m "$PROD_WP")"/*) echo "refused: staging path inside production"; exit 1 ;; esac
  if [ -f "$WP/wp-config.php" ]; then
    [ "$(w config get DB_NAME)" != "$(wprod config get DB_NAME)" ] || { echo "refused: staging uses the production database"; exit 1; }
    [ "$(w option get siteurl --skip-plugins)" = "$URL" ] || { echo "refused: staging siteurl is not $URL"; exit 1; }
  fi
else
  [ "$(w option get siteurl --skip-plugins)" = "$URL" ] || { echo "refused: production siteurl is not $URL"; exit 1; }
fi
prod_only() { [ "$LHC_SITE" = prod ] || { echo "refused: step $1 is for production only"; exit 1; }; }
staging_only() { [ "$LHC_SITE" = staging ] || { echo "refused: step $1 is for staging only"; exit 1; }; }

fetch_pages() {
  mkdir -p "$S/pages"
  curl -sSf -o "$S/create-pages.php" "$SRC_DEPLOY/create-pages.php" || return 1
  for f in $PAGES; do curl -sSf -o "$S/pages/$f.html" "$SRC/Doc/content/pages/$f.html" || return 1; done
  sha256sum "$S/create-pages.php" "$S/pages/"*.html
}
page_id() { w eval "\$p = get_page_by_path( '$1', OBJECT, 'page' ); echo \$p ? \$p->ID : '';"; }
# HTTP status of a staging address, with the team login (a) or without it (n). Never prints the password.
http() {
  local auth=() u p
  if [ "$1" = a ]; then u=$(sed -n 's/^login=//p' "$HTLOGIN"); p=$(sed -n 's/^password=//p' "$HTLOGIN"); auth=(-K -); fi
  printf 'user = "%s:%s"\n' "$u" "$p" | curl -s -o /dev/null -w '%{http_code}' --max-time 30 "${auth[@]}" "$URL$2"
}
db_cnf() {  # private client options file for the site's own database
  local f; f=$(mktemp); chmod 600 "$f"
  printf '[client]\nuser=%s\npassword="%s"\nhost=%s\n' "$(w config get DB_USER)" "$(w config get DB_PASSWORD)" "$(w config get DB_HOST)" > "$f"
  echo "$f"
}
check_site() {  # read-only checks of the staging site
  echo "core: $(w core version) | theme: $(w theme list --status=active --field=name) | blog_public=$(w option get blog_public) | siteurl=$(w option get siteurl)"
  w core verify-checksums 2>&1 | tail -1
  echo "pages: $(w post list --post_type=page --post_status=publish --orderby=menu_order --order=ASC --field=post_name | tr '\n' ' ')"
  echo "front page: $(w option get show_on_front) $(w option get page_on_front) | posts page: $(w option get page_for_posts)"
  [ -f "$HTLOGIN" ] || { echo "no HTTP login yet: HTTP checks skipped"; return; }
  echo "HTTP without login: / $(http n /) | /wp-admin/ $(http n /wp-admin/)"
  printf 'HTTP with login:'; for s in / /a-propos/ /ministeres/ /evenements/ /ressources/ /actualites/ /galerie/ /donner/ /contact/ /wp-login.php; do printf ' %s %s' "$s" "$(http a "$s")"; done; echo
  echo "X-Robots-Tag: $(curl -sI --max-time 30 "$URL/" | tr -d '\r' | sed -n 's/^x-robots-tag: //Ip')"
}

mkdir -p "$S/logs"
for step in "$@"; do
log="$S/logs/$step.log"
[ -f "$S/logs/$step.done" ] && { cat "$log"; continue; }
[ -f "$S/logs/$step.failed" ] && { cat "$log"; echo "step $step failed earlier: stopped"; exit 1; }
[ -f "$S/logs/$step.running" ] && { echo "step $step already running"; exit 0; }
touch "$S/logs/$step.running"
(
echo "== $LHC_SITE $step ref $LHC_REF $(date -u +%FT%TZ)"
case "${step%.*}" in
inventory)
  whoami; wp --version; w core version; php -v | head -1
  w theme list; w plugin list
  for o in siteurl home blogname blogdescription show_on_front page_on_front page_for_posts permalink_structure blog_public WPLANG timezone_string template stylesheet default_category; do printf '%s = ' "$o"; w option get "$o"; done
  w post list --post_type=page,post,wp_navigation,attachment,wp_template,wp_template_part,wp_global_styles,wp_block --post_status=any --fields=ID,post_type,post_status,post_name,post_title,post_modified
  w user list --fields=ID,user_login,roles
  w db tables --all-tables-with-prefix
  du -sh "$WP"; df -h "$HOME" | tail -1; ls -la "$(dirname "$WP")"
  ;;
users-list)
  # Read-only: accounts with e-mail addresses (output stays in the cron log, never in Git).
  w user list --fields=ID,user_login,display_name,user_email,roles,user_registered
  ;;
backup)
  set -o pipefail; umask 077
  TS=$(date -u +%Y%m%d-%H%M%S); B="$BK/$TS"; mkdir -p "$B"; chmod 700 "$BK" "$B"
  # "wp db export" needs proc_open(), disabled on this host: call mysqldump directly.
  # Credentials go to a private temporary file, never to the command line or the log.
  cnf=$(db_cnf)
  mysqldump --defaults-extra-file="$cnf" --single-transaction --no-tablespaces --add-drop-table "$(w config get DB_NAME)" > "$B/db.sql"; echo "mysqldump exit $?"
  rm -f "$cnf"; gzip -9 "$B/db.sql"
  extra=(); [ -f "$HTPASSWD" ] && extra=(.htpasswd)
  tar czf "$B/files.tar.gz" -C "$(dirname "$WP")" public_html "${extra[@]}"; echo "tar exit $?"
  (cd "$B" && sha256sum db.sql.gz files.tar.gz > SHA256SUMS)
  ls -l --time-style=full-iso "$B"; cat "$B/SHA256SUMS"
  echo "gzip test:"; gzip -t "$B/db.sql.gz" && gzip -t "$B/files.tar.gz" && echo OK
  echo "files in archive: $(tar tzf "$B/files.tar.gz" | grep -vc '/$') | files on disk: $(find "$WP" -type f | wc -l)"
  tar tzf "$B/files.tar.gz" | grep -E '^public_html/(wp-config.php|\.htaccess|wp-includes/version.php|wp-content/themes/lighthouse-church/style.css)$|^\.htpasswd$'
  echo "uploads in archive: $(tar tzf "$B/files.tar.gz" | grep -c '^public_html/wp-content/uploads/.*[^/]$')"
  echo "tables in dump: $(zcat "$B/db.sql.gz" | grep -c '^CREATE TABLE')  tables in db: $(w db tables --all-tables-with-prefix | wc -l)"
  zcat "$B/db.sql.gz" | grep -c '^INSERT INTO' | sed 's/^/INSERT statements: /'
  zcat "$B/db.sql.gz" | tail -1
  echo "$B" > "$S/last-backup"
  ;;
backups-check)
  # Read-only: every backup folder of this site, its checksums and archive integrity.
  for b in "$BK"/*/; do
    echo "## $b"; ls -l --time-style=full-iso "$b"
    [ -f "$b/SHA256SUMS" ] && (cd "$b" && sha256sum -c SHA256SUMS) || sha256sum "$b"*.gz
    for f in "$b"*.gz; do gzip -t "$f" && echo "gzip OK $(basename "$f")"; done
  done
  ls -ld "$BK" "$BK"/*; df -h "$HOME" | tail -1; du -sh "$BK"
  echo "## reference theme ZIP"; ls -l "$THEME_ZIP" && sha256sum "$THEME_ZIP"
  ;;
theme)
  # Installs the reference ZIP 0.1.0 kept on the server, only if its checksum matches.
  staging_only "$step"
  [ -f "$THEME_ZIP" ] || { echo "missing $THEME_ZIP"; exit 1; }
  sum=$(sha256sum "$THEME_ZIP" | cut -d' ' -f1); echo "sha256 $sum"
  [ "$sum" = "$THEME_SHA" ] || { echo "CHECKSUM MISMATCH: not installed"; exit 1; }
  echo "checksum matches the reference"
  w theme install "$THEME_ZIP"
  w theme list
  ;;
pages)
  fetch_pages || exit 1
  w eval-file "$S/create-pages.php" pages "$S/pages"
  w post list --post_type=page --post_status=any --fields=ID,post_status,post_name,post_title,menu_order
  ;;
setup)
  # Staging only: same reading settings, permalinks, theme and menu as production; no production content.
  staging_only "$step"; set -e
  w option update blogname '[DEV] LightHouse Church Bujumbura'
  w option update blogdescription 'Environnement de développement — ce site n’est pas le site officiel'
  w option update timezone_string 'Africa/Bujumbura'
  w option update blog_public 0
  [ "$(w option get permalink_structure)" = "/%postname%/" ] || w rewrite structure '/%postname%/' --hard
  for s in $SLUGS; do
    id=$(page_id "$s"); [ -n "$id" ] || { echo "missing $s"; exit 1; }
    [ "$(w post get "$id" --field=post_status)" = publish ] || w eval "wp_publish_post( $id );"
    eval "id_${s//-/_}=$id"
  done
  w option update show_on_front page; w option update page_on_front "$id_accueil"; w option update page_for_posts "$id_actualites"
  for c in "Actualités:actualites" "Événements:evenements" "Ressources:ressources"; do
    w term get category "${c#*:}" --by=slug --field=term_id >/dev/null 2>&1 || w term create category "${c%%:*}" --slug="${c#*:}"
  done
  # Default installation content (sample post and page) goes to the trash, as on production.
  for id in $(w post list --post_type=post,page --post_status=any --name=hello-world --field=ID) $(w post list --post_type=post,page --post_status=any --name=bonjour-tout-le-monde --field=ID) \
            $(w post list --post_type=page --post_status=any --name=sample-page --field=ID) $(w post list --post_type=page --post_status=any --name=page-d-exemple --field=ID); do
    w post delete "$id"
  done
  w theme activate lighthouse-church
  [ -f "$S/create-pages.php" ] || fetch_pages
  w eval-file "$S/create-pages.php" menu
  w litespeed-purge all 2>/dev/null || true
  w cache flush
  w theme list; for o in blogname blog_public show_on_front page_on_front page_for_posts permalink_structure timezone_string WPLANG; do printf '%s = ' "$o"; w option get "$o"; done
  w post list --post_type=page,post,wp_navigation --fields=ID,post_type,post_status,post_name,post_title
  ;;
footer)
  # Staging only: the same footer as production (Site Editor customisation from footer-final.html).
  staging_only "$step"; mkdir -p "$S/drafts"
  curl -sSf -o "$S/apply-home.php" "$SRC_DEPLOY/apply-home.php" || exit 1
  for f in accueil-final footer-final; do curl -sSf -o "$S/drafts/$f.html" "$SRC_DEPLOY/drafts/$f.html" || exit 1; done
  sha256sum "$S/apply-home.php" "$S/drafts/"*.html
  w eval-file "$S/apply-home.php" apply "$S/drafts"
  w litespeed-purge all 2>/dev/null || true; w cache flush
  ;;
protect)
  # Staging only: HTTP login on the whole site (the ACME challenge and wp-cron.php stay reachable) and
  # an X-Robots-Tag header. The password is generated here, stored in a private file and never printed.
  staging_only "$step"
  mkdir -p "$(dirname "$HTLOGIN")"; chmod 700 "$(dirname "$HTLOGIN")"
  if [ ! -f "$HTLOGIN" ]; then
    umask 077; pw=$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | cut -c1-20)
    printf 'site=%s\nlogin=%s\npassword=%s\n' "$URL" lhc-equipe "$pw" > "$HTLOGIN"; chmod 600 "$HTLOGIN"; umask 022
  fi
  pw=$(sed -n 's/^password=//p' "$HTLOGIN")
  printf 'lhc-equipe:%s\n' "$(openssl passwd -apr1 "$pw")" > "$HTPASSWD"; chmod 644 "$HTPASSWD"; unset pw
  ht="$WP/.htaccess"; touch "$ht"; cp -p "$ht" "$S/htaccess.before-protect"
  if ! grep -q '^# BEGIN LHC staging protection' "$ht"; then
    { cat <<EOF
# BEGIN LHC staging protection
# Development environment (D-021): team HTTP login and no indexing. Not the official website.
SetEnvIf Request_URI "^/(\.well-known/acme-challenge/|wp-cron\.php)" lhc_open
AuthType Basic
AuthName "LightHouse Church - environnement de developpement"
AuthUserFile $HTPASSWD
<RequireAny>
Require env lhc_open
Require valid-user
</RequireAny>
<IfModule mod_headers.c>
Header always set X-Robots-Tag "noindex, nofollow"
</IfModule>
# END LHC staging protection

EOF
    cat "$S/htaccess.before-protect"; } > "$ht"
  fi
  chmod 644 "$ht"; ls -l "$ht" "$HTPASSWD" "$HTLOGIN"
  sed -n '/^# BEGIN LHC staging protection/,/^# END LHC staging protection/p' "$ht"
  w option update blog_public 0
  check_site
  echo "HTTP with a wrong password: $(printf 'user = "lhc-equipe:wrong"\n' | curl -s -o /dev/null -w '%{http_code}' -K - "$URL/")"
  echo "ACME path without login (404 expected, not 401): $(http n /.well-known/acme-challenge/lhc-test)"
  ;;
accounts)
  # Staging only: one Editor account per mentee, with the e-mail address of their production account
  # (read-only lookup, so no address is written in Git). WordPress e-mails each person a link to set
  # their own password. Each entry: <production login>:<staging login>:<display name>.
  staging_only "$step"
  for m in $STAGING_EDITORS; do
    plog="${m%%:*}"; slog="${m#*:}"; slog="${slog%%:*}"; name="${m##*:}"
    mail=$(wprod user get "$plog" --field=user_email 2>/dev/null) || { echo "$plog: not found on production, skipped"; continue; }
    if w user get "$slog" --field=ID >/dev/null 2>&1; then echo "$slog: already exists, not changed"; continue; fi
    w user create "$slog" "$mail" --role=editor --display_name="$name" --send-email --porcelain | sed "s/^/$slog created, ID /"
  done
  w user list --fields=ID,user_login,display_name,roles
  ;;
check)
  staging_only "$step"; check_site ;;
restore-full)
  # Staging only: full restore of the latest staging backup over the staging site, after a simulated
  # incident (marker page added, Galerie page deleted, marker file added). Production is never touched.
  staging_only "$step"; set -o pipefail
  B=$(cat "$S/last-backup"); [ -d "$B" ] || { echo "no staging backup"; exit 1; }
  case "$B" in "$BK"/*) ;; *) echo "refused: $B is not a staging backup"; exit 1 ;; esac
  echo "backup $B"; (cd "$B" && sha256sum -c SHA256SUMS) || exit 1
  TS=$(date -u +%Y%m%d-%H%M%S)
  echo "-- simulated incident"
  marker=$(w post create --post_type=page --post_status=publish --post_title='Marqueur test de restauration' --post_name=lhc-restore-marker --porcelain)
  gal=$(page_id galerie); w post delete "$gal" --force
  echo marker > "$WP/wp-content/lhc-restore-marker.txt"
  echo "marker page $marker, galerie deleted ($gal): /galerie/ $(http a /galerie/) /lhc-restore-marker/ $(http a /lhc-restore-marker/)"
  start=$(date +%s)
  echo "-- restore database"
  cnf=$(db_cnf); zcat "$B/db.sql.gz" | mysql --defaults-extra-file="$cnf"; echo "import exit $?"; rm -f "$cnf"
  echo "-- restore files"
  mv "$WP" "$WP.pre-restore-$TS" && mkdir "$WP" && chmod 755 "$WP"
  tar xpzf "$B/files.tar.gz" -C "$(dirname "$WP")"; echo "extract exit $?"
  echo "restore took $(( $(date +%s) - start )) s"
  w cache flush; w litespeed-purge all 2>/dev/null || true
  echo "-- checks"
  echo "marker page in db: $(w post list --post_type=page --post_status=any --name=lhc-restore-marker --format=count) (0 expected)"
  echo "galerie back: $(page_id galerie) | marker file: $([ -f "$WP/wp-content/lhc-restore-marker.txt" ] && echo present || echo absent) (absent expected)"
  echo "files on disk: $(find "$WP" -type f | wc -l) | files in archive: $(tar tzf "$B/files.tar.gz" | grep '^public_html/' | grep -vc '/$')"
  check_site
  echo "/lhc-restore-marker/ $(http a /lhc-restore-marker/) (404 expected)"
  if [ "$(http a /galerie/)" = 200 ] && [ "$(http a /)" = 200 ] && [ "$(page_id lhc-restore-marker)" = "" ]; then
    rm -rf "$WP.pre-restore-$TS"; echo "RESTORE TEST OK: previous folder removed"
  else
    echo "RESTORE TEST FAILED: previous files kept in $WP.pre-restore-$TS"; exit 1
  fi
  ;;
golive)
  prod_only "$step"; set -e
  w option update blogname 'LightHouse Church Bujumbura'
  w option update timezone_string 'Africa/Bujumbura'
  [ "$(w option get permalink_structure)" = "/%postname%/" ] || w rewrite structure '/%postname%/' --hard
  for s in $SLUGS; do
    id=$(page_id "$s"); [ -n "$id" ] || { echo "missing $s"; exit 1; }
    st=$(w post get "$id" --field=post_status); [ "$st" = publish ] || w eval "wp_publish_post( $id );"  # "wp post update" rejects page-full-width while the old theme is active
    eval "id_${s//-/_}=$id"
  done
  w option update show_on_front page; w option update page_on_front "$id_accueil"; w option update page_for_posts "$id_actualites"
  for c in "Actualités:actualites" "Événements:evenements" "Ressources:ressources"; do
    w term get category "${c#*:}" --by=slug --field=term_id >/dev/null 2>&1 || w term create category "${c%%:*}" --slug="${c#*:}"
  done
  w theme activate lighthouse-church
  [ -f "$S/create-pages.php" ] || fetch_pages
  w eval-file "$S/create-pages.php" menu
  w litespeed-purge all 2>/dev/null || true
  w cache flush
  w theme list; for o in blogname show_on_front page_on_front page_for_posts permalink_structure timezone_string; do printf '%s = ' "$o"; w option get "$o"; done
  w post list --post_type=page,wp_navigation --fields=ID,post_type,post_status,post_name,post_title
  ;;
home-draft|home-apply)
  # Homepage and footer layout update; files come from development/deploy at LHC_REF.
  prod_only "$step"
  mkdir -p "$S/drafts"
  curl -sSf -o "$S/apply-home.php" "$SRC_DEPLOY/apply-home.php" || exit 1
  if [ "${step%.*}" = home-draft ]; then files="accueil-v2 footer-v2"; else files="accueil-final footer-final"; fi
  for f in $files; do curl -sSf -o "$S/drafts/$f.html" "$SRC_DEPLOY/drafts/$f.html" || exit 1; done
  sha256sum "$S/apply-home.php" "$S/drafts/"*.html
  if [ "${step%.*}" = home-draft ]; then
    # Rejected image candidates L, N, P, R (attachments imported by img-import.2).
    for id in 40 42 44 46; do w post get "$id" --field=ID >/dev/null 2>&1 && w post delete "$id" --force; done
    w eval-file "$S/apply-home.php" draft "$S/drafts"
  else
    w eval-file "$S/apply-home.php" apply "$S/drafts"
    w litespeed-purge all 2>/dev/null || true; w cache flush
  fi
  ;;
verify-user)
  # Temporary Editor account used once to test editing in the block editor; removed by verify-user-delete.
  prod_only "$step"
  pass=$(openssl rand -hex 16)
  w user get lhc-verify --field=ID >/dev/null 2>&1 || w user create lhc-verify lhc-verify@lighthousechurchbujumbura.org --role=editor --user_pass="$pass" --display_name="Verification (temporary)"
  w user update lhc-verify --user_pass="$pass" --skip-email
  echo "login lhc-verify password $pass"
  ;;
verify-user-delete)
  prod_only "$step"
  w user delete lhc-verify --reassign=1 --yes
  w user list --fields=ID,user_login,roles
  ;;
img-search)
  # Candidate photos under CC0 or Public Domain Mark from the Openverse API (no attribution required).
  # rawpixel previews are watermarked: only Wikimedia Commons and StockSnap originals.
  prod_only "$step"
  for q in "lighthouse" "lighthouse night" "lighthouse sunset" "bible" "open bible" "praying" "worship" "church interior" "candle" "sunrise" "Bujumbura" "Burundi"; do
    echo "## $q"
    curl -sSfG "https://api.openverse.org/v1/images/" --data-urlencode "q=$q" -d license=cc0 -d source=wikimedia,stocksnap -d size=large -d page_size=8 -d mature=false |
      php -r '$d = json_decode(stream_get_contents(STDIN), true); foreach ($d["results"] ?? [] as $r) { echo implode(" | ", [$r["width"]."x".$r["height"], $r["license"], $r["title"], $r["creator"], $r["url"], $r["foreign_landing_url"]]), "\n"; }'
  done
  ;;
img-delete)
  # Removes the rejected first candidates (watermarked previews), imported by img-import on 2026-10-25.
  prod_only "$step"
  for id in 33 34 35 36 37 38; do w post delete "$id" --force; done
  ;;
img-import)
  # Imports the CC0 candidates of development/deploy/image-candidates.tsv into the Media Library.
  prod_only "$step"
  mkdir -p "$S/img"; curl -sSf -o "$S/image-candidates.tsv" "$SRC_DEPLOY/image-candidates.tsv" || exit 1
  while IFS=$'\t' read -r key url alt title lic landing; do
    [ -n "$key" ] || continue
    big="${url/editor_1024/image_1300}"; f="$S/img/$key.jpg"
    curl -sSfL -A "$UA" -o "$f" "$big" 2>/dev/null || curl -sSfL -A "$UA" -o "$f" "$url" || { echo "$key download failed"; continue; }
    id=$(w media import "$f" --title="$alt" --alt="$alt" --desc="Photo d'illustration provisoire, libre de droits (licence ${lic^^}), à remplacer par une photo de l'Église. Ne représente pas LightHouse Church. Source : $title — $landing" --porcelain)
    echo "$key $id $(w eval "echo wp_get_attachment_url( $id ), ' ', implode( 'x', array_slice( wp_get_attachment_image_src( $id, 'full' ), 1, 2 ) );")"
  done < "$S/image-candidates.tsv"
  ;;
audit)
  # Read-only: backups, deployed theme files, plugin versions and LiteSpeed Cache release data.
  prod_only "$step"
  for b in "$HOME"/lhc-backups/*/; do
    echo "## $b"; ls -l --time-style=full-iso "$b"; sha256sum "$b"*
    for f in "$b"*.gz; do gzip -t "$f" && echo "gzip OK $(basename "$f")"; done
    [ -f "$b/files.tar.gz" ] && echo "files: $(tar tzf "$b/files.tar.gz" | wc -l)"
    [ -f "$b/db.sql.gz" ] && echo "tables: $(zcat "$b/db.sql.gz" | grep -c '^CREATE TABLE') | $(zcat "$b/db.sql.gz" | tail -1)"
  done
  ls -ld "$HOME/lhc-backups" "$HOME"/lhc-backups/*
  echo "## theme files"; (cd "$WP/wp-content/themes/lighthouse-church" && find . -type f -print0 | sort -z | xargs -0 sha256sum)
  echo "## versions"; w core version; php -v | head -1; w plugin list --fields=name,status,version,update_version
  echo "## litespeed-cache on wordpress.org"
  curl -sSf "https://api.wordpress.org/plugins/info/1.2/?action=plugin_information&slug=litespeed-cache&fields[sections]=1" |
    php -r '$d = json_decode(stream_get_contents(STDIN), true); foreach (["version", "requires", "tested", "requires_php", "last_updated"] as $k) { echo "$k: ", $d[$k] ?? "", "\n"; } echo substr(strip_tags($d["sections"]["changelog"] ?? ""), 0, 1500), "\n";'
  echo "## cron output files"; ls -la "$HOME/.logs"
  echo "## lhc-ops"; ls -la "$S" "$S/logs"
  ;;
export-db)
  # Read-only: prints the database backup base64-encoded, so it can be copied out through the cron output.
  prod_only "$step"
  f="$HOME/lhc-backups/20261025-202803/db.sql.gz"; sha256sum "$f"; base64 -w 0 "$f"; echo
  ;;
restore-test)
  # Restores a backup into an isolated temporary database and a temporary folder, never into the live site.
  # ~/lhc-ops/rt.cnf ([client] user, password, database of the temporary database) is written by a cron job
  # just before and removed here; the temporary database is deleted afterwards with the Hostinger API.
  prod_only "$step"
  B="$HOME/lhc-backups/20261025-202803"; T="$HOME/lhc-restore-test"; cnf="$S/rt.cnf"
  [ -f "$cnf" ] || { echo "missing $cnf"; exit 1; }
  live_db=$(w config get DB_NAME); rt_db=$(sed -n 's/^database=//p' "$cnf")
  [ -n "$rt_db" ] && [ "$rt_db" != "$live_db" ] || { echo "refused: temporary database must differ from the live one"; exit 1; }
  zcat "$B/db.sql.gz" | mysql --defaults-extra-file="$cnf"; echo "import exit ${PIPESTATUS[1]}"
  q() { mysql --defaults-extra-file="$cnf" -N -e "$1"; }
  echo "tables: $(q 'SHOW TABLES' | wc -l)"
  for t in wp_posts wp_postmeta wp_options wp_users wp_terms; do echo "$t restored=$(q "SELECT COUNT(*) FROM $t")"; done
  echo "siteurl=$(q "SELECT option_value FROM wp_options WHERE option_name='siteurl'") template=$(q "SELECT option_value FROM wp_options WHERE option_name='template'")"
  echo "pages: $(q "SELECT CONCAT(ID,':',post_name,':',post_status) FROM wp_posts WHERE post_type='page'" | tr '\n' ' ')"
  rm -f "$cnf"
  rm -rf "$T"; mkdir -p "$T"; chmod 700 "$T"
  tar xzf "$B/files.tar.gz" -C "$T"; echo "extract exit $?"
  echo "extracted files: $(find "$T/public_html" -type f | wc -l)"
  for f in wp-config.php wp-includes/version.php wp-content/themes/twentytwentyfive/style.css; do [ -f "$T/public_html/$f" ] && echo "present $f"; done
  grep -o "wp_version = '[^']*'" "$T/public_html/wp-includes/version.php"
  (cd "$T/public_html" && find wp-admin wp-includes -type f -print0 | sort -z | xargs -0 sha256sum) | sha256sum | sed 's/^/core files digest (backup) /'
  (cd "$WP" && find wp-admin wp-includes -type f -print0 | sort -z | xargs -0 sha256sum) | sha256sum | sed 's/^/core files digest (live)   /'
  rm -rf "$T"; echo "temporary folder removed"
  ;;
rollback)
  # Production: back to Twenty Twenty-Five and the previous homepage setting (never run so far).
  prod_only "$step"
  w theme activate twentytwentyfive
  w option update show_on_front "$(cat "$S/prev.show_on_front" 2>/dev/null || echo posts)"
  w litespeed-purge all 2>/dev/null || true; w cache flush
  w theme list; w option get show_on_front
  ;;
*) echo "unknown step $step"; exit 1 ;;
esac
) > "$log" 2>&1
rc=$?
echo "== exit $rc $(date -u +%FT%TZ)" >> "$log"
rm -f "$S/logs/$step.running"
if [ $rc -eq 0 ]; then touch "$S/logs/$step.done"; cat "$log"; else touch "$S/logs/$step.failed"; cat "$log"; echo "step $step failed: stopped"; exit 1; fi
done
