// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_in_app_messaging;

class InAppMessagingDisplayMessage {
  InAppMessagingDisplayMessage._({ this.messageID, this.renderAsTestMessage });
  final String messageID;
  final bool renderAsTestMessage;

  @override
  String toString() => '$runtimeType[$messageID, $renderAsTestMessage]';

  @override
  bool operator ==(Object o) {
    return o is InAppMessagingDisplayMessage &&
        messageID == o.messageID &&
        renderAsTestMessage == o.renderAsTestMessage;
  }

  @override
  int get hashCode => hashValues(messageID, renderAsTestMessage);
}