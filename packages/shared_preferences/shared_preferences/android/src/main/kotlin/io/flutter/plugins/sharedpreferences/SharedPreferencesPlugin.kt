// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.sharedpreferences
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
/** SharedPreferencesPlugin */
class SharedPreferencesPlugin:FlutterPlugin {
  private var channel:MethodChannel? = null
  private val CHANNEL_NAME = "plugins.flutter.io/shared_preferences"
  fun registerWith(registrar:io.flutter.plugin.common.PluginRegistry.Registrar) {
    setupChannel(registrar.messenger(), registrar.context())
  }
  override fun onAttachedToEngine(binding:FlutterPlugin.FlutterPluginBinding) {
    setupChannel(binding.binaryMessenger, binding.applicationContext)
  }
  override fun onDetachedFromEngine(binding:FlutterPlugin.FlutterPluginBinding) {
    teardownChannel()
  }
  private fun setupChannel(messenger:BinaryMessenger, context:Context) {
    channel = MethodChannel(messenger, CHANNEL_NAME)
    channel?.setMethodCallHandler(MethodCallHandlerImpl(context))
  }
  private fun teardownChannel() {
    channel?.let{
      it.setMethodCallHandler(null)
      channel = null
    }
  }
}