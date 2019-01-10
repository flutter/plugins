// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_in_app_messaging;

enum InAppMessagingDismissType {
  /// user swipes away the banner view
  InAppMessagingDismissTypeUserSwipe,

  /// user clicks on close buttons
  InAppMessagingDismissTypeUserTapClose,

  /// automatic dismiss from banner view
  InAppMessagingDismissTypeAuto,

  /// message is dismissed, but not belonging to any
  /// above dismiss category
  InAppMessagingDismissUnspecified,
}

class InAppMessagingDisplayDelegate {
  // TODO(jackson): Implement
  void messageDismissed(InAppMessagingDismissType type) {}

  // TODO(jackson): Implement
  void messageClicked() {}

  // TODO(jackson): Implement
  void impressionDetected() {}

  // TODO(jackson): Implement
  void displayErrorEncountered(dynamic error) {}
}
