#!/usr/bin/env bash

set -euo pipefail

repository_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/redlib-build-selection.XXXXXX")"
trap 'rm -rf -- "${test_dir}"' EXIT
cd "${test_dir}"
git init -q
git config user.name "Build selection test"
git config user.email "test@example.com"

commit() {
	git add -A
	git commit -qm "$1"
}

check() {
	local base="$1" expected="$2" actual
	actual="$("${repository_dir}/scripts/select-builds.sh" "${base}" HEAD)"
	if [[ "${actual}" != "${expected}" ]]; then
		printf 'Expected:\n%s\nActual:\n%s\n' "${expected}" "${actual}" >&2
		exit 1
	fi
}

echo initial > README
commit initial
base="$(git rev-parse HEAD)"
check "${base}" $'redlib=false\nnachtalb=false\nmv12star=false'

echo upstream > redlib
commit upstream
check "${base}" $'redlib=true\nnachtalb=false\nmv12star=false'
base="$(git rev-parse HEAD)"

echo fork > redlib-nachtalb
commit nachtalb
check "${base}" $'redlib=false\nnachtalb=true\nmv12star=false'
base="$(git rev-parse HEAD)"

echo fork > redlib-mv12star
commit mv12star
check "${base}" $'redlib=false\nnachtalb=false\nmv12star=true'
base="$(git rev-parse HEAD)"

mkdir patches-mv12star patches-nachtalb
echo patch > patches-mv12star/ipv6.patch
echo patch > patches-nachtalb/ipv6.patch
commit patches
check "${base}" $'redlib=false\nnachtalb=true\nmv12star=true'
base="$(git rev-parse HEAD)"

git mv patches-mv12star/ipv6.patch patches-mv12star/renamed.patch
commit rename
check "${base}" $'redlib=false\nnachtalb=false\nmv12star=true'
base="$(git rev-parse HEAD)"

git mv patches-mv12star/renamed.patch patches-nachtalb/moved.patch
commit move
check "${base}" $'redlib=false\nnachtalb=true\nmv12star=true'
base="$(git rev-parse HEAD)"

echo shared >> README
commit shared
check "${base}" $'redlib=true\nnachtalb=true\nmv12star=true'

echo "Build selection tests passed."
