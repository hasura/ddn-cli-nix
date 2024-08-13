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
          ver = "v2.0.0";
          sysSpec = 
              if system == "x86_64-linux" then rec
                { 
                  arch = "linux-amd64";
                  src = pkgs.fetchurl {
                    url = "https://graphql-engine-cdn.hasura.io/ddn/cli/v3.1/${ver}/cli-ddn-${arch}";
                    sha256 = "sha256-Qylj1bqFHTfvscv740R82tYe6y4t562VUs/+pofFDT8=";
                  };
                }
              else if system == "x86_64-darwin" then rec
                { 
                  arch = "darwin-amd64";
                  src = pkgs.fetchurl {
                    url = "https://graphql-engine-cdn.hasura.io/ddn/cli/v3.1/${ver}/cli-ddn-${arch}";
                    sha256 = "sha256-f+ryrtpEsrsebhA389/CLIQTjFzyXWQkL2E2hCcs9yM=";
                  };
                }
              else if system == "aarch64-darwin" then rec
                { 
                  arch = "darwin-arm64";
                  src = pkgs.fetchurl {
                    url = "https://graphql-engine-cdn.hasura.io/ddn/cli/v3.1/${ver}/cli-ddn-${arch}";
                    sha256 = "sha256-M7+yvNYfUUK9IaZODykaKAaAZ6O6BCKySxyMfpIMJZk=";
                  };
                }
              else builtins.throw "Unsupported system";
      in
        { 
          defaultPackage = pkgs.stdenv.mkDerivation rec {
            name = "ddn";

            version = ver;

            arch = sysSpec.arch;

            # https://nixos.wiki/wiki/Packaging/Binaries
            src = sysSpec.src;

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
              platforms = platforms.all;
            };
          };
        });
}