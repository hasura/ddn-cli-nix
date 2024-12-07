# Automatically updates ddn.nix to build the given version of the CLI. Run with
# an argument to specify a specific version, e.g. v2.15.0. Or run without
# arguments to automatically select the latest version (requires read access to
# the CLI repo).
#
# Run this script through its nix package:
#
#     $ nix run .#update
#
# Assumes that these environment variables are set:
#
# - BINARY_URL_PATTERN

if [ $# -eq 0 ]; then
  VERSION=""
else
  VERSION="$1"
fi

REPO_URL="${REPO_URL:="git@github.com:hasura/v3-cli-go.git"}";
PACKAGE_EXPRESSION="${PACKAGE_EXPRESSION:="packages/ddn.nix"}";

function list-tags() {
  list-git-tags --url="$REPO_URL" \
    | grep -E "^v[0-9.]+$" # excludes pre-releases
}

function latest-tag() {
  list-tags \
    | sort --version-sort --reverse \
    | head --lines=1
}

function fetch-hash() {
  local url="$1"
  nix store prefetch-file --json "$url" | jq -r .hash
}

function main() {
  local version="${VERSION:=$(latest-tag)}"

  sed -i "s|version\s*=[^;]*;|version = \"$version\";|" "$PACKAGE_EXPRESSION"

  for system in "darwin-amd64" "darwin-arm64" "linux-amd64"; do
    local urlWithVersion="${BINARY_URL_PATTERN//VERSION/$version}"
    local url="${urlWithVersion//PLATFORM-ARCH/$system}"
    local hash
    hash=$(fetch-hash "$url")

    sed -i "s|\"$system\"\s*=[^;]*;|\"$system\" = \"$hash\";|" "$PACKAGE_EXPRESSION"
  done

  # Echo success message to stderr to provide feedback. Echo version to stdout
  # so that another script can easily read the version string.
  >&2 echo "Updated successfully"
  echo "$version"
}

main
