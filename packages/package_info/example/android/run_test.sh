#!/bin/bash

./gradlew \
    -Pverbose=true \
    -Ptarget=$(pwd)/../test_driver/adapter.dart \
    -Ptrack-widget-creation=false \
    -Pfilesystem-scheme=org-dartlang-root \
    connectedAndroidTest
