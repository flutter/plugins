// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html' as html;
import 'dart:convert';

String resource(String name) =>
    Uri.parse(html.document.baseUri).resolve(name).toString();

String toBase64Url(String contents) {
  // Open the file
  return 'data:text/javascript;base64,' + base64.encode(utf8.encode(contents));
}
