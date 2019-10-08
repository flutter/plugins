#!/bin/sh

suffix=${CIRCLE_BRANCH}_$(date -d "today" +"%Y%m%d%H%M")
cp ./build/app/outputs/apk/release/app-release.apk ./app_name$suffix.apk
./google-cloud-sdk/bin/gsutil cp ./app_name$suffix.apk gs://built-apk
./google-cloud-sdk/bin/gsutil acl ch -u AllUsers:R gs://built-apk/app_name$suffix.apk