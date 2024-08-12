## Example flake.nix

```nix
{
  description = "..";

  inputs = {
     nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
     flake-utils.url = "github:numtide/flake-utils";
     ddnPkg.url = "github:TheInnerLight/hasura-ddn-cli-nix";
     
  };

  outputs = { self, nixpkgs, flake-utils, ddnPkg }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          ddn = ddnPkg.defaultPackage.${system};
          lib =  nixpkgs.lib;
      in {
        devShell = pkgs.mkShell rec {
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
