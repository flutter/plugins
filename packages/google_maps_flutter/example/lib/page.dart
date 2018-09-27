// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

abstract class Page extends StatelessWidget {
  const Page(this.leading, this.title);

  final Widget leading;
  final String title;
}
