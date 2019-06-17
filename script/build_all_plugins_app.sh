#!/bin/bash

# This script builds the app in flutter/plugins/example/all_plugins to make
# sure all first party plugins can be compiled together.

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"
check_changed_packages > /dev/null

cd $REPO_DIR/examples/all_plugins
flutter clean > /dev/null

function error() {
  echo "$@" 1>&2
}

failures=0

for version in "debug" "release"; do
  (flutter build $@ --$version) > /dev/null

  if [ $? -eq 0 ]; then
    echo "Successfully built $version all_plugins app."
    echo "All first party plugins compile together."
  else
    error "Failed to build $version all_plugins app."
    if [[ "${#CHANGED_PACKAGE_LIST[@]}" == 0 ]]; then
      error "There was a failure to compile all first party plugins together, but there were no changes detected in packages."
    else
      error "Changes to the following packages may prevent all first party plugins from compiling together:"
      for package in "${CHANGED_PACKAGE_LIST[@]}"; do
        error "$package"
      done
      echo ""
    fi
    failures=$(($failures + 1))
  fi
done

exit $failures
