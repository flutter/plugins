#!/bin/bash
set -ev
if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
  pub global run flutter_plugin_tools "$@"
else
  export FLUTTER_CHANGED_PACKAGES=`git diff --name-only $TRAVIS_COMMIT_RANGE | grep -o "packages/[^/]*" | sed -e "s/packages\///g" | sort | uniq | paste -s -d, -`
  pub global run flutter_plugin_tools "$@" --plugins=$FLUTTER_CHANGED_PACKAGES
fi
