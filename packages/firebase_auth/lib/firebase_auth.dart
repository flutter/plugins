// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library firebase_auth;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

part 'src/auth_provider/email_auth_provider.dart';
part 'src/auth_provider/facebook_auth_provider.dart';
part 'src/auth_provider/github_auth_provider.dart';
part 'src/auth_provider/google_auth_provider.dart';
part 'src/auth_provider/phone_auth_provider.dart';
part 'src/auth_provider/twitter_auth_provider.dart';
part 'src/auth_credential.dart';
part 'src/auth_exception.dart';
part 'src/firebase_auth.dart';
part 'src/firebase_user.dart';
part 'src/user_info.dart';
part 'src/user_metadata.dart';
part 'src/user_update_info.dart';
