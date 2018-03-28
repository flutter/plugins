// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cloud_firestore;

import 'dart:async';
import 'dart:convert';
import 'dart:ui' show hashValues, hashList;

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

import 'src/utils/push_id_generator.dart';

part 'src/collection_reference.dart';
part 'src/document_change.dart';
part 'src/document_snapshot.dart';
part 'src/document_reference.dart';
part 'src/firestore.dart';
part 'src/query.dart';
part 'src/query_snapshot.dart';
part 'src/set_options.dart';
part 'src/write_batch.dart';
