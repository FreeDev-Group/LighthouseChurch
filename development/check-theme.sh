#!/usr/bin/env bash
# Static checks for the lighthouse-church theme. Used by CI and runnable locally.
#
# Usage: development/check-theme.sh
# Requires: bash, php (CLI), zip, unzip.
#
# Checks:
#   1. PHP syntax of every .php file in the theme (php -l).
#   2. Every .json file in the theme parses as JSON.
#   3. style.css declares the required theme headers.
#   4. The installable ZIP builds and has the expected layout.
#
# Runs every check, prints each failure, and exits non-zero if any failed.

set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
theme_dir="${repo_root}/development/lighthouse-church"
failures=0

section() { printf '\n== %s\n' "$1"; }
fail() {
	printf 'FAIL: %s\n' "$1" >&2
	# On GitHub Actions, also emit an error annotation shown on the pull request.
	if [[ "${GITHUB_ACTIONS:-}" == "true" ]]; then
		printf '::error title=Theme check failed::%s\n' "${1//$'\n'/ }"
	fi
	failures=$((failures + 1))
}

echo "PHP: $(php -r 'echo PHP_VERSION;')"

section "PHP syntax"
php_count=0
while IFS= read -r -d '' file; do
	php_count=$((php_count + 1))
	if ! output="$(php -l "${file}" 2>&1)"; then
		fail "${file#"${repo_root}/"}: ${output}"
	fi
done < <(find "${theme_dir}" -name '*.php' -print0 | sort -z)
echo "${php_count} PHP files checked"

section "JSON"
json_count=0
while IFS= read -r -d '' file; do
	json_count=$((json_count + 1))
	if ! output="$(php -r 'json_decode(file_get_contents($argv[1]), false, 512, JSON_THROW_ON_ERROR);' "${file}" 2>&1)"; then
		fail "${file#"${repo_root}/"}: ${output}"
	fi
done < <(find "${theme_dir}" -name '*.json' -print0 | sort -z)
echo "${json_count} JSON files checked"

section "Theme headers (style.css)"
for header in 'Theme Name' 'Requires at least' 'Requires PHP' 'Version' 'License' 'Text Domain'; do
	if ! grep -q "^${header}:" "${theme_dir}/style.css"; then
		fail "style.css is missing the '${header}' header"
	fi
done
if ! grep -q '^Text Domain: lighthouse-church$' "${theme_dir}/style.css"; then
	fail "style.css Text Domain must be 'lighthouse-church'"
fi
echo "headers checked"

section "Build ZIP"
if build_output="$("${repo_root}/development/build-theme-zip.sh" 2>&1)"; then
	echo "${build_output}"
	version="$(sed -n 's/^Version:[[:space:]]*//p' "${theme_dir}/style.css" | head -n 1 | tr -d '\r')"
	zip_path="${repo_root}/dist/lighthouse-church-${version}.zip"
	listing="$(unzip -Z1 "${zip_path}")"
	for required in lighthouse-church/style.css lighthouse-church/theme.json lighthouse-church/functions.php lighthouse-church/templates/index.html lighthouse-church/LICENSE; do
		grep -qx "${required}" <<< "${listing}" || fail "ZIP is missing ${required}"
	done
	if grep -qv '^lighthouse-church/' <<< "${listing}"; then
		fail "ZIP contains files outside the lighthouse-church/ folder"
	fi
	if grep -q '^lighthouse-church/README.md$' <<< "${listing}"; then
		fail "ZIP should not contain the development README.md"
	fi
	echo "$(grep -vc '/$' <<< "${listing}") files in ${zip_path#"${repo_root}/"}"
else
	fail "build-theme-zip.sh failed: ${build_output}"
fi

echo
if [[ ${failures} -gt 0 ]]; then
	echo "${failures} check(s) failed." >&2
	exit 1
fi
echo "All checks passed."
