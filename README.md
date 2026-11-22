# Redlib patches

This repository tracks [Redlib](https://github.com/redlib-org/redlib) as the
`redlib` submodule and keeps local changes as an ordered patch series in
[`patches/`](patches/).
It also builds [Nachtalb's Redlib fork](https://github.com/Nachtalb/redlib) from
the `redlib-nachtalb` submodule, with its own patch series in
[`patches-nachtalb/`](patches-nachtalb/).
It also builds [mv12star's Redlib fork](https://codeberg.org/mv12star/redlib)
from the `redlib-mv12star` submodule and [`patches-mv12star/`](patches-mv12star/).

The patches are applied before compiling Redlib or building the container image.
Images built by GitHub Actions are published to
`ghcr.io/tiekoetter/redlib-patches`.

## Included behavior

The pinned Redlib source includes Fastly dual-stack DNS resolution and
percent-encoding for anonymous thread and comment requests. The Nachtalb and
mv12star forks do not include the DNS change, so their patch series add it while
preserving their RedGifs-specific DNS behavior.
Only the DNS lookup target changes; requests still use `www.reddit.com` for
TLS server-name and HTTP Host handling.

## Clone and build

```sh
git clone --recurse-submodules https://github.com/tiekoetter/redlib-patches.git
cd redlib-patches
./scripts/build.sh
```

To build the Nachtalb fork instead:

```sh
./scripts/build-nachtalb.sh
```

For mv12star:

```sh
./scripts/build-mv12star.sh
```

To build a local container image instead:

```sh
./scripts/build-container-image.sh redlib-patches:latest
```

For a container image built from Nachtalb:

```sh
./scripts/build-container-image-nachtalb.sh redlib-nachtalb:latest
```

For mv12star:

```sh
./scripts/build-container-image-mv12star.sh redlib-mv12star:latest
```

The container build deliberately uses upstream's `Dockerfile.alpine`. The
default upstream `Dockerfile` downloads a prebuilt release and therefore would
not contain this repository's patches.
Both forks use their `Dockerfile.distroless`. GitHub Actions publishes their
images as `ghcr.io/tiekoetter/redlib-patches:nachtalb` and
`ghcr.io/tiekoetter/redlib-patches:mv12star`.

## Work with the patch series

Apply the current patches to the submodule:

```sh
./scripts/apply-patches.sh
```

The Nachtalb patch series is applied independently:

```sh
./scripts/apply-patches.sh redlib-nachtalb patches-nachtalb
```

For mv12star:

```sh
./scripts/apply-patches.sh redlib-mv12star patches-mv12star
```

To add or edit patches, reset the submodule, make commits on top of its pinned
commit, and regenerate the series:

```sh
./scripts/reset-redlib.sh
git -C redlib switch --detach
# Edit files, then create one or more commits in redlib.
./scripts/format-patches.sh
```

For Nachtalb, pass `redlib-nachtalb` to `reset-redlib.sh`, and pass both
`redlib-nachtalb` and `patches-nachtalb` to `format-patches.sh` or
`apply-patches.sh`. Use `redlib-mv12star` and `patches-mv12star` for mv12star.

`format-patches.sh` replaces the existing `*.patch` files with one mail-format
patch per commit. `reset-redlib.sh` discards tracked changes and local commits
inside the default `redlib` submodule; pass the alternative submodule name to
reset a fork instead. Build artifacts and other untracked files are preserved.

The scheduled update workflow opens or refreshes a separate pull request for
each upstream branch that moves, checks its patch series, and dispatches a
non-publishing build for that fork. The dispatched build is a separate workflow
run because pull requests created with `GITHUB_TOKEN` do not trigger PR
workflows. Pull requests and pushes build only affected forks; shared changes,
tags, and manual builds default to all forks. Manual builds can select a fork
and disable publishing.

## License

Redlib is licensed under the GNU Affero General Public License v3.0. See
[`LICENSE`](LICENSE).
