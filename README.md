# Redlib patches

This repository tracks [Redlib](https://github.com/redlib-org/redlib) as the
`redlib` submodule and keeps local changes as an ordered patch series in
[`patches/`](patches/).
It also builds [Nachtalb's Redlib fork](https://github.com/Nachtalb/redlib) from
the `redlib-nachtalb` submodule, with its own patch series in
[`patches-nachtalb/`](patches-nachtalb/).

The patches are applied before compiling Redlib or building the container image.
Images built by GitHub Actions are published to
`ghcr.io/tiekoetter/redlib-patches`.

## Included behavior

The pinned Redlib source includes Fastly dual-stack DNS resolution and
percent-encoding for anonymous thread and comment requests. The Nachtalb fork
does not include the DNS change, so [`patches-nachtalb/`](patches-nachtalb/)
adds it while preserving the fork's RedGifs-specific DNS behavior.
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

To build a local container image instead:

```sh
./scripts/build-container-image.sh redlib-patches:latest
```

For a container image built from Nachtalb:

```sh
./scripts/build-container-image-nachtalb.sh redlib-nachtalb:latest
```

The container build deliberately uses upstream's `Dockerfile.alpine`. The
default upstream `Dockerfile` downloads a prebuilt release and therefore would
not contain this repository's patches.
The Nachtalb build uses its `Dockerfile.distroless`. GitHub Actions publishes
that image as `ghcr.io/tiekoetter/redlib-patches:nachtalb`.

## Work with the patch series

Apply the current patches to the submodule:

```sh
./scripts/apply-patches.sh
```

The Nachtalb patch series is applied independently:

```sh
./scripts/apply-patches.sh redlib-nachtalb patches-nachtalb
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
`apply-patches.sh`.

`format-patches.sh` replaces the existing `*.patch` files with one mail-format
patch per commit. `reset-redlib.sh` discards tracked changes and local commits
inside the default `redlib` submodule; pass `redlib-nachtalb` to reset the
alternative instead. Build artifacts and other untracked files are preserved.

The scheduled update workflow opens or refreshes a pull request when either
upstream `main` branch moves. It also reports whether each patch series still
applies to its updated submodule.

## License

Redlib is licensed under the GNU Affero General Public License v3.0. See
[`LICENSE`](LICENSE).
