#!/usr/bin/env bash

set -euo pipefail

repository_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
submodule_path="${1:-redlib}"
redlib_dir="${repository_dir}/${submodule_path}"

if ! git -C "${redlib_dir}" rev-parse --git-dir >/dev/null 2>&1; then
	git -C "${repository_dir}" submodule update --init -- "${submodule_path}"
fi

expected_commit="$(git -C "${repository_dir}" rev-parse --verify "HEAD:${submodule_path}" 2>/dev/null || true)"
if [[ -z "${expected_commit}" ]]; then
	index_entry="$(git -C "${repository_dir}" ls-files --stage -- "${submodule_path}")"
	read -r _ expected_commit _ _ <<<"${index_entry}"
fi

if [[ -z "${expected_commit}" ]]; then
	echo "Unable to determine the pinned commit for ${submodule_path}." >&2
	exit 1
fi

if [[ -d "${redlib_dir}/.git/rebase-apply" ]] || git -C "${redlib_dir}" am --show-current-patch=diff >/dev/null 2>&1; then
	git -C "${redlib_dir}" am --abort
fi

git -C "${redlib_dir}" reset --hard "${expected_commit}"
echo "${submodule_path} reset to ${expected_commit}."
