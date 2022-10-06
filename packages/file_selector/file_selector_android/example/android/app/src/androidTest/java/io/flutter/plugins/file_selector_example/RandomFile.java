// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector_example;

import android.content.Context;
import android.net.Uri;
import androidx.core.content.FileProvider;
import androidx.test.platform.app.InstrumentationRegistry;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;

public class RandomFile {
  final String m_generatedContent = RandomString.generate(16);
  final File m_file;

  RandomFile(String fileName) {
    Context appContext = InstrumentationRegistry.getInstrumentation().getTargetContext();
    m_file = generateFilenameInCache(appContext, fileName);
  }

  private File generateFilenameInCache(Context ctx, String fileName) {
    File cacheDir = ctx.getCacheDir();
    File subDir = new File(cacheDir, "shared");
    subDir.mkdir();

    while (true) {
      File fileInCache = new File(subDir, fileName);
      if (!fileInCache.exists()) {
        return fileInCache;
      }
    }
  }

  void writeGeneratedContentToFile() throws IOException {
    try (OutputStream outputStream = new FileOutputStream(m_file)) {
      try (OutputStreamWriter outputStreamWriter = new OutputStreamWriter(outputStream)) {
        outputStreamWriter.write(m_generatedContent);
      }
    }
  }

  String readFromFile() throws IOException {
    try (OutputStream outputStream = new ByteArrayOutputStream(16)) {
      try (InputStream inputStream = new FileInputStream(m_file)) {
        final byte[] buffer = new byte[16];
        int didRead;
        while (0 < (didRead = inputStream.read(buffer))) {
          outputStream.write(buffer, 0, didRead);
        }
      }
      return outputStream.toString();
    }
  }

  Uri getUriFromFileProvider() {
    Context appContext = InstrumentationRegistry.getInstrumentation().getTargetContext();
    String authority = appContext.getPackageName() + ".instrumentedTestsProvider";
    return FileProvider.getUriForFile(appContext, authority, m_file);
  }

  void delete() {
    m_file.delete();
  }
}
