// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter_driver/flutter_driver.dart';

Future<void> main() async {
  developer.log('====== start tests');
  stderr.writeln('print me');
  print('====== start tests');
  final FlutterDriver driver = await FlutterDriver.connect();
  final String data = await driver.requestData(
    null,
    timeout: const Duration(minutes: 1),
  );
  await driver.close();
  final Map<String, dynamic> result = jsonDecode(data);
  print('====== get result $result');
  exit(result['result'] == 'true' ? 0 : 1);
}
