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

if [[ -d "${redlib_dir}/.git/rebase-apply" ]] || git -C "${redlib_dir}" am --show-current-patch=diff >/dev/null 2>&1; then
	git -C "${redlib_dir}" am --abort
fi

git -C "${redlib_dir}" reset --hard "${expected_commit}"
echo "Redlib reset to ${expected_commit}."
