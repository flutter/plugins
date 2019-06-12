#!/bin/bash

# This script builds the app in flutter/plugins/example/all_plugins to make
# sure all first party plugins can be compiled together.

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

versions=("debug" "release")
platforms=("apk" "ios --no-codesign")
failures=()

cd $REPO_DIR/examples/all_plugins

for platform in "${platforms[@]}"; do
  for version in "${versions[@]}"; do
    (flutter build $platform --$version) > /dev/null

    if [ $? -eq 0 ]; then
      echo "Successfully built all_plugins $version $platform." 
    else
      error "Failed to build all_plugins $version $platform."
      failures=("${failures[@]}" "$version $platform")
    fi
  done
done

exit "${#failures[@]}"
