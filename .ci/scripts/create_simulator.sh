#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

device=com.apple.CoreSimulator.SimDeviceType.iPhone-13
os=com.apple.CoreSimulator.SimRuntime.iOS-16-0

xcrun simctl list
xcrun simctl create Flutter-iPhone "$device" "$os" | xargs xcrun simctl boot
