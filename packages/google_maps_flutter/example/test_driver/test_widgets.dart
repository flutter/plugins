// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';

Future<void> pumpWidget(Widget widget) {
  runApp(widget);
  return WidgetsBinding.instance.endOfFrame;
}
