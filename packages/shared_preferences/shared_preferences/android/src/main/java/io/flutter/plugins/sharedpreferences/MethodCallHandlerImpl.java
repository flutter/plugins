// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.util.Base64;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
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
import java.util.Optional;
import java.util.Set;

/**
 * Implementation of the {@link MethodChannel.MethodCallHandler} for the plugin. It is also
 * responsible of managing the {@link android.content.SharedPreferences}.
 */
@SuppressWarnings("unchecked")
class MethodCallHandlerImpl implements MethodChannel.MethodCallHandler {

  private static final String SHARED_PREFERENCES_DEFAULT_NAME = "FlutterSharedPreferences";
  private static final String CHANNEL_NAME = "plugins.flutter.io/shared_preferences";
  private static final String PREFIX = "flutter.";

  // Fun fact: The following is a base64 encoding of the string "This is the
  // prefix for a list."
  private static final String LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu";
  private static final String BIG_INTEGER_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy";
  private static final String DOUBLE_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu";

  private final Context context;
  private final HashMap<String, SharedPreferences> instances;

  /**
   * Constructs a {@link MethodCallHandlerImpl} instance, and sets the {@link Context}. This should
   * be used as a singleton. Use {@link #getPreferences} to get an instance of {@link
   * SharedPreferences} associated to a specific file.
   */
  MethodCallHandlerImpl(Context context) {
    this.context = context;
    this.instances = new HashMap<>();
  }

  /**
   * @param filename The file to store the preferences.
   * @return An instance of {@link SharedPreferences}.
   */
  private SharedPreferences getPreferences(String filename) {
    SharedPreferences instance = instances.get(filename);
    if (instance == null) {
      instance =
          context.getSharedPreferences(
              Optional.ofNullable(filename).orElse(SHARED_PREFERENCES_DEFAULT_NAME),
              Context.MODE_PRIVATE);
      instances.put(filename, instance);
    }
    return instance;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    final String key = call.argument("key");
    final String filename = call.argument("filename");
    final SharedPreferences preferences = getPreferences(filename);
    try {
      switch (call.method) {
        case "setBool":
          commitAsync(preferences.edit().putBoolean(key, (boolean) call.argument("value")), result);
          break;
        case "setDouble":
          final double doubleValue = ((Number) call.argument("value")).doubleValue();
          final String doubleValueStr = Double.toString(doubleValue);
          commitAsync(preferences.edit().putString(key, DOUBLE_PREFIX + doubleValueStr), result);
          break;
        case "setInt":
          final Number number = call.argument("value");
          if (number instanceof BigInteger) {
            final BigInteger integerValue = (BigInteger) number;
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
          final String value = (String) call.argument("value");
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
          final List<String> list = call.argument("value");
          commitAsync(
              preferences.edit().putString(key, LIST_IDENTIFIER + encodeList(list)), result);
          break;
        case "commit":
          // We've been committing the whole time.
          result.success(true);
          break;
        case "getAll":
          result.success(getAllPrefs(filename));
          return;
        case "remove":
          commitAsync(preferences.edit().remove(key), result);
          break;
        case "clear":
          final Set<String> keySet = getAllPrefs(filename).keySet();
          final SharedPreferences.Editor clearEditor = preferences.edit();
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
    new AsyncTask<Void, Void, Boolean>() {
      @Override
      protected Boolean doInBackground(Void... voids) {
        return editor.commit();
      }

      @Override
      protected void onPostExecute(Boolean value) {
        result.success(value);
      }
    }.execute();
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
  private Map<String, Object> getAllPrefs(String filename) throws IOException {
    final SharedPreferences preferences = getPreferences(filename);
    final Map<String, ?> allPrefs = preferences.getAll();
    final Map<String, Object> filteredPrefs = new HashMap<>();
    for (String key : allPrefs.keySet()) {
      if (key.startsWith(PREFIX)) {
        Object value = allPrefs.get(key);
        if (value instanceof String) {
          final String stringValue = (String) value;
          if (stringValue.startsWith(LIST_IDENTIFIER)) {
            value = decodeList(stringValue.substring(LIST_IDENTIFIER.length()));
          } else if (stringValue.startsWith(BIG_INTEGER_PREFIX)) {
            final String encoded = stringValue.substring(BIG_INTEGER_PREFIX.length());
            value = new BigInteger(encoded, Character.MAX_RADIX);
          } else if (stringValue.startsWith(DOUBLE_PREFIX)) {
            final String doubleStr = stringValue.substring(DOUBLE_PREFIX.length());
            value = Double.valueOf(doubleStr);
          }
        } else if (value instanceof Set) {
          // This only happens for previous usage of setStringSet. The app expects a list.
          final List<String> listValue = new ArrayList<>((Set) value);
          // Let's migrate the value too while we are at it.
          final boolean success =
              preferences
                  .edit()
                  .remove(key)
                  .putString(key, LIST_IDENTIFIER + encodeList(listValue))
                  .commit();
          if (!success) {
            // If we are unable to migrate the existing preferences, it means we potentially
            // lost them.
            // In this case, an error from getAllPrefs() is appropriate since it will alert
            // the app during plugin initialization.
            throw new IOException("Could not migrate set to list");
          }
          value = listValue;
        }
        filteredPrefs.put(key, value);
      }
    }
    return filteredPrefs;
  }
}
