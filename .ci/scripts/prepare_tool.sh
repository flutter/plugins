#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# To set FETCH_HEAD for "git merge-base" to work
git fetch origin master

cd script/tool
dart pub get
