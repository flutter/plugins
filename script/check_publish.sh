#!/bin/bash
set -e

# This script checks to make sure that each of the plugins *could* be published.
# It doesn't actually publish anything.

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

function check_publish() {
  local failures=()
  for package_name in "$@"; do
    local dir="$REPO_DIR/packages/$package_name"
    echo "Checking that $package_name can be published."
    if (cd "$dir" && pub publish --dry-run > /dev/null); then
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

# Sets CHANGED_PACKAGE_LIST
check_changed_packages

if [[ "${#CHANGED_PACKAGE_LIST[@]}" != 0 ]]; then
  check_publish "${CHANGED_PACKAGE_LIST[@]}"
fi