// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cloud_firestore;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show hashValues, hashList;

import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'src/utils/push_id_generator.dart';

part 'src/blob.dart';
part 'src/collection_reference.dart';
part 'src/document_change.dart';
part 'src/document_reference.dart';
part 'src/document_snapshot.dart';
part 'src/field_value.dart';
part 'src/firestore.dart';
part 'src/firestore_message_codec.dart';
part 'src/geo_point.dart';
part 'src/query.dart';
part 'src/query_snapshot.dart';
part 'src/snapshot_metadata.dart';
part 'src/timestamp.dart';
part 'src/transaction.dart';
part 'src/write_batch.dart';
