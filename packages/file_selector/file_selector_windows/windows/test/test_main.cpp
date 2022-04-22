// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include <gtest/gtest.h>
#include <windows.h>

int main(int argc, char** argv) {
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  testing::InitGoogleTest(&argc, argv);
  int exit_code = RUN_ALL_TESTS();

  ::CoUninitialize();

  return exit_code;
}
