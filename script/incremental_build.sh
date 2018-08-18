#!/bin/bash
set -e
set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

function error() {
  echo "$@" 1>&2
}

CHANGED_PACKAGES=""

function check_changed_packages() {
  # Try get a merge base for the branch and calculate affected packages.
  # We need this check because some CIs can do a single branch clones with a limited history of commits.
  local packages
  local branch_base_sha="$(git merge-base --fork-point FETCH_HEAD HEAD || git merge-base FETCH_HEAD HEAD)"
#  local branch_base_sha="$(git merge-base --fork-point master || git merge-base master)"
  if [[ "$?" == 0 ]]; then
    echo "Checking for changed packages from $branch_base_sha"
    IFS=$'\n' packages=( $(git diff --name-only "$branch_base_sha" HEAD | grep -o "packages/[^/]*" | sed -e "s/packages\///g" | sort | uniq) )
  else
    error "Cannot find a merge base for the current branch to run an incremental build..."
    error "Please rebase your branch onto the latest master!"
    return 1
  fi

  # Filter out any packages that don't have a pubspec.yaml: they have probably
  # been deleted in this PR.
  CHANGED_PACKAGES=""
  local package_set=()
  for package in "${packages[@]}"; do
    if [[ -f "$REPO_DIR/packages/$package/pubspec.yaml" ]]; then
      CHANGED_PACKAGES="${CHANGED_PACKAGES},$package"
      package_set=("${package_set[@]}" "$package")
    fi
  done

  if [[ "${#package_set[@]}" == 0 ]]; then
    echo "No changes detected in packages. Skipping."
    return 0
  else
    echo "Detected changes in the following ${#package_set[@]} package(s):"
    for package in "${package_set[@]}"; do
      echo "$package"
    done
    echo ""
  fi
}

# Set some default actions if run without arguments.
ACTIONS=("$@")
if [[ "${#ACTIONS[@]}" == 0 ]]; then
  ACTIONS=("test" "analyze" "java-test")
fi

BRANCH_NAME="${BRANCH_NAME:-"$(git rev-parse --abbrev-ref HEAD)"}"
if [[ "${BRANCH_NAME}" == "master" ]]; then
  echo "Running for all packages"
  (cd "$REPO_DIR" && pub global run flutter_plugin_tools "${ACTIONS[@]}" $PLUGIN_SHARDING)
else
  check_changed_packages
  echo "Environment:"
  env
  echo "---------------------"
  if [[ "$CHANGED_PACKAGES" == "" ]]; then
    echo "Running for all packages"
    (cd "$REPO_DIR" && pub global run flutter_plugin_tools "${ACTIONS[@]}" $PLUGIN_SHARDING)
  else
    (cd "$REPO_DIR" && pub global run flutter_plugin_tools "${ACTIONS[@]}" --plugins="$CHANGED_PACKAGES" $PLUGIN_SHARDING)
  fi
fi
