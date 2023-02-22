#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# To set FETCH_HEAD for "git merge-base" to work
git fetch origin main

# Pinned version of the plugin tools, to avoid breakage in this repository
# when pushing updates from flutter/packages.
dart pub global activate flutter_plugin_tools 0.13.4+3
