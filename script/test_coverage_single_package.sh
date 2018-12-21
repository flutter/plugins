#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

if [ -z "$PACKAGE" ]; then
    echo "Need to set PACKAGE env var"
    exit 1
fi

cd $REPO_DIR/packages/$PACKAGE/example/android/
./gradlew jacocoTestDebugUnitTestReport
cd $REPO_DIR/packages/$PACKAGE
flutter test --coverage

cd $REPO_DIR
bash <(curl -s https://codecov.io/bash) -B "$PACKAGE/$BRANCH_NAME" -s packages/$PACKAGE
