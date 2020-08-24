// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The JS mock of the global gapi object
String gapi() => '''
function Gapi() {};
Gapi.prototype.load = function (script, cb) {
  window.setTimeout(cb, 30);
};
window.gapi = new Gapi();
''';
