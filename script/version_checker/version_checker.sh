#!/bin/bash
#
# Checks to ensure that the versions for all the
# changed packages have been incremented correctly.

set -e

readonly BASE_DIR=$(dirname "$0")
pushd $BASE_DIR

pub get
pub run lib/main.dart "$@"

popd
