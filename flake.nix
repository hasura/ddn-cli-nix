{
  description = "Hasura DDN CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      eachSystem = callback: nixpkgs.lib.genAttrs systems (system: callback (mkPkgs system));
      binary-url-pattern = "https://graphql-engine-cdn.hasura.io/ddn/cli/v4/VERSION/cli-ddn-PLATFORM-ARCH";
    in
    {
      packages = eachSystem (pkgs: rec {
        default = ddn;
        ddn = pkgs.callPackage ./packages/ddn.nix { inherit binary-url-pattern; };

        update = pkgs.writeShellApplication {
          name = "update";
          runtimeInputs = with pkgs; [
            coreutils
            curl
            gnugrep
            jq
          ];
          text = ''
            BINARY_URL_PATTERN='${binary-url-pattern}'
            ${builtins.readFile ./scripts/update.sh}
          '';
        };
      });

      checks = eachSystem (pkgs: {
        default = pkgs.callPackage ./packages/check.nix {
          ddn = self.packages.${pkgs.system}.ddn;
        };
      });

      overlays.default = final: prev: {
        ddn = self.packages.${final.system}.default;
      };
    };
}
