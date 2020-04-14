// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;

import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'generated/gapiauth2.dart' as auth2;

/// Injects a bunch of libraries in the <head> and returns a
/// Future that resolves when all load.
Future<void> injectJSLibraries(List<String> libraries,
    {html.HtmlElement target /*, Duration timeout */}) {
  final List<Future<void>> loading = <Future<void>>[];
  final List<html.HtmlElement> tags = <html.HtmlElement>[];

  libraries.forEach((String library) {
    final html.ScriptElement script = html.ScriptElement()
      ..async = true
      ..defer = true
      ..src = library;
    // TODO add a timeout race to fail this future
    loading.add(script.onLoad.first);
    tags.add(script);
  });
  (target ?? html.querySelector('head')).children.addAll(tags);
  return Future.wait(loading);
}

/// Utility method that converts `currentUser` to the equivalent
/// [GoogleSignInUserData].
/// This method returns `null` when the [currentUser] is not signed in.
GoogleSignInUserData gapiUserToPluginUserData(auth2.GoogleUser currentUser) {
  final bool isSignedIn = currentUser?.isSignedIn() ?? false;
  final auth2.BasicProfile profile = currentUser?.getBasicProfile();
  if (!isSignedIn || profile?.getId() == null) {
    return null;
  }
  return GoogleSignInUserData(
    displayName: profile?.getName(),
    email: profile?.getEmail(),
    id: profile?.getId(),
    photoUrl: profile?.getImageUrl(),
    idToken: currentUser.getAuthResponse()?.id_token,
  );
}
