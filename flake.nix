{
  description = "Hasura DDN CLI";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          lib =  nixpkgs.lib;
      in
        { 
          defaultPackage = pkgs.stdenv.mkDerivation rec {
            name = "ddn";

            version = "v2.0.0";

            arch = if system == "x86_64-linux" then "linux-amd64"
                   else if system == "x86_64-darwin" then "darwin-amd64"
                   else if system == "aarch64-darwin" then "darwin-arm64"
                   else builtins.throw "Unsupported system";

            # https://nixos.wiki/wiki/Packaging/Binaries
            src = pkgs.fetchurl {
              url = "https://graphql-engine-cdn.hasura.io/ddn/cli/v3.1/${version}/cli-ddn-${arch}";
              sha256 = "sha256-Qylj1bqFHTfvscv740R82tYe6y4t562VUs/+pofFDT8=";
            };

            sourceRoot = ".";

            dontUnpack = true;

            installPhase = ''
            runHook preInstall
            install -m755 -D ${src} $out/bin/ddn
            runHook postInstall
            '';

            meta = with lib; {
              homepage = "https://hasura.io/ddn";
              description = "Hasura DDN";
              platforms = platforms.linux;
            };
          };
        });
}