{ binary-url-pattern
, buildFHSEnv
, fetchurl
}:
let
  version = "v2.29.0";
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
    "linux-amd64" = "sha256-fhDV21fYRtqrYsCEL2yk9q3flalgTwb2fnDsYzvFZGg=";
    "darwin-amd64" = "sha256-xshfm2QHAywAZ0jRbmyfm8mvvDx4f4OYEcYHdNH7ZpY=";
    "darwin-arm64" = "sha256-yQr1DWcbTKzycafqXJ/4WZSP1ux4KpnufykYgtFrC98=";
  }.${system};
  src = system: fetchurl {
    url = src-url version system;
    hash = hash (go-system system);
  };

  # This function defines a package containing the DDN CLI binary, and nothing
  # else.
  ddn-unwrapped = { lib, hostPlatform, stdenvNoCC }: stdenvNoCC.mkDerivation {
    name = "ddn-unwrapped";
    inherit version;
    src = src hostPlatform.system;
    phases = [ "installPhase" "patchPhase" ];
    installPhase = ''
      mkdir -p "$out/bin"
      cp "$src" "$out/bin/ddn"
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
  };
in
# The CLI binary is statically-linked, but it contains an embedded executable
  # that is dynamically-linked, and requires /lib64/ld-linux-x86-64.so.2. So we
  # need to build an FHS wrapper to provide the necessary interpreter at the
  # expected path.
buildFHSEnv {
  name = "ddn";
  targetPkgs = pkgs: [ (pkgs.callPackage ddn-unwrapped { }) ];
  runScript = "ddn";
}
