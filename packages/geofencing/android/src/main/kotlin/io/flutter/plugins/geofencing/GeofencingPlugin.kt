// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.geofencing

import android.Manifest
import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar

class GeofencingPlugin(context: Context, activity: Activity?) : MethodCallHandler {
    private val mContext = context
    private val mActivity = activity
    private val mGeofencingClient = LocationServices.getGeofencingClient(mContext)

    companion object {
        @JvmStatic
        private val TAG = "GeofencingPlugin"
        @JvmStatic
        val SHARED_PREFERENCES_KEY = "geofencing_plugin_cache"
        @JvmStatic
        val CALLBACK_HANDLE_KEY = "callback_handle"
        @JvmStatic
        val CALLBACK_DISPATCHER_HANDLE_KEY = "callback_dispatch_handler"
        @JvmStatic
        private val REQUIRED_PERMISSIONS = arrayOf(Manifest.permission.ACCESS_FINE_LOCATION)


        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = GeofencingPlugin(registrar.context(), registrar.activity())
            val channel = MethodChannel(registrar.messenger(), "plugins.flutter.io/geofencing_plugin")
            channel.setMethodCallHandler(plugin)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val args = call.arguments() as? ArrayList<*>
        when(call.method) {
            "GeofencingPlugin.initializeService" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    mActivity?.requestPermissions(REQUIRED_PERMISSIONS, 12312)
                }
                initializeService(args)
                result.success(true)
            }
            "GeofencingPlugin.registerGeofence" -> registerGeofence(args, result)
            "GeofencingPlugin.removeGeofence" -> removeGeofence(args, result)
            else -> result.notImplemented()
        }
    }

    private fun initializeService(args: ArrayList<*>?) {
        Log.d(TAG, "Initializing GeofencingService")
        val callbackHandle = args!![0] as Long
        mContext.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
                .edit()
                .putLong(CALLBACK_DISPATCHER_HANDLE_KEY, callbackHandle)
                .apply()
    }

    private fun getGeofencingRequest(geofence: Geofence, initialTrigger: Int): GeofencingRequest {
        return GeofencingRequest.Builder().apply {
            setInitialTrigger(initialTrigger)
            addGeofence(geofence)
        }.build()
    }

    private fun getGeofencePendingIndent(callbackHandle: Long): PendingIntent {
        val intent = Intent(mContext, GeofencingBroadcastReceiver::class.java)
                .putExtra(CALLBACK_HANDLE_KEY, callbackHandle)
        return PendingIntent.getBroadcast(mContext, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
    }

    private fun registerGeofence(args: ArrayList<*>?, result: Result) {
        val callbackHandle = args!![0] as Long
        val id = args[1] as String
        val lat = args[2] as Double
        val long = args[3] as Double
        val radius = (args[4] as Double).toFloat()
        val fenceTriggers = args[5] as Int
        val initialTriggers = args[6] as Int
        val expirationDuration = (args[7] as Int).toLong()
        val loiteringDelay = args[8] as Int
        val notificationResponsiveness = args[9] as Int
        val geofence = Geofence.Builder()
                .setRequestId(id)
                .setCircularRegion(lat, long, radius)
                .setTransitionTypes(initialTriggers)
                .setLoiteringDelay(loiteringDelay)
                .setNotificationResponsiveness(notificationResponsiveness)
                .setExpirationDuration(expirationDuration)
                .build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                (mContext.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
                        == PackageManager.PERMISSION_DENIED)) {
            val msg = "'registerGeofence' requires the ACCESS_FINE_LOCATION permission."
            Log.w(TAG, msg)
            result.error(msg, null, null)
        }
        mGeofencingClient.addGeofences(getGeofencingRequest(geofence, fenceTriggers),
                getGeofencePendingIndent(callbackHandle))?.run {
            addOnSuccessListener {
                Log.i(TAG, "Successfully added geofence")
                result.success(true)
            }
            addOnFailureListener {
                Log.e(TAG, "Failed to add geofence: $it")
                result.error(it.toString(), null, null)
            }
        }
    }

    private fun removeGeofence(args: ArrayList<*>?, result: Result) {
        val ids = listOf(args!![0] as String)
        mGeofencingClient.removeGeofences(ids).run {
            addOnSuccessListener {
                result.success(true)
            }
            addOnFailureListener {
                result.error(it.toString(), null, null)
            }
        }
    }
}
