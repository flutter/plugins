#!/bin/bash
set -e

# This script checks to make sure that each of the plugins *could* be published.
# It doesn't actually publish anything.

# So that users can run this script from anywhere and it will work as expected.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

# Sets CHANGED_PACKAGE_LIST and CHANGED_PACKAGES
check_changed_packages

if [[ "${#CHANGED_PACKAGE_LIST[@]}" != 0 ]]; then
  plugin_tools publish-check --plugins="${CHANGED_PACKAGES}"
fi
