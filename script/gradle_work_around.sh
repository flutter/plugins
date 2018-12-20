#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

# Set some default actions if run without arguments.
ACTIONS=("$@")
if [[ "${#ACTIONS[@]}" == 0 ]]; then
  ACTIONS=("test" "tasks" "testDebugUnitTest")
fi

mv build.gradle _build.gradle
cp $SCRIPT_DIR/build.gradle .

# equivalent to try cache
{ gradle "${ACTIONS[@]}"; } || { EXIT_CODE=$?; }
rm build.gradle
mv _build.gradle build.gradle

exit $EXIT_CODE
