{
  description = "Hasura DDN CLI";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          binary-url-pattern = "https://graphql-engine-cdn.hasura.io/ddn/cli/v4/VERSION/cli-ddn-PLATFORM-ARCH";
        in
        {
          packages = rec {
            ddn = pkgs.callPackage ./packages/ddn.nix { inherit binary-url-pattern; };
            default = ddn;

            update = pkgs.writeShellApplication {
              name = "update";
              runtimeInputs = with pkgs; [
                common-updater-scripts # provides list-git-tags
                coreutils
                gnugrep
                jq
              ];
              text = ''
                BINARY_URL_PATTERN='${binary-url-pattern}'
                ${builtins.readFile ./scripts/update.sh}
              '';
            };
          };

        }) // {

      overlays.default = final: prev: {
        ddn = self.packages.${final.system}.default;
      };
    };
}
