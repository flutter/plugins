// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;

import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'generated/gapiauth2.dart' as auth2;

/// Injects a list of JS [libraries] as `script` tags into a [target] [html.HtmlElement].
///
/// If [target] is not provided, it defaults to the web app's `head` tag (see `web/index.html`).
/// [libraries] is a list of URLs that are used as the `src` attribute of `script` tags
/// to which an `onLoad` listener is attached (one per URL).
///
/// Returns a [Future] that resolves when all of the `script` tags `onLoad` events trigger.
Future<void> injectJSLibraries(
  List<String> libraries, {
  html.HtmlElement? target,
}) {
  final List<Future<void>> loading = <Future<void>>[];
  final List<html.HtmlElement> tags = <html.HtmlElement>[];

  final html.Element targetElement = target ?? html.querySelector('head')!;

  for (final String library in libraries) {
    final html.ScriptElement script = html.ScriptElement()
      ..async = true
      ..defer = true
      ..src = library;
    // TODO(ditman): add a timeout race to fail this future
    loading.add(script.onLoad.first);
    tags.add(script);
  }

  targetElement.children.addAll(tags);
  return Future.wait(loading);
}

/// Utility method that converts `currentUser` to the equivalent [GoogleSignInUserData].
///
/// This method returns `null` when the [currentUser] is not signed in.
GoogleSignInUserData? gapiUserToPluginUserData(auth2.GoogleUser? currentUser) {
  final bool isSignedIn = currentUser?.isSignedIn() ?? false;
  final auth2.BasicProfile? profile = currentUser?.getBasicProfile();
  if (!isSignedIn || profile?.getId() == null) {
    return null;
  }

  return GoogleSignInUserData(
    displayName: profile?.getName(),
    email: profile?.getEmail() ?? '',
    id: profile?.getId() ?? '',
    photoUrl: profile?.getImageUrl(),
    idToken: currentUser?.getAuthResponse().id_token,
  );
}
