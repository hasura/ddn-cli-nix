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
