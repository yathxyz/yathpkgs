# yathpkgs

Packages and NixOS modules for my own software, each pinned to a release.

The package set is `x86_64-linux` only, like both upstream flakes. Use a named
package, e.g. `nix build .#edwin`. There is no `default` package: upstream's
two defaults already have the names `edwin` and `workbench`.

## Layout and pins

- `flake.nix`: release tag URLs, package exports, overlay, modules, and checks.
- `flake.lock`: Nix's record of the exact revisions and hashes.
- `scripts/update`: release tag lookup, lock refresh, and build verification.

We use tagged upstream flake inputs so the packages and modules come from
upstream without copying their build logic.
Workbench follows our Edwin pin, and both use the nixpkgs locked by Edwin.
Nix records the resolved revisions and hashes and fetches the inputs directly,
without building sources during evaluation.

Edwin v0.1.2 exports the desktop module under both names, so we import its
shipped system module directly for `nixosModules.edwind`.

## Updating

```sh
nix develop -c scripts/update edwin
nix develop -c scripts/update --all
```

The script picks the highest version-sorted `v*` tag on GitHub, checks the
candidate before replacing the tag and lock, and never commits. An unchanged
tag leaves both files alone.

To add a program, add a `name.url = "github:owner/repo/vX.Y.Z";` line to
`inputs`, wire any dependency follows, and add the upstream named packages
and modules to `outputs`. Run `nix flake lock` and `nix flake check`.
