#!/bin/bash
set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

# Plugins that deliberately use their own analysis_options.yaml.
#
# This list should only be deleted from, never added to. This only exists
# because we adopted stricter analysis rules recently and needed to exclude
# already failing packages to start linting the repo as a whole.
#
# TODO(mklim): Remove everything from this list. https://github.com/flutter/flutter/issues/45440
CUSTOM_ANALYSIS_PLUGINS=(
  "in_app_purchase"
  "camera"
  "google_sign_in/google_sign_in"
)
# Comma-separated string of the list above
readonly CUSTOM_FLAG=$(IFS=, ; echo "${CUSTOM_ANALYSIS_PLUGINS[*]}")
# Set some default actions if run without arguments.
ACTIONS=("$@")
if [[ "${#ACTIONS[@]}" == 0 ]]; then
  ACTIONS=("analyze" "--custom-analysis" "$CUSTOM_FLAG" "test" "java-test")
elif [[ "${ACTIONS[@]}" == "analyze" ]]; then
  ACTIONS=("analyze" "--custom-analysis" "$CUSTOM_FLAG")
fi

BRANCH_NAME="${BRANCH_NAME:-"$(git rev-parse --abbrev-ref HEAD)"}"
if [[ "${BRANCH_NAME}" == "master" ]]; then
  echo "Running for all packages"
  (cd "$REPO_DIR" && pub global run flutter_plugin_tools "${ACTIONS[@]}" $PLUGIN_SHARDING)
else
  # Sets CHANGED_PACKAGES
  check_changed_packages

  if [[ "$CHANGED_PACKAGES" == "" ]]; then
    echo "No changes detected in packages."
    echo "Running for all packages"
    (cd "$REPO_DIR" && pub global run flutter_plugin_tools "${ACTIONS[@]}" $PLUGIN_SHARDING)
  else
    echo running "${ACTIONS[@]}"
    (cd "$REPO_DIR" && pub global run flutter_plugin_tools "${ACTIONS[@]}" --plugins="$CHANGED_PACKAGES" $PLUGIN_SHARDING)
    echo "Running version check for changed packages"
    (cd "$REPO_DIR" && pub global run flutter_plugin_tools version-check --base_sha="$(get_branch_base_sha)")
  fi
fi
