{ hostPlatform
, fetchurl
, stdenvNoCC
, lib
, binary-url-pattern
}:
let
  version = "v3.2.0";
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
    "linux-amd64" = "sha256-jx43K8BUpNttkwAHWTFMrt0nt9g1wvC8CxzACJxJz8o=";
    "darwin-amd64" = "sha256-agEnsyPepdGcx+aIxm5NBUzhuggq02tM2w8jQz/3aJQ=";
    "darwin-arm64" = "sha256-UCrzhFuRX2fD78dePupSpWwpvUZB/c6vpGFvPW4CZAM=";
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
