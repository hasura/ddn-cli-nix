# Checks that the ddn package builds and contains the expected version string.
# If this derivation fails to build that means something is wrong.
{ ddn
, bintools
, coreutils
, gnugrep
, stdenvNoCC
}:

stdenvNoCC.mkDerivation {
  name = "ddn-checks";
  src = ./.;
  buildInputs = [
    bintools # provides `strings` command
    coreutils
    gnugrep
  ];
  buildPhase = ''
    expected_version="${ddn.version}"

    # Scan the binary for the version number instead of running `ddn --version`
    # because when the program runs it connects to the internet to check for an
    # updated version, and that doesn't work in the nix build sandbox.
    actual_version="$(strings ${ddn}/bin/ddn | grep -Po '(?<=BuildVersion=)\S+' | head -n1)"

    if [ "$expected_version" != "$actual_version" ]; then
      echo "Expected version: $expected_version"
      echo "Actual version: $actual_version"
      echo
      echo 'You might see this error if you updated "version" in packages/ddn.nix, but did not update hashes correctly.'
      exit 1
    fi

    echo "ok! ddn's reported version matches the expected version, $expected_version"
  '';
  installPhase = ''
    echo "ok" > "$out"
  '';
}
