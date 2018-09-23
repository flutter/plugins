// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.geofencing

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.view.FlutterMain


class GeofencingBroadcastReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "GeofencingBroadcastReceiver"
    }
    override fun onReceive(context: Context, intent: Intent) {
        FlutterMain.ensureInitializationComplete(context, null)
        GeofencingService.enqueueWork(context, intent)
    }
}