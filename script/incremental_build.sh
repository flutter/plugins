#!/bin/bash

set -ev

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

if [ "${BRANCH_NAME}" = "master" ]; then
  echo "Running for all packages"
  pub global run flutter_plugin_tools "$@"
else
  # Make sure there is up-to-date master.
  git fetch origin master

  FLUTTER_CHANGED_GLOBAL=0
  FLUTTER_CHANGED_PACKAGES=""

  # Try get a merge base for the branch and calculate affected packages.
  # We need this check because some CIs can do a single branch clones with a limited history of commits.
  if BRANCH_BASE_SHA=$(git merge-base --fork-point FETCH_HEAD HEAD); then
    echo "Checking changes from $BRANCH_BASE_SHA..."
    FLUTTER_CHANGED_GLOBAL=`git diff --name-only $BRANCH_BASE_SHA HEAD | grep -v packages | wc -l`
    FLUTTER_CHANGED_PACKAGES=`git diff --name-only $BRANCH_BASE_SHA HEAD | grep -o "packages/[^/]*" | sed -e "s/packages\///g" | sort | uniq | paste -s -d, -`
  else
    echo "Cannot find a merge base for the current branch to run an incremental build..."
    echo "Please rebase your branch onto the latest master!"
  fi

  if [ "${FLUTTER_CHANGED_PACKAGES}" = "" ] || [ $FLUTTER_CHANGED_GLOBAL -gt 0 ]; then
    echo "Running for all packages"
    pub global run flutter_plugin_tools "$@"
  else
    echo "Running only for $FLUTTER_CHANGED_PACKAGES"
    pub global run flutter_plugin_tools "$@" --plugins=$FLUTTER_CHANGED_PACKAGES
  fi
fi
