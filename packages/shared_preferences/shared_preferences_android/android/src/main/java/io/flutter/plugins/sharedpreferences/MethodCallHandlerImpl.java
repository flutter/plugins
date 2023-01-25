// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Base64;
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

/** Helper class to save data to `android.content.SharedPreferences` */

// Rename class and file to match it's purpose, preferably SharedPreferencesHelper
@SuppressWarnings("unchecked")
class MethodCallHandlerImpl {

  private static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";

  // Fun fact: The following is a base64 encoding of the string "This is the prefix for a list."
  private static final String LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu";
  private static final String BIG_INTEGER_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy";
  private static final String DOUBLE_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu";

  private final android.content.SharedPreferences preferences;

  MethodCallHandlerImpl(Context context) {
    preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
  }

  public Boolean setBool(String key, Boolean value) {
    return preferences.edit().putBoolean(key, value).commit();
  }

  public Boolean setString(String key, String value) {
    if (value.startsWith(LIST_IDENTIFIER)
        || value.startsWith(BIG_INTEGER_PREFIX)
        || value.startsWith(DOUBLE_PREFIX)) {
      throw new RuntimeException(
          "StorageError: This string cannot be stored as it clashes with special identifier prefixes");
    }
    return preferences.edit().putString(key, value).commit();
  }

  public Boolean setInt(String key, Object value) {
    Number number = (Number) value;
    if (number instanceof BigInteger) {
      BigInteger integerValue = (BigInteger) number;
      return preferences
          .edit()
          .putString(key, BIG_INTEGER_PREFIX + integerValue.toString(Character.MAX_RADIX))
          .commit();
    } else {
      return preferences.edit().putLong(key, number.longValue()).commit();
    }
  }

  public Boolean setDouble(String key, Double value) {
    String doubleValueStr = Double.toString(value);
    return preferences.edit().putString(key, DOUBLE_PREFIX + doubleValueStr).commit();
  }

  public Boolean setStringList(String key, List<String> value) throws RuntimeException {
    Boolean success =
        preferences.edit().putString(key, LIST_IDENTIFIER + encodeList(value)).commit();
    return success;
  }

  public Map<String, Object> getAll() throws RuntimeException {
    Map<String, Object> data = getAllPrefs();
    return data;
  }

  public Boolean remove(String key) {
    return preferences.edit().remove(key).commit();
  }

  public Boolean clear() throws RuntimeException {
    Set<String> keySet = getAllPrefs().keySet();
    SharedPreferences.Editor clearEditor = preferences.edit();
    for (String keyToDelete : keySet) {
      clearEditor.remove(keyToDelete);
    }
    return clearEditor.commit();
  }

  // Filter preferences to only those set by the flutter app.
  @SuppressWarnings("unchecked")
  private Map<String, Object> getAllPrefs() throws RuntimeException {
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
          List<String> listValue = new ArrayList<String>((Set<String>) value);
          // Let's migrate the value too while we are at it.
          try {
            preferences
                .edit()
                .remove(key)
                .putString(key, LIST_IDENTIFIER + encodeList(listValue))
                .commit();
          } catch (RuntimeException e) {
            // If we are unable to migrate the existing preferences, it means we potentially lost them.
            // In this case, an error from getAllPrefs() is appropriate since it will alert the app during plugin initialization.
            throw e;
          }
          value = listValue;
        }
        filteredPrefs.put(key, value);
      }
    }

    return filteredPrefs;
  }

  @SuppressWarnings("unchecked")
  private List<String> decodeList(String encodedList) throws RuntimeException {
    ObjectInputStream stream = null;
    try {
      stream = new ObjectInputStream(new ByteArrayInputStream(Base64.decode(encodedList, 0)));
      List<String> data = (List<String>) stream.readObject();
      if (stream != null) {
        stream.close();
      }

      return data;
    } catch (IOException | ClassNotFoundException e) {
      throw new RuntimeException(e);
    }
  }

  private String encodeList(List<String> list) throws RuntimeException {
    ObjectOutputStream stream = null;
    try {
      ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
      stream = new ObjectOutputStream(byteStream);
      stream.writeObject(list);
      stream.flush();
      String data = Base64.encodeToString(byteStream.toByteArray(), 0);
      if (stream != null) {
        stream.close();
      }

      return data;
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }
}
