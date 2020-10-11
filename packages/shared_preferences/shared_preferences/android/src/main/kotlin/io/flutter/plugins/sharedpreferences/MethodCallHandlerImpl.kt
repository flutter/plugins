// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.sharedpreferences
import android.content.Context
import android.content.SharedPreferences
import android.os.AsyncTask
import android.util.Base64
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.ObjectInputStream
import java.io.ObjectOutputStream
import java.math.BigInteger
import java.util.ArrayList
import java.util.HashMap
/**
* Implementation of the {@link MethodChannel.MethodCallHandler} for the plugin. It is also
* responsible of managing the {@link android.content.SharedPreferences}.
*/
class MethodCallHandlerImpl/**
 * Constructs a {@link MethodCallHandlerImpl} instance. Creates a {@link
 * android.content.SharedPreferences} based on the {@code context}.
 */
(context:Context):MethodChannel.MethodCallHandler {
  private val preferences:android.content.SharedPreferences
  private var editor: SharedPreferences.Editor? = null
  // Filter preferences to only those set by the flutter app.
  private// This only happens for previous usage of setStringSet. The app expects a list.
  // Let's migrate the value too while we are at it.
  // If we are unable to migrate the existing preferences, it means we potentially lost them.
  // In this case, an error from getAllPrefs() is appropriate since it will alert the app during plugin initialization.
  val allPrefs:Map<String, Any>

  @Throws(IOException::class)
  get() {
    val allPrefs = preferences.all
    val filteredPrefs = HashMap<String, Any>()
    for (key in allPrefs.keys) {
      if (key.startsWith("flutter.")) {
        var value = allPrefs[key]
        if (value is String) {
          val stringValue = value
          when {
              stringValue.startsWith(LIST_IDENTIFIER) -> {
                value = decodeList(stringValue.substring(LIST_IDENTIFIER.length))
              }
              stringValue.startsWith(BIG_INTEGER_PREFIX) -> {
                val encoded = stringValue.substring(BIG_INTEGER_PREFIX.length)
                value = BigInteger(encoded, Character.MAX_RADIX)
              }
              stringValue.startsWith(DOUBLE_PREFIX) -> {
                val doubleStr = stringValue.substring(DOUBLE_PREFIX.length)
                value = java.lang.Double.valueOf(doubleStr)
              }
          }
        }
        else if (value is Set<*>) {
          val listValue = value.map { it.toString() }.toMutableList()
          val success = preferences
          .edit()
          .remove(key)
          .putString(key, LIST_IDENTIFIER + encodeList(listValue))
          .commit()
          if (!success) {
            throw IOException("Could not migrate set to list")
          }
          value = listValue
        }
        value?.let { filteredPrefs.put(key, it) }
      }
    }
    return filteredPrefs
  }

  init {
    preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
  }

  override fun onMethodCall(call:MethodCall, result:MethodChannel.Result) {
    val key = call.argument("key") as String?
    try
    {
      when (call.method) {
        "setBool" -> commitAsync(preferences.edit().putBoolean(key, call.argument<Boolean>("value") as Boolean), result)
        "setDouble" -> {
          val doubleValue = (call.argument<Number>("value") as Number).toDouble()
          val doubleValueStr = doubleValue.toString()
          commitAsync(preferences.edit().putString(key, DOUBLE_PREFIX + doubleValueStr), result)
        }
        "setInt" -> {
          val number = call.argument<Number>("value")
          if (number is BigInteger)
          {
            val integerValue = number as BigInteger
            commitAsync(
              preferences
              .edit()
              .putString(
                key, BIG_INTEGER_PREFIX + integerValue.toString(Character.MAX_RADIX)),
              result)
          }
          else
          {
            commitAsync(preferences.edit().putLong(key, number!!.toLong()), result)
          }
        }
        "setString" -> {
          val value = call.argument<String>("value") as String
          if (value.startsWith(LIST_IDENTIFIER) || value.startsWith(BIG_INTEGER_PREFIX))
          {
            result.error(
              "StorageError",
              "This string cannot be stored as it clashes with special identifier prefixes.", null)
            return
          }
          commitAsync(preferences.edit().putString(key, value), result)
        }
        "setStringList" -> {
          val list = call.argument<List<String>>("value") as List<String>
          commitAsync(
            preferences.edit().putString(key, LIST_IDENTIFIER + encodeList(list)), result)
        }
        "commit" ->
        // We've been committing the whole time.
        result.success(true)
        "getAll" -> {
          result.success(allPrefs)
          return
        }
        "remove" -> commitAsync(preferences.edit().remove(key), result)
        "clear" -> {
          val keySet = allPrefs.keys
          val clearEditor = preferences.edit()
          for (keyToDelete in keySet)
          {
            clearEditor.remove(keyToDelete)
          }
          commitAsync(clearEditor, result)
        }
        else -> result.notImplemented()
      }
    }
    catch (e:IOException) {
      result.error("IOException encountered", call.method, e)
    }
  }

  private fun commitAsync(
    editor:SharedPreferences.Editor, result:MethodChannel.Result) {
    object:AsyncTask<Void, Void, Boolean>() {
      override protected fun doInBackground(vararg voids:Void):Boolean {
        return editor.commit()
      }
      override protected fun onPostExecute(value:Boolean) {
        result.success(value)
      }
    }.execute()
  }

  @Throws(IOException::class)
  private fun decodeList(encodedList:String):List<String> {
    var stream:ObjectInputStream? = null
    try {
      stream = ObjectInputStream(ByteArrayInputStream(Base64.decode(encodedList, 0)))
      return stream.readObject() as List<String>
    }
    catch (e:ClassNotFoundException) {
      throw IOException(e)
    }
    finally {
      stream?.let { it.close() }
    }
  }

  @Throws(IOException::class)
  private fun encodeList(list:List<String>):String {
    var stream:ObjectOutputStream? = null
    try {
      val byteStream = ByteArrayOutputStream()
      stream = ObjectOutputStream(byteStream)
      stream.writeObject(list)
      stream.flush()
      return Base64.encodeToString(byteStream.toByteArray(), 0)
    }
    finally {
      stream?.let { it.close() }
    }
  }

  companion object {
    private val SHARED_PREFERENCES_NAME = "FlutterSharedPreferences"
    // Fun fact: The following is a base64 encoding of the string "This is the prefix for a list."
    private val LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu"
    private val BIG_INTEGER_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy"
    private val DOUBLE_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu"
  }
}