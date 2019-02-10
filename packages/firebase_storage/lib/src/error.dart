// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_storage;

class StorageError {
  static const int unknown = -13000;
  static const int objectNotFound = -13010;
  static const int bucketNotFound = -13011;
  static const int projectNotFound = -13012;
  static const int quotaExceeded = -13013;
  static const int notAuthenticated = -13020;
  static const int notAuthorized = -13021;
  static const int retryLimitExceeded = -13030;
  static const int invalidChecksum = -13031;
  static const int canceled = -13040;
}
