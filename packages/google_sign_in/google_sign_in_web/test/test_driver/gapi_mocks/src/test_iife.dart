// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_sign_in_web/src/load_gapi.dart'
    show kGapiOnloadCallbackFunctionName;

// Wraps some JS mock code in an IIFE that ends by calling the onLoad dart callback.
String testIife(String mock) => '''
(function() {
  $mock;
  window['$kGapiOnloadCallbackFunctionName']();
})();
'''
    .replaceAll(RegExp(r'\s{2,}'), '');
