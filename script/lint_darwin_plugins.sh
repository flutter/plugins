#!/bin/bash

# This script lints and tests iOS and macOS platform code.

# So that users can run this script from anywhere and it will work as expected.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

function lint_package() {
  local package_name="$1"
  local package_dir="${REPO_DIR}/packages/$package_name/"
  local failure_count=0

  local skipped_podspecs=(
    'url_launcher_web.podspec'
  )
  find "${package_dir}" -type f -name '*\.podspec' | while read podspec; do
    # These podspecs are temporary multi-platform adoption dummy files.
    if [[ "${skipped_podspecs[*]}" =~ "$(basename ${podspec})" ]]; then
      continue
    fi

    echo "Linting $(basename ${podspec})"

    # Build as frameworks.
    # This will also run any tests set up as a test_spec. See https://blog.cocoapods.org/CocoaPods-1.3.0.
    # TODO: Add --analyze flag https://github.com/flutter/flutter/issues/41443
    # TODO: Remove --allow-warnings flag https://github.com/flutter/flutter/issues/41444
    pod lib lint "${podspec}" --allow-warnings --fail-fast --silent
    if [[ "$?" -ne 0 ]]; then
      error "Package ${package_name} has framework issues. Run \"pod lib lint $podspec\" to inspect."
      failure_count+=1
    fi

    # Build as libraries.
    pod lib lint "${podspec}" --allow-warnings --use-libraries --fail-fast --silent
    if [[ "$?" -ne 0 ]]; then
      error "Package ${package_name} has library issues. Run \"pod lib lint $podspec --use-libraries\" to inspect."
      failure_count+=1
    fi
  done

  return "${failure_count}"
}

function lint_packages() {
  if [[ ! "$(which pod)" ]]; then 
    echo "pod not installed. Skipping."
    return
  fi

  # TODO: These packages have linter errors. Remove plugins from this list as linter issues are fixed.
  local skipped_packages=(
    'battery'
    'google_maps_flutter'
    'google_sign_in'
    'share'
    'webview_flutter'
  )

  local failure_count=0
  for package_name in "$@"; do
    if [[ "${skipped_packages[*]}" =~ "${package_name}" ]]; then
      continue
    fi      
    lint_package "${package_name}"
    failure_count+="$?"
  done

  return "${failure_count}"
}

# Sets CHANGED_PACKAGE_LIST
check_changed_packages

if [[ "${#CHANGED_PACKAGE_LIST[@]}" != 0 ]]; then
  lint_packages "${CHANGED_PACKAGE_LIST[@]}"
fi
