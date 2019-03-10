// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.os.AsyncTask;
import androidx.core.util.Consumer;

public class BitmapAsyncGenerator extends AsyncTask<Void, Void, String> {

  private Consumer<String> callback;
  private Supplier<String> generateAction;

  public BitmapAsyncGenerator(Consumer<String> callback, Supplier<String> generateAction) {
    this.callback = callback;
    this.generateAction = generateAction;
  }

  @Override
  protected String doInBackground(Void... voids) {
    return generateAction.get();
  }

  @Override
  protected void onPostExecute(String bitmapFilePath) {
    super.onPostExecute(bitmapFilePath);
    callback.accept(bitmapFilePath);
    callback = null;
    generateAction = null;
  }
}
