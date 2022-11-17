#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

<<<<<<< HEAD
cd all_packages
flutter build windows --debug
flutter build windows --release
=======
platform="$1"
build_mode="$2"
cd all_packages
flutter build "$platform" --"$build_mode"
>>>>>>> e500884c758c2d516baf7d5ab30639c81dd6b849
