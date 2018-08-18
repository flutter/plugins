#!/bin/bash
set -e

# This script checks to make sure that each of the plugins *could* be published.
# It doesn't acutually publish anything.

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

function error() {
  echo "$@" 1>&2
}

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
    echo "FAIL: The following ${#failures[@]} package(s) failed the publishing check:"
    for failure in "${failures[@]}"; do
      echo "$failure"
    done
  fi
  return "${#failures[@]}"
}

function check_changed_packages() {
  # Try get a merge base for the branch and calculate affected packages.
  # We need this check because some CIs can do a single branch clones with a limited history of commits.
  # If merge-base --fork-point can't be found (it's more conservative), then use regular merge-base.
  local branch_base_sha="$(git merge-base --fork-point FETCH_HEAD HEAD || git merge-base FETCH_HEAD HEAD)"
  echo "Checking for changed packages from $branch_base_sha"
  local packages
  if [[ "$?" == 0 ]]; then
    IFS=$'\n' packages=( $(git diff --name-only "$branch_base_sha" HEAD | grep -o "packages/[^/]*" | sed -e "s/packages\///g" | sort | uniq) )
  else
    error "Cannot find a merge base for the current branch to run an incremental build..."
    error "Please rebase your branch onto the latest master!"
    return 1
  fi

  # Filter out any packages that don't have a pubspec.yaml: they have probably
  # been deleted in this PR.
  local existing=()
  for package in "${packages[@]}"; do
    if [[ -f "$REPO_DIR/packages/$package/pubspec.yaml" ]]; then
      existing=("${existing[@]}" "$package")
    fi
  done
  
  if [[ "${#existing[@]}" == 0 ]]; then
    echo "No changes detected in packages. Skipping publish check."
    return 0
  else
    echo "Detected changes in the following ${#existing[@]} package(s):"
    for package in "${existing[@]}"; do
      echo "$package"
    done
    echo ""
  fi

  check_publish "${existing[@]}"
}

check_changed_packages "$@"

