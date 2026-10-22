#!/usr/bin/env bash
# Build an installable ZIP of the lighthouse-church theme.
#
# Usage: development/build-theme-zip.sh
# Output: dist/lighthouse-church-<version>.zip (dist/ and *.zip are git-ignored).
#
# The ZIP contains a single top-level "lighthouse-church/" folder, as
# WordPress expects for Appearance > Themes > Add New > Upload Theme.
# Development-only files (README.md, dotfiles) are excluded.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
theme_dir="${repo_root}/development/lighthouse-church"
dist_dir="${repo_root}/dist"

version="$(sed -n 's/^Version:[[:space:]]*//p' "${theme_dir}/style.css" | head -n 1 | tr -d '\r')"
if [[ -z "${version}" ]]; then
	echo "Error: could not read Version from style.css" >&2
	exit 1
fi

for required in style.css theme.json functions.php templates/index.html; do
	if [[ ! -f "${theme_dir}/${required}" ]]; then
		echo "Error: missing ${required}" >&2
		exit 1
	fi
done

mkdir -p "${dist_dir}"
zip_path="${dist_dir}/lighthouse-church-${version}.zip"
rm -f "${zip_path}"

cd "${repo_root}/development"
zip -r -q -X "${zip_path}" lighthouse-church \
	-x 'lighthouse-church/README.md' \
	-x 'lighthouse-church/.*' \
	-x 'lighthouse-church/**/.*'

echo "Built ${zip_path}"
