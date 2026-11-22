#!/usr/bin/env bash

set -euo pipefail

repository_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
submodule_path="redlib-mv12star"
patch_path="patches-mv12star"
patches_applied=false

cleanup() {
	if [[ "${patches_applied}" == true ]]; then
		"${repository_dir}/scripts/reset-redlib.sh" "${submodule_path}"
	fi
}
trap cleanup EXIT

"${repository_dir}/scripts/apply-patches.sh" "${submodule_path}" "${patch_path}"
patches_applied=true

cargo build \
	--manifest-path "${repository_dir}/${submodule_path}/Cargo.toml" \
	--release \
	--locked

cp "${repository_dir}/${submodule_path}/target/release/redlib" "${repository_dir}/redlib-mv12star-bin"
echo "Built ${repository_dir}/redlib-mv12star-bin."
