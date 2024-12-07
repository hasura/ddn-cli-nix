# Hasura DDN CLI packaged for Nix

This repo provides Nix packages for the [Hasura v3 CLI][] via a flake.

[Hasura v3 CLI]: https://hasura.io/docs/3.0/cli/overview/

To run the CLI directly run,

```sh
$ nix run github:hasura/ddn-cli-nix
```

You probably want to use the flake in this repository as a flake input in your
own configuration.

## Example flake.nix

```nix
{
  description = "..";

  inputs = {
     nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
     flake-utils.url = "github:numtide/flake-utils";
     ddnPkg.url = "github:hasura/ddn-cli-nix";
  };

  outputs = { self, nixpkgs, flake-utils, ddnPkg }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          ddn = ddnPkg.packages.${system}.default;
      in {
        devShell = pkgs.mkShell {
          buildInputs = [
            ddn
          ];
        };
      });
}
```

0. Install [nix](https://nixos.org/) and ensure [flakes](https://nixos.wiki/wiki/Flakes) are enabled
1. Run `nix develop`
2. `ddn` is now available in your shell

## Updating

The packages in this repo package a specific version of the CLI. To update the
packages to the latest CLI version run the update script:

```
$ nix run .#update
```

This requires read access to the CLI source repository to get a list of tags. It
is also possible to update without repository access by specifying a specific
version:

```
$ nix run .#update v2.15.0
```

Packages can only be set to use versions that have binaries published on
Hasura's CDN.
