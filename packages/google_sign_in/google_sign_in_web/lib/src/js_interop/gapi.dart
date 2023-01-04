// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Type definitions for Google API Client
/// Project: https://github.com/google/google-api-javascript-client
/// Definitions by: Frank M <https://github.com/sgtfrankieboy>, grant <https://github.com/grant>
/// Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped
/// TypeScript Version: 2.3

// https://github.com/DefinitelyTyped/DefinitelyTyped/blob/master/types/gapi

// ignore_for_file: public_member_api_docs, unused_element, sort_constructors_first, prefer_generic_function_type_aliases

@JS()
library gapi;

import 'package:js/js.dart';

// Module gapi
typedef void LoadCallback(
    [dynamic args1,
    dynamic args2,
    dynamic args3,
    dynamic args4,
    dynamic args5]);

@anonymous
@JS()
abstract class LoadConfig {
  external LoadCallback get callback;
  external set callback(LoadCallback v);
  external Function? get onerror;
  external set onerror(Function? v);
  external num? get timeout;
  external set timeout(num? v);
  external Function? get ontimeout;
  external set ontimeout(Function? v);
  external factory LoadConfig(
      {LoadCallback callback,
      Function? onerror,
      num? timeout,
      Function? ontimeout});
}

/*type CallbackOrConfig = LoadConfig | LoadCallback;*/
/// Pragmatically initialize gapi class member.
/// Reference: https://developers.google.com/api-client-library/javascript/reference/referencedocs#gapiloadlibraries-callbackorconfig
@JS('gapi.load')
external void load(
    String apiName, dynamic /*LoadConfig|LoadCallback*/ callback);
// End module gapi

// Manually removed gapi.auth and gapi.client, unused by this plugin.
