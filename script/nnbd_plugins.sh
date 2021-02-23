#!/bin/bash

# This script contains the list of plugins migrated to nnbd
# that should be excluded from testing on Flutter stable until
# null-safe is available on stable.

readonly NNBD_PLUGINS_LIST=(
  "android_alarm_manager"
  "android_intent"
  "battery"
  "camera"
  "camera_platform_interface"
  "connectivity"
  "cross_file"
  "device_info"
  "file_selector"
  "flutter_plugin_android_lifecycle"
  "flutter_webview"
  "google_maps_flutter"
  "google_sign_in"
  "image_picker"
  "ios_platform_images"
  "local_auth"
  "path_provider"
  "package_info"
  "plugin_platform_interface"
  "quick_actions"
  "sensors"
  "share"
  "shared_preferences"
  "url_launcher"
  "video_player"
  "webview_flutter"
  "wifi_info_flutter"
  "in_app_purchase"
)

# This list contains the list of plugins that have *not* been
# migrated to nnbd, and conflict with those that have when
# building the all plugins app. This list should be kept empty.

readonly NON_NNBD_PLUGINS_LIST=(
  "extension_google_sign_in_as_googleapis_auth"
  "google_maps_flutter_web" # Not yet migrated.
)

export EXCLUDED_PLUGINS_FROM_STABLE=$(IFS=, ; echo "${NNBD_PLUGINS_LIST[*]}")
export EXCLUDED_PLUGINS_FOR_NNBD=$(IFS=, ; echo "${NON_NNBD_PLUGINS_LIST[*]}")
