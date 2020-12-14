#!/bin/bash

# This script contains the list of plugins migrated to nnbd
# that should be excluded from testing on Flutter stable until
# null-safe is available on stable.

readonly NNBD_PLUGINS_LIST=(
  "flutter_webview"
)

export EXCLUDED_PLUGINS_FROM_STABLE=$(IFS=, ; echo "${NNBD_PLUGINS_LIST[*]}")
