#!/bin/bash
set -ev

if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
  echo "Running for all packages"
  pub global run flutter_plugin_tools "$@"
else
  FLUTTER_CHANGED_GLOBAL=`git diff --name-only $TRAVIS_COMMIT_RANGE | grep -v packages | wc -l`
  FLUTTER_CHANGED_PACKAGES=`git diff --name-only $TRAVIS_COMMIT_RANGE | grep -o "packages/[^/]*" | sed -e "s/packages\///g" | sort | uniq | paste -s -d, -`
  if [ "${FLUTTER_CHANGED_PACKAGES}" = "" ] || [ $FLUTTER_CHANGED_GLOBAL -gt 0 ]; then
    echo "Running for all packages"
    pub global run flutter_plugin_tools "$@"
  else
    echo "Running only for $FLUTTER_CHANGED_PACKAGES"
    pub global run flutter_plugin_tools "$@" --plugins=$FLUTTER_CHANGED_PACKAGES
  fi
fi
