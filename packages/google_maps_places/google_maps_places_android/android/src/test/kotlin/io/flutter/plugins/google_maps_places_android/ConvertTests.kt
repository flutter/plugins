// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.google_maps_places_android

import com.google.android.libraries.places.api.model.Place
import com.google.android.libraries.places.api.model.TypeFilter
import junit.framework.TestCase.*

import org.junit.Test

class ConvertTests {

    @Test
    fun testConvertsLatLng() {
        val data = LatLngAndroid(65.0121, 25.4651)
        val converted = Convert.convertLatLng(data)
        assertNotNull(converted)
        assertEquals(converted?.latitude, data.latitude)
        assertEquals(converted?.longitude, data.longitude)
        assertNull(Convert.convertLatLng(null))
        assertNull(Convert.convertLatLng(LatLngAndroid(65.0121, null)))
        assertNull(Convert.convertLatLng(LatLngAndroid(null, 25.4651)))
        assertNull(Convert.convertLatLng(LatLngAndroid(null, null)))
    }

    @Test
    fun testConvertsLatLngBounds() {
        assertNotNull(Convert.convertLatLngBounds(LatLngBoundsAndroid(
            LatLngAndroid(60.4518, 22.2666),
            LatLngAndroid(70.0821, 27.8718)
        )))
        assertNull(Convert.convertLatLngBounds(null))
        assertNull(Convert.convertLatLngBounds(LatLngBoundsAndroid(
            null,
            LatLngAndroid(70.0821, 27.8718)
        )))
        assertNull(Convert.convertLatLngBounds(LatLngBoundsAndroid(
            LatLngAndroid(60.4518, 22.2666),
            null
        )))
        assertNull(Convert.convertLatLngBounds(LatLngBoundsAndroid(
            LatLngAndroid(null, 22.2666),
            LatLngAndroid(70.0821, 27.8718)
        )))
        assertNull(Convert.convertLatLngBounds(LatLngBoundsAndroid(
            null,
            null
        )))
    }

    @Test
    fun testConvertsCountries() {
        val countries = mutableListOf<String?>()
        assertNull(Convert.convertCountries(null))
        assertNotNull(Convert.convertCountries(countries))
        countries.add(0, null)
        assertNotNull(Convert.convertCountries(countries))
        countries.removeAt(0)
        countries.addAll(listOf("fi", "us"))
        val converted = Convert.convertCountries(countries)
        assertNotNull(converted)
        assertEquals(converted?.size, countries.size)
    }

    @Test
    fun testConvertsTypeFilters() {
        val typeFilters = mutableListOf<Long?>()
        assertNull(Convert.convertTypeFilters(null))
        assertNotNull(Convert.convertTypeFilters(typeFilters))
        typeFilters.add(0, null)
        assertNotNull(Convert.convertTypeFilters(typeFilters))
        typeFilters.removeAt(0)
        typeFilters.addAll(listOf(1, 2))
        val converted = Convert.convertTypeFilters(typeFilters)
        assertNotNull(converted)
        assertEquals(converted?.size, typeFilters.size)
    }

    @Test
    fun testConvertsTypeFiltersToSingle() {
        val typeFilters = mutableListOf<Long?>()
        assertNull(Convert.convertTypeFiltersToSingle(null))
        assertNull(Convert.convertTypeFiltersToSingle(typeFilters))
        typeFilters.add(0, null)
        assertNull(Convert.convertTypeFiltersToSingle(typeFilters))
        typeFilters.removeAt(0)
        typeFilters.addAll(listOf(1, 2))
        val converted = Convert.convertTypeFiltersToSingle(typeFilters)
        assertNotNull(converted)
        assertEquals(converted.toString(), TypeFilterAndroid.ofRaw(1).toString())
    }

    @Test
    fun testConvertsTypeFilter() {
        assertEquals(Convert.convertTypeFilter(TypeFilterAndroid.ADDRESS.raw).toString(),
            TypeFilter.ADDRESS.toString())
        assertEquals(Convert.convertTypeFilter(TypeFilterAndroid.CITIES.raw).toString(),
            TypeFilter.CITIES.toString())
        assertEquals(Convert.convertTypeFilter(TypeFilterAndroid.ESTABLISHMENT.raw).toString(),
            TypeFilter.ESTABLISHMENT.toString())
        assertEquals(Convert.convertTypeFilter(TypeFilterAndroid.GEOCODE.raw).toString(),
            TypeFilter.GEOCODE.toString())
        assertEquals(Convert.convertTypeFilter(TypeFilterAndroid.REGIONS.raw).toString(),
            TypeFilter.REGIONS.toString())
    }

    @Test
    fun testConvertsPlaceTypes() {
        val types = listOf(Place.Type.ACCOUNTING, Place.Type.GEOCODE)
        val converted = Convert.convertPlaceTypes(types)
        assertNotNull(converted)
        assertEquals(types.size, converted.size)
        assertEquals(types[0].toString(), PlaceTypeAndroid.ofRaw(converted[0].toInt()).toString())
    }

    @Test
    fun testConvertsPlaceType() {
        assertEquals(Convert.convertPlaceType(Place.Type.GEOCODE).toString(),
            Place.Type.GEOCODE.toString())
    }
}