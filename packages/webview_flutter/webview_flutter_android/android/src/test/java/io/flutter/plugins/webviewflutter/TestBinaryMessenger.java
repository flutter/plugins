// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.BinaryMessenger;
import java.nio.ByteBuffer;

public class TestBinaryMessenger implements BinaryMessenger {
  @Override
  public void send(@NonNull String s, @Nullable ByteBuffer byteBuffer) {}

  @Override
  public void send(
      @NonNull String s, @Nullable ByteBuffer byteBuffer, @Nullable BinaryReply binaryReply) {}

  @Override
  public void setMessageHandler(
      @NonNull String s, @Nullable BinaryMessageHandler binaryMessageHandler) {}
}
