#!/usr/bin/env bash

set -euo pipefail

repository_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
image_name="${1:-redlib-patches:latest}"
patches_applied=false

cleanup() {
	if [[ "${patches_applied}" == true ]]; then
		"${repository_dir}/scripts/reset-redlib.sh"
	fi
}
trap cleanup EXIT

"${repository_dir}/scripts/apply-patches.sh"
patches_applied=true

docker build \
	--file "${repository_dir}/redlib/Dockerfile.alpine" \
	--tag "${image_name}" \
	"${repository_dir}/redlib"

echo "Built ${image_name}."
