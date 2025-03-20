{ hostPlatform
, fetchurl
, stdenvNoCC
, lib
, binary-url-pattern
}:
let
  version = "v2.26.2";
  src-url = version: system: builtins.replaceStrings
    [ "VERSION" "PLATFORM-ARCH" ]
    [ version (go-system system) ]
    binary-url-pattern
  ;
  go-system = system: {
    "x86_64-linux" = "linux-amd64";
    "x86_64-darwin" = "darwin-amd64";
    "aarch64-darwin" = "darwin-arm64";
  }.${system};
  hash = system: {
    "linux-amd64" = "sha256-FX38yfr7O53ZZGdCmge7jlt5KDY+8JRZwvV7Ki/RV04=";
    "darwin-amd64" = "sha256-F/NZkEYDZzhU1J3HxwBgD9l6YWGTuO3vOj2Bgn1c26I=";
    "darwin-arm64" = "sha256-GaQfQ3xDnz4qZZYB49t6MwRLx4O+ACSV/62GFovCe7w=";
  }.${system};
  src = system: fetchurl {
    url = src-url version system;
    hash = hash (go-system system);
  };
in
stdenvNoCC.mkDerivation {
  name = "ddn";
  inherit version;
  src = src hostPlatform.system;
  phases = [ "installPhase" "patchPhase" ];
  installPhase = ''
    mkdir -p "$out/bin"
    cp $src "$out/bin/ddn"
    chmod +x "$out/bin/ddn"
  '';

  meta = {
    description = "CLI for managing Hasura DDN data graphs";
    homepage = "https://hasura.io/docs/3.0/cli/overview/";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "ddn";
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
