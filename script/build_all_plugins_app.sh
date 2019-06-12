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

failures=()

for version in "debug" "release"; do
  (flutter build $@ --$version) > /dev/null

  if [ $? -eq 0 ]; then
    echo "Successfully built $version all_plugins app."
  else
    error "Failed to build $version all_plugins app."
    failures=("${failures[@]}")
  fi
done

exit "${#failures[@]}"
