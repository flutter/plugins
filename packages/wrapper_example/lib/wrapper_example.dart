// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library wrapper_example;

import 'src/base_object.dart';
import 'src/example_library.pigeon.dart';
import 'src/my_class.dart';

export 'src/base_object.dart' show BaseObject;
export 'src/my_class.dart' show MyClass;
export 'src/my_other_class.dart' show MyOtherClass;

class WrapperExample {
  static void registerWith() {
    BaseObjectFlutterApi.setup(BaseObjectFlutterApiImpl());
    MyClassFlutterApi.setup(MyClassFlutterApiImpl());
  }
}
