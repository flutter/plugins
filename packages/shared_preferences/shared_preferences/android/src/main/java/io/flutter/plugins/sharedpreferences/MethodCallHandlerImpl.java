// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Looper;
import android.util.Base64;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.SettableFuture;
import com.google.common.util.concurrent.ThreadFactoryBuilder;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.Executor;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Implementation of the {@link MethodChannel.MethodCallHandler} for the plugin. It is also
 * responsible of managing the {@link android.content.SharedPreferences}.
 */
@SuppressWarnings("unchecked")
class MethodCallHandlerImpl implements MethodChannel.MethodCallHandler {

  private static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";
  private static final String SHARED_PREFERENCES_ERROR_CODE = "shared-preferences-error";

  // Fun fact: The following is a base64 encoding of the string "This is the prefix for a list."
  private static final String LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu";
  private static final String BIG_INTEGER_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy";
  private static final String DOUBLE_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu";

  private final android.content.SharedPreferences preferences;
  private final ExecutorService executor;
  private final Executor uiThreadExecutor;

  /**
   * Constructs a {@link MethodCallHandlerImpl} instance. Creates a {@link
   * android.content.SharedPreferences} based on the {@code context}.
   */
  MethodCallHandlerImpl(Context context) {
    preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
    executor = Executors.newSingleThreadExecutor(
        new ThreadFactoryBuilder()
            .setNameFormat("shared-preferences-background-%d")
            .setPriority(Thread.NORM_PRIORITY)
            .build()
    );
    uiThreadExecutor = new UiThreadExecutor();
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull MethodChannel.Result result) {
    String key = call.argument("key");
    try {
      switch (call.method) {
        case "setBool":
          commitAsync(preferences.edit().putBoolean(key, (boolean) call.argument("value")), result);
          break;
        case "setDouble":
          double doubleValue = ((Number) call.argument("value")).doubleValue();
          String doubleValueStr = Double.toString(doubleValue);
          commitAsync(preferences.edit().putString(key, DOUBLE_PREFIX + doubleValueStr), result);
          break;
        case "setInt":
          Number number = call.argument("value");
          if (number instanceof BigInteger) {
            BigInteger integerValue = (BigInteger) number;
            commitAsync(
                preferences
                    .edit()
                    .putString(
                        key, BIG_INTEGER_PREFIX + integerValue.toString(Character.MAX_RADIX)),
                result);
          } else {
            commitAsync(preferences.edit().putLong(key, number.longValue()), result);
          }
          break;
        case "setString":
          String value = (String) call.argument("value");
          if (value.startsWith(LIST_IDENTIFIER) || value.startsWith(BIG_INTEGER_PREFIX)) {
            result.error(
                "StorageError",
                "This string cannot be stored as it clashes with special identifier prefixes.",
                null);
            return;
          }
          commitAsync(preferences.edit().putString(key, value), result);
          break;
        case "setStringList":
          List<String> list = call.argument("value");
          commitAsync(
              preferences.edit().putString(key, LIST_IDENTIFIER + encodeList(list)), result);
          break;
        case "commit":
          // We've been committing the whole time.
          result.success(true);
          break;
        case "getAll":
          result.success(getAllPrefs());
          return;
        case "remove":
          commitAsync(preferences.edit().remove(key), result);
          break;
        case "clear":
          Set<String> keySet = getAllPrefs().keySet();
          SharedPreferences.Editor clearEditor = preferences.edit();
          for (String keyToDelete : keySet) {
            clearEditor.remove(keyToDelete);
          }
          commitAsync(clearEditor, result);
          break;
        default:
          result.notImplemented();
          break;
      }
    } catch (IOException e) {
      result.error("IOException encountered", call.method, e);
    }
  }

  private void commitAsync(
      final SharedPreferences.Editor editor, final MethodChannel.Result result) {
    final SettableFuture<Boolean> future = SettableFuture.create();

    Futures.addCallback(
        future,
        new FutureCallback<Boolean>() {
          @Override
          public void onSuccess(@Nullable Boolean b) {
            if (b != null) {
              result.success(b);
            } else {
              result.error(SHARED_PREFERENCES_ERROR_CODE, "Null result", null);
            }
          }

          @Override
          public void onFailure(@NonNull Throwable t) {
            result.error(SHARED_PREFERENCES_ERROR_CODE, t.getMessage(), null);
          }
        },
        uiThreadExecutor
    );

    executor.execute(new Runnable() {
      @Override
      public void run() {
        try {
          future.set(editor.commit());
        } catch (Throwable t) {
          future.setException(t);
        }
      }
    });
  }

  private List<String> decodeList(String encodedList) throws IOException {
    ObjectInputStream stream = null;
    try {
      stream = new ObjectInputStream(new ByteArrayInputStream(Base64.decode(encodedList, 0)));
      return (List<String>) stream.readObject();
    } catch (ClassNotFoundException e) {
      throw new IOException(e);
    } finally {
      if (stream != null) {
        stream.close();
      }
    }
  }

  private String encodeList(List<String> list) throws IOException {
    ObjectOutputStream stream = null;
    try {
      ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
      stream = new ObjectOutputStream(byteStream);
      stream.writeObject(list);
      stream.flush();
      return Base64.encodeToString(byteStream.toByteArray(), 0);
    } finally {
      if (stream != null) {
        stream.close();
      }
    }
  }

  // Filter preferences to only those set by the flutter app.
  private Map<String, Object> getAllPrefs() throws IOException {
    Map<String, ?> allPrefs = preferences.getAll();
    Map<String, Object> filteredPrefs = new HashMap<>();
    for (String key : allPrefs.keySet()) {
      if (key.startsWith("flutter.")) {
        Object value = allPrefs.get(key);
        if (value instanceof String) {
          String stringValue = (String) value;
          if (stringValue.startsWith(LIST_IDENTIFIER)) {
            value = decodeList(stringValue.substring(LIST_IDENTIFIER.length()));
          } else if (stringValue.startsWith(BIG_INTEGER_PREFIX)) {
            String encoded = stringValue.substring(BIG_INTEGER_PREFIX.length());
            value = new BigInteger(encoded, Character.MAX_RADIX);
          } else if (stringValue.startsWith(DOUBLE_PREFIX)) {
            String doubleStr = stringValue.substring(DOUBLE_PREFIX.length());
            value = Double.valueOf(doubleStr);
          }
        } else if (value instanceof Set) {
          // This only happens for previous usage of setStringSet. The app expects a list.
          List<String> listValue = new ArrayList<>((Set) value);
          // Let's migrate the value too while we are at it.
          boolean success =
              preferences
                  .edit()
                  .remove(key)
                  .putString(key, LIST_IDENTIFIER + encodeList(listValue))
                  .commit();
          if (!success) {
            // If we are unable to migrate the existing preferences, it means we potentially lost them.
            // In this case, an error from getAllPrefs() is appropriate since it will alert the app during plugin initialization.
            throw new IOException("Could not migrate set to list");
          }
          value = listValue;
        }
        filteredPrefs.put(key, value);
      }
    }
    return filteredPrefs;
  }

  public void teardown() {
    executor.shutdown();
  }

  private static class UiThreadExecutor implements Executor {
    private final Handler handler = new Handler(Looper.getMainLooper());

    @Override
    public void execute(Runnable command) {
      handler.post(command);
    }
  }
}
