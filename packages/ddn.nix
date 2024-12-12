{ hostPlatform
, fetchurl
, stdenvNoCC
, lib
, binary-url-pattern
}:
let
  version = "v2.17.1";
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
    "linux-amd64" = "sha256-JDE7wnR7T48AuVOl5X34ghSreMcJQpN+kqLTxQRQH+k=";
    "darwin-amd64" = "sha256-xUW8OBob1LSUlahWU1k/9mp1pO1Y5BB6TDdWpcUV1oM=";
    "darwin-arm64" = "sha256-C+Nz8kunkr4pNOqsMoKZUEwQ7wPfnWVLtxNfuG0/CC0=";
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
