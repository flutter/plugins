#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

platform="$1"
build_mode="$2"
shift 2
cd all_packages
flutter build "$platform" --"$build_mode" "$@"
