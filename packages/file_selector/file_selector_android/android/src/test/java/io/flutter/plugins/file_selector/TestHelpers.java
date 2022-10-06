// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector;

import android.net.Uri;
import java.util.ArrayList;
import java.util.List;

public class TestHelpers {

  public static Messages.SelectionOptions buildSelectionOptions(
      List<String> allowedTypes, Boolean allowMultiple) {
    return new Messages.SelectionOptions.Builder()
        .setAllowedTypes(allowedTypes)
        .setAllowMultiple(allowMultiple)
        .build();
  }

  public static ArrayList<Uri> setMockUris(int uriCount, Uri mockUri) {
    ArrayList<Uri> mockUris = new ArrayList<>();

    for (int i = 0; i < uriCount; i++) {
      mockUris.add(mockUri);
    }
    return mockUris;
  }
}
