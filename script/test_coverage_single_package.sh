#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

if [ -z "$PACKAGE" ]; then
    echo "Need to set PACKAGE env var"
    exit 1
fi

cd packages/$PACKAGE
flutter test --coverage
cd android
$SCRIPT_DIR/gradle_work_around.sh jacocoTestDebugUnitTestReport

cd $REPO_DIR
bash <(curl -s https://codecov.io/bash) -B "$PACKAGE/$BRANCH_NAME" -s packages/$PACKAGE
