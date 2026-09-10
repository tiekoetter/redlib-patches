#!/usr/bin/env bash

set -euo pipefail

repository_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
redlib_dir="${repository_dir}/redlib"

if ! git -C "${redlib_dir}" rev-parse --git-dir >/dev/null 2>&1; then
	git -C "${repository_dir}" submodule update --init -- redlib
fi

expected_commit="$(git -C "${repository_dir}" rev-parse --verify HEAD:redlib 2>/dev/null || true)"
if [[ -z "${expected_commit}" ]]; then
	index_entry="$(git -C "${repository_dir}" ls-files --stage -- redlib)"
	read -r _ expected_commit _ _ <<<"${index_entry}"
fi

if [[ -z "${expected_commit}" ]]; then
	echo "Unable to determine the pinned Redlib commit." >&2
	exit 1
fi

current_commit="$(git -C "${redlib_dir}" rev-parse HEAD)"
if [[ "${current_commit}" != "${expected_commit}" ]]; then
	echo "Redlib is not at the pinned commit. Run scripts/reset-redlib.sh first." >&2
	exit 1
fi

if [[ -n "$(git -C "${redlib_dir}" status --porcelain)" ]]; then
	echo "Redlib has uncommitted changes. Commit them or run scripts/reset-redlib.sh first." >&2
	exit 1
fi

shopt -s nullglob
patches=("${repository_dir}"/patches/*.patch)

if (( ${#patches[@]} == 0 )); then
	echo "No patches to apply."
	exit 0
fi

echo "Applying ${#patches[@]} patch(es) to Redlib..."
GIT_COMMITTER_NAME="redlib-patches" \
	GIT_COMMITTER_EMAIL="redlib-patches@users.noreply.github.com" \
	git -C "${redlib_dir}" am --3way "${patches[@]}"
