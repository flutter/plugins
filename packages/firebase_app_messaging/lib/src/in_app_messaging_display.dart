// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_in_app_messaging;

abstract class InAppMessagingDisplay {
  void displayMessage(InAppMessagingDisplayMessage message, InAppMessagingDisplayDelegate delegate);
}
