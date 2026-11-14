#!/usr/bin/env bash

set -euo pipefail

repository_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
submodule_path="${1:-redlib}"
patch_path="${2:-patches}"
redlib_dir="${repository_dir}/${submodule_path}"
patch_dir="${repository_dir}/${patch_path}"

base_commit="$(git -C "${repository_dir}" rev-parse --verify "HEAD:${submodule_path}" 2>/dev/null || true)"
if [[ -z "${base_commit}" ]]; then
	index_entry="$(git -C "${repository_dir}" ls-files --stage -- "${submodule_path}")"
	read -r _ base_commit _ _ <<<"${index_entry}"
fi

if [[ -z "${base_commit}" ]]; then
	echo "Unable to determine the pinned commit for ${submodule_path}." >&2
	exit 1
fi

if [[ -n "$(git -C "${redlib_dir}" status --porcelain)" ]]; then
	echo "${submodule_path} has uncommitted changes; commit them before formatting patches." >&2
	exit 1
fi

if ! git -C "${redlib_dir}" merge-base --is-ancestor "${base_commit}" HEAD; then
	echo "The pinned commit for ${submodule_path} is not an ancestor of HEAD." >&2
	exit 1
fi

commit_count="$(git -C "${redlib_dir}" rev-list --count "${base_commit}..HEAD")"
if (( commit_count == 0 )); then
	echo "There are no commits to format on top of the pinned ${submodule_path} commit." >&2
	exit 1
fi

temporary_dir="$(mktemp -d "${TMPDIR:-/tmp}/redlib-patches.XXXXXX")"
trap 'rm -rf -- "${temporary_dir}"' EXIT

git -C "${redlib_dir}" format-patch \
	--output-directory "${temporary_dir}" \
	"${base_commit}..HEAD"

find "${patch_dir}" -maxdepth 1 -type f -name '*.patch' -delete
cp "${temporary_dir}"/*.patch "${patch_dir}/"

echo "Formatted ${commit_count} patch(es) in ${patch_dir}."
