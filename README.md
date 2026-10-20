# Redlib patches

This repository tracks [Redlib](https://github.com/redlib-org/redlib) as the
`redlib` submodule and keeps local changes as an ordered patch series in
[`patches/`](patches/).

The patches are applied before compiling Redlib or building the container image.
Images built by GitHub Actions are published to
`ghcr.io/tiekoetter/redlib-patches`.

## Included patches

- Resolve `www.reddit.com` through `dualstack.reddit.map.fastly.net`. The URL,
  TLS server name, and HTTP Host header remain `www.reddit.com`, while the
  Fastly alias supplies IPv4 and IPv6 destinations for outbound proxy routing.
- Restore thread and comment pages for anonymous clients by percent-encoding
  the comments-route separator in outbound Reddit requests. Both scoped
  `/r/<subreddit>/comments/...` and short `/comments/...` routes are covered.

## Clone and build

```sh
git clone --recurse-submodules https://github.com/tiekoetter/redlib-patches.git
cd redlib-patches
./scripts/build.sh
```

To build a local container image instead:

```sh
./scripts/build-container-image.sh redlib-patches:latest
```

The container build deliberately uses upstream's `Dockerfile.alpine`. The
default upstream `Dockerfile` downloads a prebuilt release and therefore would
not contain this repository's patches.

## Work with the patch series

Apply the current patches to the submodule:

```sh
./scripts/apply-patches.sh
```

To add or edit patches, reset the submodule, make commits on top of its pinned
commit, and regenerate the series:

```sh
./scripts/reset-redlib.sh
git -C redlib switch --detach
# Edit files, then create one or more commits in redlib.
./scripts/format-patches.sh
```

`format-patches.sh` replaces the existing `*.patch` files with one mail-format
patch per commit. `reset-redlib.sh` discards tracked changes and local commits
inside the submodule; build artifacts and other untracked files are preserved.

The scheduled update workflow opens or refreshes a pull request when Redlib's
`main` branch moves. It also reports whether the complete patch series still
applies to the new upstream commit.

## License

Redlib is licensed under the GNU Affero General Public License v3.0. See
[`LICENSE`](LICENSE).
