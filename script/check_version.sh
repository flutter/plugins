#!/bin/bash
set -e

# So that users can run this script from anywhere and it will work as expected.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

# Sets CHANGED_PACKAGE_LIST and CHANGED_PACKAGES
check_changed_packages

plugin_tools version-check --base_sha="$(get_branch_base_sha)"
# if [[ "${#CHANGED_PACKAGE_LIST[@]}" != 0 ]]; then
# fi
