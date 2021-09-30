// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A instantiable class that extends [GoogleIdentity]
class _TestGoogleIdentity extends GoogleIdentity {
  _TestGoogleIdentity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String email;

  final String? displayName;

  final String? photoUrl;
}

/// A mocked [HttpClient] which always returns a [_MockHttpRequest].
class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  void addCredentials(
      Uri url, String realm, HttpClientCredentials credentials) {}

  @override
  void addProxyCredentials(
      String host, int port, String realm, HttpClientCredentials credentials) {}

  @override
  set authenticate(
      Future<bool> Function(Uri url, String scheme, String realm)? f) {}

  @override
  set authenticateProxy(
      Future<bool> Function(String host, int port, String scheme, String realm)?
          f) {}

  @override
  set badCertificateCallback(
      bool Function(X509Certificate cert, String host, int port)? callback) {}

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    throw UnimplementedError();
  }

  @override
  set findProxy(String Function(Uri url)? f) {}

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return Future<HttpClientRequest>.value(_MockHttpRequest());
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientRequest> open(
      String method, String host, int port, String path) {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    throw UnimplementedError();
  }
}

/// A mocked [HttpClientRequest] which always returns a [_MockHttpClientResponse].
class _MockHttpRequest extends HttpClientRequest {
  @override
  late Encoding encoding;

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientResponse> close() {
    return Future<HttpClientResponse>.value(_MockHttpResponse());
  }

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  List<Cookie> get cookies => <Cookie>[];

  @override
  Future<HttpClientResponse> get done async => _MockHttpResponse();

  @override
  Future<void> flush() {
    return Future<void>.value();
  }

  @override
  String get method => '';

  @override
  Uri get uri => Uri();

  @override
  void write(Object? obj) {}

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? obj = '']) {}
}

/// This is an transparent 1x1 gif image
final Uint8List _transparentImage = Uint8List.fromList(
  [
    71,
    73,
    70,
    56,
    57,
    97,
    1,
    0,
    1,
    0,
    128,
    0,
    0,
    255,
    255,
    255,
    0,
    0,
    0,
    33,
    249,
    4,
    1,
    0,
    0,
    0,
    0,
    44,
    0,
    0,
    0,
    0,
    1,
    0,
    1,
    0,
    0,
    2,
    2,
    68,
    1,
    0,
    59,
  ],
);

/// A mocked [HttpClientResponse] which is empty and has a [statusCode] of 200
/// and returns a 1x1 transparent image.
class _MockHttpResponse implements HttpClientResponse {
  final Stream<Uint8List> _delegate =
      Stream<Uint8List>.value(_transparentImage);

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  int get contentLength => -1;

  @override
  HttpClientResponseCompressionState get compressionState {
    return HttpClientResponseCompressionState.decompressed;
  }

  @override
  List<Cookie> get cookies => <Cookie>[];

  @override
  Future<Socket> detachSocket() {
    return Future<Socket>.error(UnsupportedError('Mocked response'));
  }

  @override
  bool get isRedirect => false;

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _delegate.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => '';

  @override
  Future<HttpClientResponse> redirect(
      [String? method, Uri? url, bool? followLoops]) {
    return Future<HttpClientResponse>.error(
        UnsupportedError('Mocked response'));
  }

  @override
  List<RedirectInfo> get redirects => <RedirectInfo>[];

  @override
  int get statusCode => 200;

  @override
  Future<bool> any(bool Function(Uint8List element) test) {
    return _delegate.any(test);
  }

  @override
  Stream<Uint8List> asBroadcastStream({
    void Function(StreamSubscription<Uint8List> subscription)? onListen,
    void Function(StreamSubscription<Uint8List> subscription)? onCancel,
  }) {
    return _delegate.asBroadcastStream(onListen: onListen, onCancel: onCancel);
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(Uint8List event) convert) {
    return _delegate.asyncExpand<E>(convert);
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(Uint8List event) convert) {
    return _delegate.asyncMap<E>(convert);
  }

  @override
  Stream<R> cast<R>() {
    return _delegate.cast<R>();
  }

  @override
  Future<bool> contains(Object? needle) {
    return _delegate.contains(needle);
  }

  @override
  Stream<Uint8List> distinct(
      [bool Function(Uint8List previous, Uint8List next)? equals]) {
    return _delegate.distinct(equals);
  }

  @override
  Future<E> drain<E>([E? futureValue]) {
    return _delegate.drain<E>(futureValue);
  }

  @override
  Future<Uint8List> elementAt(int index) {
    return _delegate.elementAt(index);
  }

  @override
  Future<bool> every(bool Function(Uint8List element) test) {
    return _delegate.every(test);
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(Uint8List element) convert) {
    return _delegate.expand(convert);
  }

  @override
  Future<Uint8List> get first => _delegate.first;

  @override
  Future<Uint8List> firstWhere(
    bool Function(Uint8List element) test, {
    List<int> Function()? orElse,
  }) {
    return _delegate.firstWhere(test,
        orElse: orElse == null
            ? null
            : () {
                return Uint8List.fromList(orElse());
              });
  }

  @override
  Future<S> fold<S>(
      S initialValue, S Function(S previous, Uint8List element) combine) {
    return _delegate.fold<S>(initialValue, combine);
  }

  @override
  Future<dynamic> forEach(void Function(Uint8List element) action) {
    return _delegate.forEach(action);
  }

  @override
  Stream<Uint8List> handleError(
    Function onError, {
    bool Function(dynamic error)? test,
  }) {
    return _delegate.handleError(onError, test: test);
  }

  @override
  bool get isBroadcast => _delegate.isBroadcast;

  @override
  Future<bool> get isEmpty => _delegate.isEmpty;

  @override
  Future<String> join([String separator = '']) {
    return _delegate.join(separator);
  }

  @override
  Future<Uint8List> get last => _delegate.last;

  @override
  Future<Uint8List> lastWhere(
    bool Function(Uint8List element) test, {
    List<int> Function()? orElse,
  }) {
    return _delegate.lastWhere(test,
        orElse: orElse == null
            ? null
            : () {
                return Uint8List.fromList(orElse());
              });
  }

  @override
  Future<int> get length => _delegate.length;

  @override
  Stream<S> map<S>(S Function(Uint8List event) convert) {
    return _delegate.map<S>(convert);
  }

  @override
  Future<dynamic> pipe(StreamConsumer<List<int>> streamConsumer) {
    return _delegate.cast<List<int>>().pipe(streamConsumer);
  }

  @override
  Future<Uint8List> reduce(
      List<int> Function(Uint8List previous, Uint8List element) combine) {
    return _delegate.reduce((Uint8List previous, Uint8List element) {
      return Uint8List.fromList(combine(previous, element));
    });
  }

  @override
  Future<Uint8List> get single => _delegate.single;

  @override
  Future<Uint8List> singleWhere(bool Function(Uint8List element) test,
      {List<int> Function()? orElse}) {
    return _delegate.singleWhere(test,
        orElse: orElse == null
            ? null
            : () {
                return Uint8List.fromList(orElse());
              });
  }

  @override
  Stream<Uint8List> skip(int count) {
    return _delegate.skip(count);
  }

  @override
  Stream<Uint8List> skipWhile(bool Function(Uint8List element) test) {
    return _delegate.skipWhile(test);
  }

  @override
  Stream<Uint8List> take(int count) {
    return _delegate.take(count);
  }

  @override
  Stream<Uint8List> takeWhile(bool Function(Uint8List element) test) {
    return _delegate.takeWhile(test);
  }

  @override
  Stream<Uint8List> timeout(
    Duration timeLimit, {
    void Function(EventSink<Uint8List> sink)? onTimeout,
  }) {
    return _delegate.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<List<Uint8List>> toList() {
    return _delegate.toList();
  }

  @override
  Future<Set<Uint8List>> toSet() {
    return _delegate.toSet();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    return _delegate.cast<List<int>>().transform<S>(streamTransformer);
  }

  @override
  Stream<Uint8List> where(bool Function(Uint8List event) test) {
    return _delegate.where(test);
  }
}

/// A mocked [HttpHeaders] that ignores all writes.
class _MockHttpHeaders extends HttpHeaders {
  @override
  List<String>? operator [](String name) => <String>[];

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void clear() {}

  @override
  void forEach(void Function(String name, List<String> values) f) {}

  @override
  void noFolding(String name) {}

  @override
  void remove(String name, Object value) {}

  @override
  void removeAll(String name) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  String? value(String name) => null;
}

void main() {
  testWidgets('It should build th GoogleUserCircleAvatar successfully',
      (WidgetTester tester) async {
    final GoogleIdentity identity = _TestGoogleIdentity(
      email: 'email@email.com',
      id: 'userId',
      photoUrl: 'photoUrl',
    );
    tester.binding.window.physicalSizeTestValue = Size(100, 100);

    await HttpOverrides.runZoned(
      () async {
        await tester.pumpWidget(MaterialApp(
          home: SizedBox(
            height: 100,
            width: 100,
            child: GoogleUserCircleAvatar(
              identity: identity,
            ),
          ),
        ));
      },
      createHttpClient: (SecurityContext? c) => _MockHttpClient(),
    );
  });
}
