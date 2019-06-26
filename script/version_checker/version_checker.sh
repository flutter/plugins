#!/bin/bash
#
# Checks to ensure that the versions for all the
# changed packages have been incremented correctly.

set -e

readonly BASE_DIR=$(dirname "$0")
pushd $BASE_DIR

readonly BASE_SHA="$(git merge-base --fork-point FETCH_HEAD HEAD || git merge-base FETCH_HEAD HEAD)"

pub get
pub run lib/main.dart --root_dir "$@" --base_sha "$BASE_SHA"

popd
