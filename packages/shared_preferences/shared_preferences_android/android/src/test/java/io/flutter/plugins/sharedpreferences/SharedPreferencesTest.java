// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import androidx.annotation.NonNull;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.Test;

// Class Mocking SharedPreferencesAPI
class MockAPI implements Messages.SharedPreferencesApi {

  Map<String, Object> items = new HashMap<String, Object>();

  @Override
  public Boolean remove(@NonNull String key) {
    items.remove(key);
    return true;
  }

  @Override
  public Boolean setBool(@NonNull String key, @NonNull Boolean value) {
    items.put(key, value);
    return true;
  }

  @Override
  public Boolean setString(@NonNull String key, @NonNull String value) {
    items.put(key, value);
    return true;
  }

  @Override
  public Boolean setInt(@NonNull String key, @NonNull Object value) {
    items.put(key, value);
    return true;
  }

  @Override
  public Boolean setDouble(@NonNull String key, @NonNull Double value) {
    items.put(key, value);
    return true;
  }

  @Override
  public Boolean setStringList(@NonNull String key, @NonNull List<String> value) {
    items.put(key, value);
    return true;
  }

  @Override
  public Boolean clear() {
    items.clear();
    return true;
  }

  @Override
  public Map<String, Object> getAll() {
    return items;
  }
}

public class SharedPreferencesTest {

  MockAPI api = new MockAPI();

  Map<String, Object> data =
      new HashMap<String, Object>() {
        {
          put("Language", "Java");
          put("Counter", 0);
          put("Pie", 3.14);
          put("Names", Arrays.asList("Flutter", "Dart"));
          put("NewToFlutter", false);
        }
      };

  @Test
  public void initPluginDoesNotThrow() {
    final SharedPreferencesPlugin plugin = new SharedPreferencesPlugin();
  }

  @Test
  public void testAddValues() {
    assertEquals(api.getAll().size(), 0);

    addData(api);

    assertEquals(api.getAll().size(), 5);
    assertEquals(api.getAll().get("Language"), "Java");
    assertEquals(api.getAll().get("Counter"), 0);
    assertEquals(api.getAll().get("Pie"), 3.14);
    assertEquals(api.getAll().get("Names"), Arrays.asList("Flutter", "Dart"));
    assertEquals(api.getAll().get("NewToFlutter"), false);
  }

  @Test
  public void testGetAllData() {
    assertEquals(api.getAll(), new HashMap<String, Object>());
    addData(api);

    assertEquals(api.getAll(), data);
  }

  @Test
  public void testClear() {
    addData(api);
    assertEquals(api.getAll().size(), 5);
    api.clear();
    assertEquals(api.getAll().size(), 0);
  }

  @Test
  public void testRemove() {
    api.setBool("isJava", true);
    api.remove("isJava");
    assertFalse(api.getAll().containsKey("isJava"));
  }

  public void addData(MockAPI api) {
    api.setString("Language", "Java");
    api.setInt("Counter", 0);
    api.setDouble("Pie", 3.14);
    api.setStringList("Names", Arrays.asList("Flutter", "Dart"));
    api.setBool("NewToFlutter", false);
  }
}
