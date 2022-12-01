// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.google_maps_places_android

import com.google.android.gms.maps.model.LatLng
import com.google.android.libraries.places.api.model.AutocompletePrediction
import com.google.android.libraries.places.api.model.Place
import com.google.android.libraries.places.api.model.RectangularBounds
import com.google.android.libraries.places.api.model.TypeFilter
import com.google.android.libraries.places.api.net.FindAutocompletePredictionsResponse

/// Converters from and to Pigeon generated values.
object Convert {

  /// Converts [LatLngAndroid] to [LatLng].
  ///
  /// Returns [null] if [latLng] is [null].
  fun convertLatLng(latLng: LatLngAndroid?): LatLng? {
    if (latLng?.latitude == null || latLng.longitude == null) {
      return null
    }
    return LatLng(latLng.latitude, latLng.longitude)
  }

  /// Converts [LatLngBoundsAndroid] to [RectangularBounds].
  ///
  /// Returns [null] if [latLngBounds] is [null].
  fun convertLatLngBounds(latLngBounds: LatLngBoundsAndroid?): RectangularBounds? {
    if (latLngBounds?.northeast == null || latLngBounds.southwest == null) {
      return null
    }
    val northeast = convertLatLng(latLngBounds.northeast)
    val southwest = convertLatLng(latLngBounds.southwest)
    if (northeast == null || southwest == null) {
      return null
    }
    return RectangularBounds.newInstance(southwest, northeast)
  }

  /// Converts list of [String] to list of [String].
  ///
  /// Returns [null] if [countries] is [null].
  fun convertCountries(countries: List<String?>?): List<String>? {
    if (countries == null) {
      return null
    }
    return countries.map { country ->  country.toString() }
  }

  /// Converts list of [TypeFilterAndroid] to list of [String].
  ///
  /// Returns [null] if [filters] is [null].
  internal fun convertTypeFilters(filters: List<Long?>?): List<String?>? {
    if (filters == null) {
      return null
    }
    @Suppress("UNCHECKED_CAST")
    val nonNullFilters = filters.filterNotNull() as? List<Int> ?: return null
    return nonNullFilters.map { filter ->  convertTypeFilter(filter).toString() }
  }

  /// Converts list of [TypeFilterAndroid] to [TypeFilter].
  ///
  /// Returns [null] if [filters] is [null].
  fun convertTypeFiltersToSingle(filters: List<Long?>?): TypeFilter? {
    if (filters == null || filters.isEmpty()) {
      return null
    }

    @Suppress("UNCHECKED_CAST")
    val nonNullFilters = filters.filterNotNull() as? List<Int> ?: return null
    if (nonNullFilters.isEmpty()) {
      return null
    }
    val filter = nonNullFilters.first()
    return convertTypeFilter(filter)
  }

  /// Converts [TypeFilterAndroid] to [TypeFilter].
  ///
  /// Throws [IllegalArgumentException] on invalid [filter].
  internal fun convertTypeFilter(filter: Int): TypeFilter {
    return when (TypeFilterAndroid.ofRaw(filter)) {
      TypeFilterAndroid.ADDRESS -> TypeFilter.ADDRESS
      TypeFilterAndroid.CITIES -> TypeFilter.CITIES
      TypeFilterAndroid.ESTABLISHMENT -> TypeFilter.ESTABLISHMENT
      TypeFilterAndroid.GEOCODE -> TypeFilter.GEOCODE
      TypeFilterAndroid.REGIONS -> TypeFilter.REGIONS
      else -> {throw IllegalArgumentException("Invalid TypeFilter: $filter")}
    }
  }

  /// Converts [FindAutocompletePredictionsResponse] to list of [AutocompletePredictionAndroid].
  fun convertResponse(result: FindAutocompletePredictionsResponse): List<AutocompletePredictionAndroid> {
    return result.autocompletePredictions.map { item -> convertPrediction(item) }
  }

  /// Converts [AutocompletePrediction] to of [AutocompletePredictionAndroid].
  private fun convertPrediction(prediction: AutocompletePrediction): AutocompletePredictionAndroid {
    return AutocompletePredictionAndroid(
      prediction.distanceMeters?.toLong(),
      prediction.getFullText(null).toString(),
      prediction.placeId,
      convertPlaceTypes(prediction.placeTypes),
      prediction.getPrimaryText(null).toString(),
      prediction.getSecondaryText(null).toString()
    )
  }

  /// Converts list of [Place.Type] to list of [Long].
  internal fun convertPlaceTypes(types: List<Place.Type>): List<Long> {
    return types.map { type -> convertPlaceType(type).raw.toLong() }
  }

  /// Converts [Place.Type] to [Long] value of [PlaceTypeAndroid].
  ///
  /// Throws [IllegalArgumentException] on invalid [type].
  internal fun convertPlaceType(type: Place.Type): PlaceTypeAndroid {
    return when (type) {
      Place.Type.ACCOUNTING -> PlaceTypeAndroid.ACCOUNTING
      Place.Type.ADMINISTRATIVE_AREA_LEVEL_1 -> PlaceTypeAndroid.ADMINISTRATIVEAREALEVEL1
      Place.Type.ADMINISTRATIVE_AREA_LEVEL_2 -> PlaceTypeAndroid.ADMINISTRATIVEAREALEVEL2
      Place.Type.ADMINISTRATIVE_AREA_LEVEL_3 -> PlaceTypeAndroid.ADMINISTRATIVEAREALEVEL3
      Place.Type.ADMINISTRATIVE_AREA_LEVEL_4 -> PlaceTypeAndroid.ADMINISTRATIVEAREALEVEL4
      Place.Type.ADMINISTRATIVE_AREA_LEVEL_5 -> PlaceTypeAndroid.ADMINISTRATIVEAREALEVEL5
      Place.Type.AIRPORT -> PlaceTypeAndroid.AIRPORT
      Place.Type.AMUSEMENT_PARK -> PlaceTypeAndroid.AMUSEMENTPARK
      Place.Type.AQUARIUM -> PlaceTypeAndroid.AQUARIUM
      Place.Type.ARCHIPELAGO -> PlaceTypeAndroid.ARCHIPELAGO
      Place.Type.ART_GALLERY -> PlaceTypeAndroid.ARTGALLERY
      Place.Type.ATM -> PlaceTypeAndroid.ATM
      Place.Type.BAKERY -> PlaceTypeAndroid.BAKERY
      Place.Type.BANK -> PlaceTypeAndroid.BANK
      Place.Type.BAR -> PlaceTypeAndroid.BAR
      Place.Type.BEAUTY_SALON -> PlaceTypeAndroid.BEAUTYSALON
      Place.Type.BICYCLE_STORE -> PlaceTypeAndroid.BICYCLESTORE
      Place.Type.BOOK_STORE -> PlaceTypeAndroid.BOOKSTORE
      Place.Type.BOWLING_ALLEY -> PlaceTypeAndroid.BOWLINGALLEY
      Place.Type.BUS_STATION -> PlaceTypeAndroid.BUSSTATION
      Place.Type.CAFE -> PlaceTypeAndroid.CAFE
      Place.Type.CAMPGROUND -> PlaceTypeAndroid.CAMPGROUND
      Place.Type.CAR_DEALER -> PlaceTypeAndroid.CARDEALER
      Place.Type.CAR_RENTAL -> PlaceTypeAndroid.CARRENTAL
      Place.Type.CAR_REPAIR -> PlaceTypeAndroid.CARREPAIR
      Place.Type.CAR_WASH -> PlaceTypeAndroid.CARWASH
      Place.Type.CASINO -> PlaceTypeAndroid.CASINO
      Place.Type.CEMETERY -> PlaceTypeAndroid.CEMETERY
      Place.Type.CHURCH -> PlaceTypeAndroid.CHURCH
      Place.Type.CITY_HALL -> PlaceTypeAndroid.CITYHALL
      Place.Type.CLOTHING_STORE -> PlaceTypeAndroid.CLOTHINGSTORE
      Place.Type.COLLOQUIAL_AREA -> PlaceTypeAndroid.COLLOQUIALAREA
      Place.Type.CONTINENT -> PlaceTypeAndroid.CONTINENT
      Place.Type.CONVENIENCE_STORE -> PlaceTypeAndroid.CONVENIENCESTORE
      Place.Type.COUNTRY -> PlaceTypeAndroid.COUNTRY
      Place.Type.COURTHOUSE -> PlaceTypeAndroid.COURTHOUSE
      Place.Type.DENTIST -> PlaceTypeAndroid.DENTIST
      Place.Type.DEPARTMENT_STORE -> PlaceTypeAndroid.DEPARTMENTSTORE
      Place.Type.DOCTOR -> PlaceTypeAndroid.DOCTOR
      Place.Type.DRUGSTORE -> PlaceTypeAndroid.DRUGSTORE
      Place.Type.ELECTRICIAN -> PlaceTypeAndroid.ELECTRICIAN
      Place.Type.ELECTRONICS_STORE -> PlaceTypeAndroid.ELECTRONICSSTORE
      Place.Type.EMBASSY -> PlaceTypeAndroid.EMBASSY
      Place.Type.ESTABLISHMENT -> PlaceTypeAndroid.ESTABLISHMENT
      Place.Type.FINANCE -> PlaceTypeAndroid.FINANCE
      Place.Type.FIRE_STATION -> PlaceTypeAndroid.FIRESTATION
      Place.Type.FLOOR -> PlaceTypeAndroid.FLOOR
      Place.Type.FLORIST -> PlaceTypeAndroid.FLORIST
      Place.Type.FOOD -> PlaceTypeAndroid.FOOD
      Place.Type.FUNERAL_HOME -> PlaceTypeAndroid.FUNERALHOME
      Place.Type.FURNITURE_STORE -> PlaceTypeAndroid.FURNITURESTORE
      Place.Type.GAS_STATION -> PlaceTypeAndroid.GASSTATION
      Place.Type.GENERAL_CONTRACTOR -> PlaceTypeAndroid.GENERALCONTRACTOR
      Place.Type.GEOCODE -> PlaceTypeAndroid.GEOCODE
      Place.Type.GROCERY_OR_SUPERMARKET -> PlaceTypeAndroid.GROCERYORSUPERMARKET
      Place.Type.GYM -> PlaceTypeAndroid.GYM
      Place.Type.HAIR_CARE -> PlaceTypeAndroid.HAIRCARE
      Place.Type.HARDWARE_STORE -> PlaceTypeAndroid.HARDWARESTORE
      Place.Type.HEALTH -> PlaceTypeAndroid.HEALTH
      Place.Type.HINDU_TEMPLE -> PlaceTypeAndroid.HINDUTEMPLE
      Place.Type.HOME_GOODS_STORE -> PlaceTypeAndroid.HOMEGOODSSTORE
      Place.Type.HOSPITAL -> PlaceTypeAndroid.HOSPITAL
      Place.Type.INSURANCE_AGENCY -> PlaceTypeAndroid.INSURANCEAGENCY
      Place.Type.INTERSECTION -> PlaceTypeAndroid.INTERSECTION
      Place.Type.JEWELRY_STORE -> PlaceTypeAndroid.JEWELRYSTORE
      Place.Type.LAUNDRY -> PlaceTypeAndroid.LAUNDRY
      Place.Type.LAWYER -> PlaceTypeAndroid.LAWYER
      Place.Type.LIBRARY-> PlaceTypeAndroid.LIBRARY
      Place.Type.LIGHT_RAIL_STATION -> PlaceTypeAndroid.LIGHTRAILSTATION
      Place.Type.LIQUOR_STORE -> PlaceTypeAndroid.LIQUORSTORE
      Place.Type.LOCALITY -> PlaceTypeAndroid.LOCALITY
      Place.Type.LOCAL_GOVERNMENT_OFFICE -> PlaceTypeAndroid.LOCALGOVERNMENTOFFICE
      Place.Type.LOCKSMITH -> PlaceTypeAndroid.LOCKSMITH
      Place.Type.LODGING -> PlaceTypeAndroid.LODGING
      Place.Type.MEAL_DELIVERY -> PlaceTypeAndroid.MEALDELIVERY
      Place.Type.MEAL_TAKEAWAY -> PlaceTypeAndroid.MEALTAKEAWAY
      Place.Type.MOSQUE -> PlaceTypeAndroid.MOSQUE
      Place.Type.MOVIE_RENTAL -> PlaceTypeAndroid.MOVIERENTAL
      Place.Type.MOVIE_THEATER -> PlaceTypeAndroid.MOVIETHEATER
      Place.Type.MOVING_COMPANY -> PlaceTypeAndroid.MOVINGCOMPANY
      Place.Type.MUSEUM -> PlaceTypeAndroid.MUSEUM
      Place.Type.NATURAL_FEATURE -> PlaceTypeAndroid.NATURALFEATURE
      Place.Type.NEIGHBORHOOD -> PlaceTypeAndroid.NEIGHBORHOOD
      Place.Type.NIGHT_CLUB -> PlaceTypeAndroid.NIGHTCLUB
      Place.Type.OTHER -> PlaceTypeAndroid.OTHER
      Place.Type.PAINTER -> PlaceTypeAndroid.PAINTER
      Place.Type.PARK -> PlaceTypeAndroid.PARK
      Place.Type.PARKING -> PlaceTypeAndroid.PARKING
      Place.Type.PET_STORE -> PlaceTypeAndroid.PETSTORE
      Place.Type.PHARMACY -> PlaceTypeAndroid.PHARMACY
      Place.Type.PHYSIOTHERAPIST -> PlaceTypeAndroid.PHYSIOTHERAPIST
      Place.Type.PLACE_OF_WORSHIP -> PlaceTypeAndroid.PLACEOFWORSHIP
      Place.Type.PLUMBER -> PlaceTypeAndroid.PLUMBER
      Place.Type.PLUS_CODE -> PlaceTypeAndroid.PLUSCODE
      Place.Type.POINT_OF_INTEREST -> PlaceTypeAndroid.POINTOFINTEREST
      Place.Type.POLICE -> PlaceTypeAndroid.POLICE
      Place.Type.POLITICAL -> PlaceTypeAndroid.POLITICAL
      Place.Type.POSTAL_CODE -> PlaceTypeAndroid.POSTALCODE
      Place.Type.POSTAL_CODE_PREFIX -> PlaceTypeAndroid.POSTALCODEPREFIX
      Place.Type.POSTAL_CODE_SUFFIX -> PlaceTypeAndroid.POSTALCODESUFFIX
      Place.Type.POSTAL_TOWN -> PlaceTypeAndroid.POSTALTOWN
      Place.Type.POST_BOX -> PlaceTypeAndroid.POSTBOX
      Place.Type.POST_OFFICE -> PlaceTypeAndroid.POSTOFFICE
      Place.Type.PREMISE -> PlaceTypeAndroid.PREMISE
      Place.Type.PRIMARY_SCHOOL -> PlaceTypeAndroid.PRIMARYSCHOOL
      Place.Type.REAL_ESTATE_AGENCY -> PlaceTypeAndroid.REALESTATEAGENCY
      Place.Type.RESTAURANT -> PlaceTypeAndroid.RESTAURANT
      Place.Type.ROOFING_CONTRACTOR -> PlaceTypeAndroid.ROOFINGCONTRACTOR
      Place.Type.ROOM -> PlaceTypeAndroid.ROOM
      Place.Type.ROUTE -> PlaceTypeAndroid.ROUTE
      Place.Type.RV_PARK -> PlaceTypeAndroid.RVPARK
      Place.Type.SCHOOL -> PlaceTypeAndroid.SCHOOL
      Place.Type.SECONDARY_SCHOOL -> PlaceTypeAndroid.SECONDARYSCHOOL
      Place.Type.SHOE_STORE -> PlaceTypeAndroid.SHOESTORE
      Place.Type.SHOPPING_MALL -> PlaceTypeAndroid.SHOPPINGMALL
      Place.Type.SPA -> PlaceTypeAndroid.SPA
      Place.Type.STADIUM -> PlaceTypeAndroid.STADIUM
      Place.Type.STORAGE -> PlaceTypeAndroid.STORAGE
      Place.Type.STORE -> PlaceTypeAndroid.STORE
      Place.Type.STREET_ADDRESS -> PlaceTypeAndroid.STREETADDRESS
      Place.Type.STREET_NUMBER -> PlaceTypeAndroid.STREETNUMBER
      Place.Type.SUBLOCALITY -> PlaceTypeAndroid.SUBLOCALITY
      Place.Type.SUBLOCALITY_LEVEL_1 -> PlaceTypeAndroid.SUBLOCALITYLEVEL1
      Place.Type.SUBLOCALITY_LEVEL_2 -> PlaceTypeAndroid.SUBLOCALITYLEVEL2
      Place.Type.SUBLOCALITY_LEVEL_3 -> PlaceTypeAndroid.SUBLOCALITYLEVEL3
      Place.Type.SUBLOCALITY_LEVEL_4 -> PlaceTypeAndroid.SUBLOCALITYLEVEL4
      Place.Type.SUBLOCALITY_LEVEL_5 -> PlaceTypeAndroid.SUBLOCALITYLEVEL5
      Place.Type.SUBPREMISE -> PlaceTypeAndroid.SUBPREMISE
      Place.Type.SUBWAY_STATION -> PlaceTypeAndroid.SUBWAYSTATION
      Place.Type.SUPERMARKET -> PlaceTypeAndroid.SUPERMARKET
      Place.Type.SYNAGOGUE -> PlaceTypeAndroid.SYNAGOGUE
      Place.Type.TAXI_STAND -> PlaceTypeAndroid.TAXISTAND
      Place.Type.TOURIST_ATTRACTION -> PlaceTypeAndroid.TOURISTATTRACTION
      Place.Type.TOWN_SQUARE -> PlaceTypeAndroid.TOWNSQUARE
      Place.Type.TRAIN_STATION -> PlaceTypeAndroid.TRAINSTATION
      Place.Type.TRANSIT_STATION -> PlaceTypeAndroid.TRANSITSTATION
      Place.Type.TRAVEL_AGENCY -> PlaceTypeAndroid.TRAVELAGENCY
      Place.Type.UNIVERSITY -> PlaceTypeAndroid.UNIVERSITY
      Place.Type.VETERINARY_CARE -> PlaceTypeAndroid.VETERINARYCARE
      Place.Type.ZOO -> PlaceTypeAndroid.ZOO
      else -> {throw IllegalArgumentException("Invalid PlaceType: $type")}
    }
  }
}
