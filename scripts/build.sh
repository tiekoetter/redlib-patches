#!/usr/bin/env bash

set -euo pipefail

repository_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
patches_applied=false

cleanup() {
	if [[ "${patches_applied}" == true ]]; then
		"${repository_dir}/scripts/reset-redlib.sh"
	fi
}
trap cleanup EXIT

"${repository_dir}/scripts/apply-patches.sh"
patches_applied=true

cargo build \
	--manifest-path "${repository_dir}/redlib/Cargo.toml" \
	--release \
	--locked

cp "${repository_dir}/redlib/target/release/redlib" "${repository_dir}/redlib-bin"
echo "Built ${repository_dir}/redlib-bin."
