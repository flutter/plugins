#!/bin/bash
set -e

# This script checks to make sure that if LIBRARY_VERSION is hard coded, it is set
# to match the version in pubspec.yaml. This allows plugins to report their version
# for analytics purposes. See https://github.com/flutter/flutter/issues/32267

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

function check_hard_coded_version() {
  local failures=()
  for package_name in "$@"; do
    local dir="$REPO_DIR/packages/$package_name"
    echo "Checking that $package_name has the correct hard coded version, if any."
    PACKAGE_VERSION="$(cd "$dir" && cat pubspec.yaml | grep -E "^version: " | awk '{print $2}')"
    IOS_VERSION="$(cd "$dir" && grep -r "#define LIBRARY_VERSION" ios/Classes/*.m | awk '{print $3}')"
    ANDROID_VERSION="$(cd "$dir" && grep -r LIBRARY_VERSION android/src/main/java/* | awk '{print $8}')"
    if [[ "$IOS_VERSION" == "" && "$ANDROID_VERSION" == "" ]]; then
      echo "No hard coded version found"
    elif [[ "$IOS_VERSION" == "@\"$PACKAGE_VERSION\"" && "$ANDROID_VERSION" == "\"$PACKAGE_VERSION\";" ]]; then
      echo "Hard coded version matched: $PACKAGE_VERSION"
    else
      error "Hard coded version check failed for $package_name"
      error "pubspec.yaml version: $PACKAGE_VERSION"
      error "Android version: $ANDROID_VERSION"
      error "iOS version: $IOS_VERSION"
      failures=("${failures[@]}" "$package_name")
    fi
  done
  if [[ "${#failures[@]}" != 0 ]]; then
    error "FAIL: The following ${#failures[@]} package(s) failed the hard coded version check:"
    for failure in "${failures[@]}"; do
      error "$failure"
    done
  fi
  return "${#failures[@]}"
}

# Sets CHANGED_PACKAGE_LIST
check_changed_packages

if [[ "${#CHANGED_PACKAGE_LIST[@]}" != 0 ]]; then
  check_hard_coded_version "${CHANGED_PACKAGE_LIST[@]}"
fi
