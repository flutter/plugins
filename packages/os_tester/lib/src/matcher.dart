// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of os_tester;

/// Matchers
class Matcher {
  Matcher._(this._data);

  factory Matcher.visible() => Matcher._({ 'visible': true });

  final dynamic _data;
}
