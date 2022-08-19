// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file exists solely to host compiled excerpts for README.md, and is not
// intended for use as an actual example application.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
// #docregion ErrorHandling
import 'package:flutter/services.dart';
// #docregion NoErrorDialogs
import 'package:local_auth/error_codes.dart' as auth_error;
// #enddocregion NoErrorDialogs
// #docregion CanCheck
import 'package:local_auth/local_auth.dart';
// #enddocregion CanCheck
// #enddocregion ErrorHandling

// #docregion CustomMessages
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
// #enddocregion CustomMessages

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // #docregion CanCheck
  // #docregion ErrorHandling
  final LocalAuthentication auth = LocalAuthentication();
  // #enddocregion CanCheck
  // #enddocregion ErrorHandling

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('README example app'),
        ),
        body: const Text('See example in main.dart'),
      ),
    );
  }

  Future<void> checkSupport() async {
    // #docregion CanCheck
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    // #enddocregion CanCheck

    print('Can authenticate: $canAuthenticate');
    print('Can authenticate with biometrics: $canAuthenticateWithBiometrics');
  }

  Future<void> getEnrolledBiometrics() async {
    // #docregion Enrolled
    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (availableBiometrics.isNotEmpty) {
      // Some biometrics are enrolled.
    }

    if (availableBiometrics.contains(BiometricType.strong) ||
        availableBiometrics.contains(BiometricType.face)) {
      // Specific types of biometrics are available.
      // Use checks like this with caution!
    }
    // #enddocregion Enrolled
  }

  Future<void> authenticate() async {
    // #docregion AuthAny
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to show account balance');
      // #enddocregion AuthAny
      print(didAuthenticate);
      // #docregion AuthAny
    } on PlatformException {
      // ...
    }
    // #enddocregion AuthAny
  }

  Future<void> authenticateWithBiometrics() async {
    // #docregion AuthBioOnly
    final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to show account balance',
        options: const AuthenticationOptions(biometricOnly: true));
    // #enddocregion AuthBioOnly
    print(didAuthenticate);
  }

  Future<void> authenticateWithoutDialogs() async {
    // #docregion NoErrorDialogs
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to show account balance',
          options: const AuthenticationOptions(useErrorDialogs: false));
      // #enddocregion NoErrorDialogs
      print(didAuthenticate ? 'Success!' : 'Failure');
      // #docregion NoErrorDialogs
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Add handling of no hardware here.
      } else if (e.code == auth_error.notEnrolled) {
        // ...
      } else {
        // ...
      }
    }
    // #enddocregion NoErrorDialogs
  }

  Future<void> authenticateWithErrorHandling() async {
    // #docregion ErrorHandling
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to show account balance',
          options: const AuthenticationOptions(useErrorDialogs: false));
      // #enddocregion ErrorHandling
      print(didAuthenticate ? 'Success!' : 'Failure');
      // #docregion ErrorHandling
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        // Add handling of no hardware here.
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        // ...
      } else {
        // ...
      }
    }
    // #enddocregion ErrorHandling
  }

  Future<void> authenticateWithCustomDialogMessages() async {
    // #docregion CustomMessages
    final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to show account balance',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Oops! Biometric authentication required!',
            cancelButton: 'No thanks',
          ),
          IOSAuthMessages(
            cancelButton: 'No thanks',
          ),
        ]);
    // #enddocregion CustomMessages
    print(didAuthenticate ? 'Success!' : 'Failure');
  }
}
