// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of gapi_mocks;

const String gapiInitSuccess = '''
(function() {
    function Gapi() {};
    Gapi.prototype.load = function (script, callback) {
        window.setTimeout(() => {
          callback();
        }, 30);
    };

    window.gapi = new Gapi();
  
    window['$kGapiOnloadCallbackFunctionName']();
  })();
''';
