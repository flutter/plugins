// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>
#include <gtk/gtk.h>

int main(int argc, char** argv) {
  gtk_init(0, nullptr);

  testing::InitGoogleTest(&argc, argv);
  int exit_code = RUN_ALL_TESTS();

  return exit_code;
}
