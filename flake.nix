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

          # If you change this version you will have to update all of the hashes below.
          # You can get each hash by running:
          #
          #     $ nix store prefetch-file <url>
          #
          # Make sure to preserve the "sha256-" prefix when pasting here.
          ver = "v2.0.1";
          url = arch: "https://graphql-engine-cdn.hasura.io/ddn/cli/v4/${ver}/cli-ddn-${arch}";

          sysSpec = 
              if system == "x86_64-linux" then rec
                { 
                  arch = "linux-amd64";
                  src = pkgs.fetchurl {
                    url = url arch;
                    sha256 = "sha256-wnkF5F8X697KgH/ALaRGKSEth0ldN094HvkydOPBc9E=";
                  };
                }
              else if system == "x86_64-darwin" then rec
                { 
                  arch = "darwin-amd64";
                  src = pkgs.fetchurl {
                    url = url arch;
                    sha256 = "sha256-1/QyYdqBDFvbuHyDbQ5pq6YEr0CouNc2J41xnu9/XVA=";
                  };
                }
              else if system == "aarch64-darwin" then rec
                { 
                  arch = "darwin-arm64";
                  src = pkgs.fetchurl {
                    url = url arch;
                    sha256 = "sha256-sw7X+vO9oYnDObvv0Ol5Eo2Fz9rLwax9iOnRWCz4Td4=";
                  };
                }
              else builtins.throw "Unsupported system";
      in
        { 
          packages.default = pkgs.stdenv.mkDerivation rec {
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
        }) // {

      overlays.default = final: prev: {
        ddn = self.packages.${final.system}.default;
      };
    };
}
