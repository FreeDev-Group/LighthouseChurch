#!/bin/bash
# LightHouse Church deployment steps on the Hostinger server, one step per run.
# Started from a short-lived hPanel cron job (commands are limited to 255 characters):
#   mkdir -p ~/lhc-ops && cd ~/lhc-ops && curl -sSfO <raw URL of this file at a fixed commit> ; bash lhc-steps.sh <step>
# A finished step only prints its log again, so the cron job can fire more than once safely.
# Steps: inventory, backup, theme, pages-dry, pages, golive, rollback (see Doc/deployment/hostinger-deployment.md).
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin"
S="$HOME/lhc-ops"; WP="$HOME/domains/lighthousechurchbujumbura.org/public_html"
# Reviewed page content and page script (commit e48b2d8).
SRC="https://raw.githubusercontent.com/FreeDev-Group/LighthouseChurch/e48b2d80235b093d0ff24781eb815741e7c3e669"
fetch_pages() {
  mkdir -p "$S/pages"
  curl -sSf -o "$S/create-pages.php" "$SRC/development/deploy/create-pages.php" || return 1
  for f in 01-accueil 02-a-propos 03-ministeres 04-evenements 05-ressources 06-actualites 07-galerie 08-donner 09-contact; do
    curl -sSf -o "$S/pages/$f.html" "$SRC/Doc/content/pages/$f.html" || return 1
  done
  sha256sum "$S/create-pages.php" "$S/pages/"*.html
}
mkdir -p "$S/logs"; step="$1"; log="$S/logs/$step.log"
[ -f "$S/logs/$step.done" ] && { cat "$log"; exit 0; }
[ -f "$S/logs/$step.running" ] && { echo "step $step already running"; exit 0; }
touch "$S/logs/$step.running"
w() { wp --path="$WP" --skip-themes=lighthouse-church "$@"; }
# "backup.2" re-runs the backup step under a new log name.
(
echo "== $step $(date -u +%FT%TZ)"
case "${step%.*}" in
inventory)
  whoami; wp --version; w core version
  w theme list; w plugin list
  for o in show_on_front page_on_front page_for_posts template stylesheet; do w option get "$o" > "$S/prev.$o"; done
  for o in siteurl home blogname blogdescription show_on_front page_on_front page_for_posts permalink_structure blog_public WPLANG timezone_string template stylesheet default_category; do printf '%s = ' "$o"; w option get "$o"; done
  w post list --post_type=page,post,wp_navigation,attachment,wp_template,wp_template_part,wp_global_styles,wp_block --post_status=any --fields=ID,post_type,post_status,post_name,post_title,post_modified
  w term list category --fields=term_id,slug,name,count
  w user list --fields=ID,user_login,roles
  w db tables --all-tables-with-prefix
  du -sh "$WP"; df -h "$HOME" | tail -1; ls -la "$HOME"
  command -v unzip curl mysqldump
  ;;
backup)
  TS=$(date -u +%Y%m%d-%H%M%S); B="$HOME/lhc-backups/$TS"; mkdir -p "$B"; chmod 700 "$HOME/lhc-backups" "$B"
  # "wp db export" needs proc_open(), disabled on this host: call mysqldump directly.
  # Credentials go to a private temporary file, never to the command line or the log.
  cnf=$(mktemp); chmod 600 "$cnf"
  printf '[client]\nuser=%s\npassword="%s"\nhost=%s\n' "$(w config get DB_USER)" "$(w config get DB_PASSWORD)" "$(w config get DB_HOST)" > "$cnf"
  mysqldump --defaults-extra-file="$cnf" --single-transaction --no-tablespaces --add-drop-table "$(w config get DB_NAME)" > "$B/db.sql"; echo "mysqldump exit $?"
  rm -f "$cnf"; gzip -9 "$B/db.sql"
  tar czf "$B/files.tar.gz" -C "$(dirname "$WP")" public_html
  ls -l "$B"; sha256sum "$B"/*
  echo "gzip test:"; gzip -t "$B/db.sql.gz" && gzip -t "$B/files.tar.gz" && echo OK
  echo "files in archive: $(tar tzf "$B/files.tar.gz" | wc -l)"
  tar tzf "$B/files.tar.gz" | grep -E '^public_html/(wp-config.php|wp-content/themes/twentytwentyfive/style.css|wp-includes/version.php)$'
  echo "tables in dump: $(zcat "$B/db.sql.gz" | grep -c '^CREATE TABLE')  tables in db: $(w db tables --all-tables-with-prefix | wc -l)"
  zcat "$B/db.sql.gz" | grep -c '^INSERT INTO' | sed 's/^/INSERT statements: /'
  zcat "$B/db.sql.gz" | tail -1
  echo "$B" > "$S/last-backup"
  ;;
theme)
  W="$S/work"; rm -rf "$W"; mkdir -p "$W"
  # The signed artifact URL is written base64-encoded in parts url.1, url.2, … by earlier cron jobs.
  curl -sSfL -o "$W/artifact.zip" "$(cat "$S"/url.* | base64 -d)" || { echo "download failed"; exit 1; }
  unzip -o -q "$W/artifact.zip" -d "$W/a"; ls -l "$W/a"
  sum=$(sha256sum "$W/a/lighthouse-church-0.1.0.zip" | cut -d' ' -f1); echo "sha256 $sum"
  [ "$sum" = "289ef6a5fd505e1eaa01b2e7674dc481c0279e025482d5f895da72148a489afa" ] || { echo "CHECKSUM MISMATCH: not installed"; exit 1; }
  echo "checksum matches the reference"
  w theme install "$W/a/lighthouse-church-0.1.0.zip"
  w theme list
  ;;
pages-dry)
  fetch_pages && w eval-file "$S/create-pages.php" ;;
pages)
  fetch_pages || exit 1
  w eval-file "$S/create-pages.php" pages "$S/pages"
  w post list --post_type=page --post_status=any --fields=ID,post_status,post_name,post_title,menu_order
  ;;
golive)
  set -e
  w option update blogname 'LightHouse Church Bujumbura'
  w option update timezone_string 'Africa/Bujumbura'
  [ "$(w option get permalink_structure)" = "/%postname%/" ] || w rewrite structure '/%postname%/' --hard
  for s in accueil a-propos ministeres evenements ressources actualites galerie donner contact; do
    id=$(w post list --post_type=page --name="$s" --post_status=any --field=ID); [ -n "$id" ] || { echo "missing $s"; exit 1; }
    st=$(w post get "$id" --field=post_status); [ "$st" = publish ] || w post update "$id" --post_status=publish
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
rollback)
  w theme activate twentytwentyfive
  w option update show_on_front "$(cat "$S/prev.show_on_front" 2>/dev/null || echo posts)"
  w litespeed-purge all 2>/dev/null || true; w cache flush
  w theme list; w option get show_on_front
  ;;
*) echo "unknown step $step" ;;
esac
) > "$log" 2>&1
echo "== exit $? $(date -u +%FT%TZ)" >> "$log"
rm -f "$S/logs/$step.running"; touch "$S/logs/$step.done"
cat "$log"
