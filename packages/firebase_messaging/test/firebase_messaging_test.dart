// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

void main() {
  MockMethodChannel mockChannel;
  FirebaseMessaging firebaseMessaging;

  setUp(() {
    mockChannel = new MockMethodChannel();
    firebaseMessaging = new FirebaseMessaging.private(
        mockChannel, new FakePlatform(operatingSystem: 'ios'));
  });

  test('requestNotificationPermissions on ios with default permissions', () {
    firebaseMessaging.requestNotificationPermissions();
    verify(mockChannel.invokeMethod('requestNotificationPermissions',
        {'sound': true, 'badge': true, 'alert': true}));
  });

  test('requestNotificationPermissions on ios with custom permissions', () {
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: false));
    verify(mockChannel.invokeMethod('requestNotificationPermissions',
        {'sound': false, 'badge': true, 'alert': true}));
  });

  test('requestNotificationPermissions on android', () {
    firebaseMessaging = new FirebaseMessaging.private(
        mockChannel, new FakePlatform(operatingSystem: 'android'));

    firebaseMessaging.requestNotificationPermissions();
    verifyZeroInteractions(mockChannel);
  });

  test('requestNotificationPermissions on android', () {
    firebaseMessaging = new FirebaseMessaging.private(
        mockChannel, new FakePlatform(operatingSystem: 'android'));

    firebaseMessaging.requestNotificationPermissions();
    verifyZeroInteractions(mockChannel);
  });

  test('configure', () {
    firebaseMessaging.configure();
    verify(mockChannel.setMethodCallHandler(any));
    verify(mockChannel.invokeMethod('configure'));
  });

  test('incoming token', () async {
    firebaseMessaging.configure();
    dynamic handler =
        verify(mockChannel.setMethodCallHandler(captureAny)).captured.single;
    String token1 = 'I am a super secret token';
    String token2 = 'I am the new token in town';
    Future<String> tokenFromStream = firebaseMessaging.onTokenRefresh.first;
    await handler(new MethodCall('onToken', token1));

    expect(await firebaseMessaging.getToken(), token1);
    expect(await tokenFromStream, token1);

    tokenFromStream = firebaseMessaging.onTokenRefresh.first;
    await handler(new MethodCall('onToken', token2));

    expect(await firebaseMessaging.getToken(), token2);
    expect(await tokenFromStream, token2);
  });

  test('incoming iOS settings', () async {
    firebaseMessaging.configure();
    dynamic handler =
        verify(mockChannel.setMethodCallHandler(captureAny)).captured.single;
    IosNotificationSettings iosSettings = new IosNotificationSettings();

    Future<IosNotificationSettings> iosSettingsFromStream =
        firebaseMessaging.onIosSettingsRegistered.first;
    await handler(
        new MethodCall('onIosSettingsRegistered', iosSettings.toMap()));
    expect((await iosSettingsFromStream).toMap(), iosSettings.toMap());

    iosSettings = new IosNotificationSettings(sound: false);
    iosSettingsFromStream = firebaseMessaging.onIosSettingsRegistered.first;
    await handler(
        new MethodCall('onIosSettingsRegistered', iosSettings.toMap()));
    expect((await iosSettingsFromStream).toMap(), iosSettings.toMap());
  });

  test('incoming messages', () async {
    Completer onMessage = new Completer();
    Completer onLaunch = new Completer();
    Completer onResume = new Completer();

    firebaseMessaging.configure(onMessage: (m) {
      onMessage.complete(m);
    }, onLaunch: (m) {
      onLaunch.complete(m);
    }, onResume: (m) {
      onResume.complete(m);
    });
    dynamic handler =
        verify(mockChannel.setMethodCallHandler(captureAny)).captured.single;

    Object onMessageMessage = new Object();
    Object onLaunchMessage = new Object();
    Object onResumeMessage = new Object();

    await handler(new MethodCall('onMessage', onMessageMessage));
    expect(await onMessage.future, onMessageMessage);
    expect(onLaunch.isCompleted, isFalse);
    expect(onResume.isCompleted, isFalse);

    await handler(new MethodCall('onLaunch', onLaunchMessage));
    expect(await onLaunch.future, onLaunchMessage);
    expect(onResume.isCompleted, isFalse);

    await handler(new MethodCall('onResume', onResumeMessage));
    expect(await onResume.future, onResumeMessage);
  });

  const String myTopic = 'Flutter';

  test('subscribe to topic', () {
    firebaseMessaging.subscribeToTopic(myTopic);
    verify(mockChannel.invokeMethod('subscribeToTopic', myTopic));
  });

  test('unsubscribe from topic', () {
    firebaseMessaging.unsubscribeFromTopic(myTopic);
    verify(mockChannel.invokeMethod('unsubscribeFromTopic', myTopic));
  });
}

class MockMethodChannel extends Mock implements MethodChannel {}
