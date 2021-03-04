#!/bin/bash

#  Usage:
#
#   ./script/build_all_plugins_app.sh apk
#   ./script/build_all_plugins_app.sh ios

# This script builds the app in flutter/plugins/example/all_plugins to make
# sure all first party plugins can be compiled together.

# So that users can run this script from anywhere and it will work as expected.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"

readonly REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

check_changed_packages > /dev/null

# This list should be kept as short as possible, and things should remain here
# only as long as necessary, since in general the goal is for all of the latest
# versions of plugins to be mutually compatible.
#
# An example use case for this list would be to temporarily add plugins while
# updating multiple plugins for a breaking change in a common dependency in
# cases where using a relaxed version constraint isn't possible.
readonly EXCLUDED_PLUGINS_LIST=(
  "plugin_platform_interface" # This should never be a direct app dependency.
  "extension_google_sign_in_as_googleapis_auth" # Transitive dependency issues
      # with integration_test.
)
# Comma-separated string of the list above
readonly EXCLUDED=$(IFS=, ; echo "${EXCLUDED_PLUGINS_LIST[*]}")

ALL_EXCLUDED=($EXCLUDED)

echo "Excluding the following plugins: $ALL_EXCLUDED"

(cd "$REPO_DIR" && plugin_tools all-plugins-app --exclude $ALL_EXCLUDED)

function error() {
  echo "$@" 1>&2
}

failures=0

for version in "debug" "release"; do
  (cd $REPO_DIR/all_plugins && flutter build $@ --$version)

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

rm -rf $REPO_DIR/all_plugins/
exit $failures
