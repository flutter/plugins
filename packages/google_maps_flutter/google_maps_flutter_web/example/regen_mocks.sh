#!/usr/bin/bash

flutter pub get

echo "(Re)generating mocks."

flutter pub run build_runner build --delete-conflicting-outputs
