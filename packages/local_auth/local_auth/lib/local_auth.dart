// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

export 'package:local_auth/src/local_auth.dart' show LocalAuthentication;

// TODO(BeMacized): This should be removed the next time a breaking change
// occurs and LocalAuth#authenticate is removed. Packages will be expected
// to depend on the platform specific packages directly if they wish to use
// these classes.
export 'package:local_auth_android/types/auth_messages_android.dart'
    show AndroidAuthMessages;
// TODO(BeMacized): This should be removed the next time a breaking change
// occurs and LocalAuth#authenticate is removed. Packages will be expected
// to depend on the platform specific packages directly if they wish to use
// these classes.
export 'package:local_auth_ios/types/auth_messages_ios.dart'
    show IOSAuthMessages;
export 'package:local_auth_platform_interface/types/auth_options.dart'
    show AuthenticationOptions;
export 'package:local_auth_platform_interface/types/biometric_type.dart'
    show BiometricType;
