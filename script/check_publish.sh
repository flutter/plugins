#!/bin/bash
set -e

# This script checks to make sure that each of the plugins *could* be published.
# It doesn't actually publish anything.

# So that users can run this script from anywhere and it will work as expected.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

function check_publish() {
  local failures=()
  for dir in $(pub global run flutter_plugin_tools list --plugins="$1"); do
    local package_name=$(basename "$dir")

    echo "Checking that $package_name can be published."
    if [[ $(cd "$dir" && cat pubspec.yaml | grep -E "^publish_to: none") ]]; then
      echo "Package $package_name is marked as unpublishable. Skipping."
    elif (cd "$dir" && flutter pub publish -- --dry-run > /dev/null); then
      echo "Package $package_name is able to be published."
    else
      error "Unable to publish $package_name"
      failures=("${failures[@]}" "$package_name")
    fi
  done
  if [[ "${#failures[@]}" != 0 ]]; then
    error "FAIL: The following ${#failures[@]} package(s) failed the publishing check:"
    for failure in "${failures[@]}"; do
      error "$failure"
    done
  fi
  return "${#failures[@]}"
}

# Sets CHANGED_PACKAGE_LIST and CHANGED_PACKAGES
check_changed_packages

if [[ "${#CHANGED_PACKAGE_LIST[@]}" != 0 ]]; then
  check_publish "${CHANGED_PACKAGES}"
fi
