#!/usr/bin/env bash

set -euo pipefail

repository_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
submodule_path="redlib-nachtalb"
patch_path="patches-nachtalb"
image_name="${1:-redlib-nachtalb:latest}"
patches_applied=false

cleanup() {
	if [[ "${patches_applied}" == true ]]; then
		"${repository_dir}/scripts/reset-redlib.sh" "${submodule_path}"
	fi
}
trap cleanup EXIT

"${repository_dir}/scripts/apply-patches.sh" "${submodule_path}" "${patch_path}"
patches_applied=true

docker build \
	--file "${repository_dir}/${submodule_path}/Dockerfile.distroless" \
	--tag "${image_name}" \
	"${repository_dir}/${submodule_path}"

echo "Built ${image_name}."
