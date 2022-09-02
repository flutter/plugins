// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:local_auth_windows/local_auth_windows.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  late LocalAuthentication localAuthentication;
  late MockLocalAuthPlatform mockLocalAuthPlatform;

  setUp(() {
    localAuthentication = LocalAuthentication();
    mockLocalAuthPlatform = MockLocalAuthPlatform();
    LocalAuthPlatform.instance = mockLocalAuthPlatform;
  });

  test('authenticate calls platform implementation', () {
    when(mockLocalAuthPlatform.authenticate(
      localizedReason: anyNamed('localizedReason'),
      authMessages: anyNamed('authMessages'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => true);
    localAuthentication.authenticate(localizedReason: 'Test Reason');
    verify(mockLocalAuthPlatform.authenticate(
      localizedReason: 'Test Reason',
      authMessages: <AuthMessages>[
        const IOSAuthMessages(),
        const AndroidAuthMessages(),
        const WindowsAuthMessages(),
      ],
    )).called(1);
  });

  test('isDeviceSupported calls platform implementation', () {
    when(mockLocalAuthPlatform.isDeviceSupported())
        .thenAnswer((_) async => true);
    localAuthentication.isDeviceSupported();
    verify(mockLocalAuthPlatform.isDeviceSupported()).called(1);
  });

  test('getEnrolledBiometrics calls platform implementation', () {
    when(mockLocalAuthPlatform.getEnrolledBiometrics())
        .thenAnswer((_) async => <BiometricType>[]);
    localAuthentication.getAvailableBiometrics();
    verify(mockLocalAuthPlatform.getEnrolledBiometrics()).called(1);
  });

  test('stopAuthentication calls platform implementation', () {
    when(mockLocalAuthPlatform.stopAuthentication())
        .thenAnswer((_) async => true);
    localAuthentication.stopAuthentication();
    verify(mockLocalAuthPlatform.stopAuthentication()).called(1);
  });

  test('canCheckBiometrics returns correct result', () async {
    when(mockLocalAuthPlatform.deviceSupportsBiometrics())
        .thenAnswer((_) async => false);
    bool? result;
    result = await localAuthentication.canCheckBiometrics;
    expect(result, false);
    when(mockLocalAuthPlatform.deviceSupportsBiometrics())
        .thenAnswer((_) async => true);
    result = await localAuthentication.canCheckBiometrics;
    expect(result, true);
    verify(mockLocalAuthPlatform.deviceSupportsBiometrics()).called(2);
  });
}

class MockLocalAuthPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements LocalAuthPlatform {
  MockLocalAuthPlatform() {
    throwOnMissingStub(this);
  }

  @override
  Future<bool> authenticate({
    required String? localizedReason,
    required Iterable<AuthMessages>? authMessages,
    AuthenticationOptions? options = const AuthenticationOptions(),
  }) =>
      super.noSuchMethod(
          Invocation.method(#authenticate, <Object>[], <Symbol, Object?>{
            #localizedReason: localizedReason,
            #authMessages: authMessages,
            #options: options,
          }),
          returnValue: Future<bool>.value(false)) as Future<bool>;

  @override
  Future<List<BiometricType>> getEnrolledBiometrics() =>
      super.noSuchMethod(Invocation.method(#getEnrolledBiometrics, <Object>[]),
              returnValue: Future<List<BiometricType>>.value(<BiometricType>[]))
          as Future<List<BiometricType>>;

  @override
  Future<bool> isDeviceSupported() =>
      super.noSuchMethod(Invocation.method(#isDeviceSupported, <Object>[]),
          returnValue: Future<bool>.value(false)) as Future<bool>;

  @override
  Future<bool> stopAuthentication() =>
      super.noSuchMethod(Invocation.method(#stopAuthentication, <Object>[]),
          returnValue: Future<bool>.value(false)) as Future<bool>;

  @override
  Future<bool> deviceSupportsBiometrics() => super.noSuchMethod(
      Invocation.method(#deviceSupportsBiometrics, <Object>[]),
      returnValue: Future<bool>.value(false)) as Future<bool>;
}
