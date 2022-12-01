// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.google_maps_places_android

import android.content.Context
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import com.google.android.libraries.places.api.Places
import com.google.android.libraries.places.api.model.AutocompleteSessionToken
import com.google.android.libraries.places.api.net.FindAutocompletePredictionsRequest
import com.google.android.libraries.places.api.net.PlacesClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.google_maps_places_android.Convert.convertCountries
import io.flutter.plugins.google_maps_places_android.Convert.convertLatLng
import io.flutter.plugins.google_maps_places_android.Convert.convertLatLngBounds
import io.flutter.plugins.google_maps_places_android.Convert.convertResponse
import io.flutter.plugins.google_maps_places_android.Convert.convertTypeFiltersToSingle


/// GoogleMapsPlacesAndroidPlugin
class GoogleMapsPlacesAndroidPlugin: FlutterPlugin, GoogleMapsPlacesApiAndroid {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity.
  private lateinit var client: PlacesClient
  private var previousSessionToken: AutocompleteSessionToken? = null
  private lateinit var applicationContext: Context

  private fun setup(messenger: BinaryMessenger, context: Context?) {
    try {
      GoogleMapsPlacesApiAndroid.setUp(messenger, this)
    } catch (ex: Exception) {
      print("setup Exception: $ex")
    }
    if (context != null) {
      this.applicationContext = context
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    setup(flutterPluginBinding.binaryMessenger, flutterPluginBinding.applicationContext)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    setup(binding.binaryMessenger, null);
  }

  /// Finds Autocomplete Predictions.
  ///
  /// ref: https://developers.google.com/maps/documentation/places/android-sdk/autocomplete#get_place_predictions
  override fun findAutocompletePredictionsAndroid(
    query: String,
    locationBias: LatLngBoundsAndroid?,
    locationRestriction: LatLngBoundsAndroid?,
    origin: LatLngAndroid?,
    countries: List<String?>?,
    typeFilter: List<Long?>?,
    refreshToken: Boolean?,
    callback: (List<AutocompletePredictionAndroid?>) -> Unit
  ) {
    val sessionToken = initialize(refreshToken == true)

    // LocationBias and LocationRestriction are not allowed at the same time.
    val placesRequest = if (locationRestriction != null && locationBias == null) {
      requestWithLocationRestriction(query,
        locationRestriction,
        origin,
        countries,
        typeFilter,
        sessionToken)
    } else {
      requestWithLocationBias(query,
        locationBias,
        origin,
        countries,
        typeFilter,
        sessionToken)
    }
    client.findAutocompletePredictions(placesRequest).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        previousSessionToken = placesRequest.sessionToken
        print("findAutocompletePredictionsAndroid Result: ${task.result}")
        callback(convertResponse(task.result))
      } else {
        val exception = task.exception
        print("findAutocompletePredictionsAndroid Exception: $exception")
        throw Error("API_ERROR_AUTOCOMPLETE" + (exception?.message ?: "Unknown exception"))
      }
    }
  }

  /// Requests autocomplete predictions with locationBias if given.
  private fun requestWithLocationBias(
    query: String,
    locationBias: LatLngBoundsAndroid?,
    origin: LatLngAndroid?,
    countries: List<String?>?,
    typeFilter: List<Long?>?,
    sessionToken: AutocompleteSessionToken):FindAutocompletePredictionsRequest  {
    return FindAutocompletePredictionsRequest.builder()
      .setQuery(query)
      .setLocationBias(convertLatLngBounds(locationBias))
      .setCountries(convertCountries(countries) ?: emptyList())
      .setTypeFilter(convertTypeFiltersToSingle(typeFilter))
      //Not working at the moment. API return an error when used.
      //.setTypesFilter(convertTypeFilters(typeFilter) ?: emptyList())
      .setSessionToken(sessionToken)
      .setOrigin(convertLatLng(origin))
      .build()
  }

  /// Requests autocomplete predictions with location restriction.
  private fun requestWithLocationRestriction(
    query: String,
    locationRestriction: LatLngBoundsAndroid?,
    origin: LatLngAndroid?,
    countries: List<String?>?,
    typeFilter: List<Long?>?,
    sessionToken: AutocompleteSessionToken):FindAutocompletePredictionsRequest  {
    return FindAutocompletePredictionsRequest.builder()
      .setQuery(query)
      .setLocationRestriction(convertLatLngBounds(locationRestriction))
      .setCountries(convertCountries(countries) ?: emptyList())
      .setTypeFilter(convertTypeFiltersToSingle(typeFilter))
      //Not working at the moment. API return an error when used.
      //.setTypesFilter(convertTypeFilters(typeFilter) ?: emptyList())
      .setSessionToken(sessionToken)
      .setOrigin(convertLatLng(origin))
      .build()
  }


  /// Initializes Places client.
  private fun initialize(refreshToken: Boolean): AutocompleteSessionToken  {
    val applicationInfo =
      applicationContext
        .packageManager
        .getApplicationInfo(applicationContext.packageName, PackageManager.GET_META_DATA);
    var apiKey = ""
    if (applicationInfo.metaData != null) {
      apiKey = applicationInfo.metaData.getString("com.google.android.geo.API_KEY").toString()
    }
    Places.initialize(applicationContext, apiKey)
    client = Places.createClient(applicationContext)
    return getSessionToken(refreshToken);
  }

  /// Fetches new session token if needed.
  private fun getSessionToken(refreshToken: Boolean): AutocompleteSessionToken {
    val sessionToken = previousSessionToken
    if (refreshToken || sessionToken == null) {
      return AutocompleteSessionToken.newInstance()
    }
    return sessionToken
  }
}
