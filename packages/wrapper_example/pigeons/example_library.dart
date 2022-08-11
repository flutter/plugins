import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/example_library.pigeon.dart',
    dartTestOut: 'test/test_example_library.pigeon.dart',
    dartOptions: DartOptions(copyrightHeader: <String>[
      'Copyright 2013 The Flutter Authors. All rights reserved.',
      'Use of this source code is governed by a BSD-style license that can be',
      'found in the LICENSE file.',
    ]),
    javaOut:
        'android/src/main/java/com/example/wrapper_example/GeneratedExampleLibraryApis.java',
    javaOptions: JavaOptions(
      package: 'com.example.wrapper_example',
      className: 'GeneratedExampleLibraryApis',
      copyrightHeader: <String>[
        'Copyright 2013 The Flutter Authors. All rights reserved.',
        'Use of this source code is governed by a BSD-style license that can be',
        'found in the LICENSE file.',
      ],
    ),
    objcHeaderOut: 'ios/Classes/FWEGeneratedExampleLibraryAPIs.h',
    objcSourceOut: 'ios/Classes/FWEGeneratedExampleLibraryAPIs.m',
    objcOptions: ObjcOptions(
      header: 'ios/Classes/FWEGeneratedExampleLibraryApis.h',
      prefix: 'FWE',
      copyrightHeader: <String>[
        'Copyright 2013 The Flutter Authors. All rights reserved.',
        'Use of this source code is governed by a BSD-style license that can be',
        'found in the LICENSE file.',
      ],
    ),
  ),
)

/// Handles methods calls to the native base object class.
///
/// Also handles calls to remove the reference to an instance with `dispose`.
///
/// For Java:
/// See https://docs.oracle.com/javase/7/docs/api/java/lang/Object.html.
///
/// For Objective-C:
/// See https://developer.apple.com/documentation/objectivec/nsobject.
@HostApi(dartHostTestHandler: 'TestBaseObjectHostApi')
abstract class BaseObjectHostApi {
  /// Removes object from native InstanceManager.
  void dispose(int identifier);
}

/// Handles callbacks methods for the native base object class.
///
/// For Java:
/// See https://docs.oracle.com/javase/7/docs/api/java/lang/Object.html.
///
/// For Objective-C:
/// See https://developer.apple.com/documentation/objectivec/nsobject.
@FlutterApi()
abstract class BaseObjectFlutterApi {
  /// Removes object from Dart InstanceManager.
  void dispose(int identifier);
}

/// Handles methods calls to the native MyClass class.
///
/// See <link-to-docs>.
@HostApi(dartHostTestHandler: 'TestMyClassHostApi')
abstract class MyClassHostApi {
  /// Create the Java instance.
  void create(int identifier, String primitiveField, int classFieldIdentifier);

  void myStaticMethod();

  void myMethod(
    int identifier,
    String primitiveParam,
    int classParamIdentifier,
  );

  void attachClassField(int identifier, int classFieldIdentifier);
}

/// Handles callbacks methods for the native MyClass class.
///
/// See <link-to-docs>.
@FlutterApi()
abstract class MyClassFlutterApi {
  /// Create the Dart instance.
  void create(int identifier, String primitiveField, int classFieldIdentifier);

  void myCallbackMethod(int identifier);
}

/// Handles methods calls to the native MyOtherClass class.
///
/// See <link-to-docs>.
@HostApi(dartHostTestHandler: 'TestMyOtherClassHostApi')
abstract class MyOtherClassHostApi {
  void create(int identifier);
}

/// Handles callbacks methods for the native MyOtherClass class.
///
/// See <link-to-docs>.
@FlutterApi()
abstract class MyOtherClassFlutterApi {
  void create(int identifier);
}

@HostApi(dartHostTestHandler: 'TestMyClassSubclassHostApi')
abstract class MyClassSubclassHostApi {
  void create(int identifier, String primitiveField, int classFieldIdentifier);
}
