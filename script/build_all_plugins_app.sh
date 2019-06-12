#!/bin/bash

# This script builds the app in flutter/plugins/example/all_plugins to make
# sure all first party plugins can be compiled together.

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

function error() {
  echo "$@" 1>&2
}

cd $REPO_DIR/examples/all_plugins
flutter clean > /dev/null

binaries=("apk" "ipa")
versions=("debug" "release")

failures=()

for binary in "${binaries[@]}"; do
  for version in "${versions[@]}"; do
    params=""
    if [ "$binary" = "apk" ]; then
      params="apk"
    elif [ "$binary" = "ipa" ]; then
      params="ios --no-codesign"
    fi

    (flutter build $params --$version) > /dev/null

    exit_status=$?
    binary_version="$version $binary"

    if [ $exit_status -eq 0 ]; then
      echo "Successfully built all_plugins $binary_version." 
    else
      error "Failed to build all_plugins $binary_version."
      failures=("${failures[@]}" "$binary_version")
    fi
  done
done

exit "${#failures[@]}"
