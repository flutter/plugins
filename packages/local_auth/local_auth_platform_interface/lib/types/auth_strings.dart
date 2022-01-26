// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:intl/intl.dart';

/// Message shown on a button that the user can click to go to settings pages
/// from the current dialog. It is used on both Android and iOS sides.
/// Maximum 30 characters.
String get goToSettings => Intl.message('Go to settings',
    desc: 'Message shown on a button that the user can click to go to '
        'settings pages from the current dialog. It is used on both Android '
        'and iOS sides. Maximum 30 characters.');
