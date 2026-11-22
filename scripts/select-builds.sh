#!/usr/bin/env bash

set -euo pipefail

redlib=false
nachtalb=false
mv12star=false

changes="$(mktemp)"
trap 'rm -f -- "${changes}"' EXIT
git diff --no-renames --name-only -z "$1" "$2" > "${changes}"

while IFS= read -r -d '' path; do
	case "${path}" in
		redlib|patches/*|scripts/build.sh|scripts/build-container-image.sh)
			redlib=true ;;
		redlib-nachtalb|patches-nachtalb/*|scripts/build-nachtalb.sh|scripts/build-container-image-nachtalb.sh)
			nachtalb=true ;;
		redlib-mv12star|patches-mv12star/*|scripts/build-mv12star.sh|scripts/build-container-image-mv12star.sh)
			mv12star=true ;;
		*)
			redlib=true
			nachtalb=true
			mv12star=true ;;
	esac
done < "${changes}"

printf 'redlib=%s\nnachtalb=%s\nmv12star=%s\n' "${redlib}" "${nachtalb}" "${mv12star}"
