#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

if [ -z "$PACKAGE" ]; then
    echo "Need to set PACKAGE env var"
    exit 1
fi

cd $REPO_DIR/packages/$PACKAGE/example/ios/
xcodebuild \
  -scheme Runner \
  -workspace Runner.xcworkspace \
  -sdk iphonesimulator GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES \
  -destination 'platform=iOS Simulator,name=iPhone 6' \
  -enableCodeCoverage YES \
  test

bash <(curl -s https://codecov.io/bash) -cF "$PACKAGE"
