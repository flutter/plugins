#!/usr/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

flutter pub get

echo "(Re)generating mocks."

flutter pub run build_runner build --delete-conflicting-outputs
