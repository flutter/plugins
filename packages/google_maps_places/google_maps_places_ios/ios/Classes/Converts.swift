// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit
import GooglePlaces


/// Converters from and to Pigeon generated values.
class Converts: NSObject {
    
    /// Converts [LatLngIOS] to [CLLocation].
    class func convertLatLng(_ latLng:LatLngIOS?) -> CLLocation? {
        guard latLng != nil && latLng?.latitude != nil && latLng?.longitude != nil else {
            return nil
        }
        return CLLocation(latitude: latLng!.latitude!, longitude:  latLng!.longitude!)
    }
    
    /// Converts [LatLngBoundsIOS] to [GMSPlaceLocationBias].
    class func convertLocationBias(_ bounds:LatLngBoundsIOS?) -> GMSPlaceLocationBias? {
        guard bounds != nil && bounds?.northeast != nil && bounds?.southwest != nil &&
                bounds?.northeast?.latitude != nil && bounds?.northeast?.longitude != nil && bounds?.southwest?.latitude != nil && bounds?.southwest?.longitude != nil else {
            return nil
        }
        let northEastBounds = CLLocationCoordinate2D(latitude: bounds!.northeast!.longitude!, longitude: bounds!.northeast!.longitude!)
        let southWestBounds = CLLocationCoordinate2D(latitude: bounds!.southwest!.longitude!, longitude: bounds!.southwest!.longitude!)
        return GMSPlaceRectangularLocationOption( northEastBounds,
                                           southWestBounds);
    }
    
    /// Converts [LatLngBoundsIOS] to [GMSPlaceLocationRestriction].
    class func convertLocationRestrction(_ bounds:LatLngBoundsIOS?) -> GMSPlaceLocationRestriction? {
        guard bounds != nil && bounds?.northeast != nil && bounds?.southwest != nil && bounds?.northeast?.latitude != nil && bounds?.northeast?.longitude != nil && bounds?.southwest?.latitude != nil && bounds?.southwest?.longitude != nil else {
            return nil
        }
        let northEastBounds = CLLocationCoordinate2D(latitude: bounds!.northeast!.longitude!, longitude: bounds!.northeast!.longitude!)
        let southWestBounds = CLLocationCoordinate2D(latitude: bounds!.southwest!.longitude!, longitude: bounds!.southwest!.longitude!)
        return GMSPlaceRectangularLocationOption( northEastBounds,
                                           southWestBounds);
    }
    
    /// Converts array of [TypeFilterIOS] raw value to array of [GMSPlacesAutocompleteTypeFilter].
    class func convertTypeFilters(_ filters:[Int32?]?) -> [GMSPlacesAutocompleteTypeFilter]? {
        guard filters != nil else {
            return nil
        }
        return filters!.map { (filter: Int32?) in
            return convertTypeFilter(filter) }
    }
    
    /// Converts array of [TypeFilterIOS] to single [GMSPlacesAutocompleteTypeFilter].
    class func convertTypeFiltersToSingle(_ filters:[Int32?]?) -> GMSPlacesAutocompleteTypeFilter {
        guard filters != nil && !filters!.isEmpty else {
            return .noFilter
        }
        let filter = filters!.first
        return convertTypeFilter(filter!!)
    }
    
    /// Converts [TypeFilterIOS] raw value to [GMSPlacesAutocompleteTypeFilter].
    class func convertTypeFilter(_ filter:Int32?) -> GMSPlacesAutocompleteTypeFilter {
        guard filter != nil else {
            return GMSPlacesAutocompleteTypeFilter.noFilter
        }
        
        switch (TypeFilterIOS(rawValue: Int(filter!))) {
        case .address:
            return GMSPlacesAutocompleteTypeFilter.address
        case .cities:
            return GMSPlacesAutocompleteTypeFilter.city
        case .establishment:
            return GMSPlacesAutocompleteTypeFilter.establishment
        case .geocode:
            return GMSPlacesAutocompleteTypeFilter.geocode
        case .regions:
            return GMSPlacesAutocompleteTypeFilter.region
        default:
            return GMSPlacesAutocompleteTypeFilter.noFilter
        }
    }
    
    /// Converts array of [GMSAutocompletePrediction] to array  of [AutocompletePredictionIOS].
    class func convertResults(_ results: [GMSAutocompletePrediction]?) -> [AutocompletePredictionIOS?] {
        guard let results = results else {
            return []
        }
        return results.map { (prediction: GMSAutocompletePrediction) in
            return convertPrediction(prediction) }
    }
    
    /// Converts [GMSAutocompletePrediction] to [AutocompletePredictionIOS].
    class func convertPrediction(_ prediction: GMSAutocompletePrediction) -> AutocompletePredictionIOS? {
        return AutocompletePredictionIOS(distanceMeters: prediction.distanceMeters as? Int32, fullText: prediction.attributedFullText.string, placeId: prediction.placeID, placeTypes: convertPlaceTypes(prediction.types), primaryText: prediction.attributedPrimaryText.string, secondaryText: prediction.attributedSecondaryText?.string ?? "")
    }
    
    /// Converts array of [GMSPlaceType] to array  of [PlaceTypeIOS] as raw value.
    class func convertPlaceTypes(_ placeTypes: [String]) -> [Int32?] {
        return placeTypes.map { (placeType: String) in
            return Int32(convertPlaceType(placeType)?.rawValue ?? -1) }
    }
    
    /// Converts [GMSPlaceType] to [PlaceTypeIOS].
    class func convertPlaceType(_ placeType: String) -> PlaceTypeIOS? {
        switch (placeType) {
        case kGMSPlaceTypeAccounting:
            return .accounting
        case kGMSPlaceTypeAdministrativeAreaLevel1:
            return .administrativeAreaLevel1
        case kGMSPlaceTypeAdministrativeAreaLevel2:
            return .administrativeAreaLevel2
        case kGMSPlaceTypeAdministrativeAreaLevel3:
            return .administrativeAreaLevel3
        case kGMSPlaceTypeAdministrativeAreaLevel4:
            return .administrativeAreaLevel4
        case kGMSPlaceTypeAdministrativeAreaLevel5:
            return .administrativeAreaLevel5
        case kGMSPlaceTypeAirport:
            return .airport
        case kGMSPlaceTypeAmusementPark:
            return .amusementPark
        case kGMSPlaceTypeAquarium:
            return .aquarium
        // No const value available for this.
        case "archipelago":
            return .archipelago
        case kGMSPlaceTypeArtGallery:
            return .artGallery
        case kGMSPlaceTypeAtm:
            return .atm
        case kGMSPlaceTypeBakery:
            return .bakery
        case kGMSPlaceTypeBank:
            return .bank
        case kGMSPlaceTypeBar:
            return .bar
        case kGMSPlaceTypeBeautySalon:
            return .beautySalon
        case kGMSPlaceTypeBicycleStore:
            return .bicycleStore
        case kGMSPlaceTypeBookStore:
            return .bookStore
        case kGMSPlaceTypeBowlingAlley:
            return .bowlingAlley
        case kGMSPlaceTypeBusStation:
            return .busStation
        case kGMSPlaceTypeCafe:
            return .cafe
        case kGMSPlaceTypeCampground:
            return .campground
        case kGMSPlaceTypeCarDealer:
            return .carDealer
        case kGMSPlaceTypeCarRental:
            return .carRental
        case kGMSPlaceTypeCarRepair:
            return .carRepair
        case kGMSPlaceTypeCarWash:
            return .carWash
        case kGMSPlaceTypeCasino:
            return .casino
        case kGMSPlaceTypeCemetery:
            return .cemetery
        case kGMSPlaceTypeChurch:
            return .church
        case kGMSPlaceTypeCityHall:
            return .cityHall
        case kGMSPlaceTypeClothingStore:
            return .clothingStore
        case kGMSPlaceTypeColloquialArea:
            return .colloquialArea
        // No const value available for this.
        case "continent":
            return .continent
        case kGMSPlaceTypeConvenienceStore:
            return .convenienceStore
        case kGMSPlaceTypeCountry:
            return .country
        case kGMSPlaceTypeCourthouse:
            return .courthouse
        case kGMSPlaceTypeDentist:
            return .dentist
        case kGMSPlaceTypeDepartmentStore:
            return .departmentStore
        case kGMSPlaceTypeDoctor:
            return .doctor
        case kGMSPlaceTypeDrugstore:
            return .drugstore
        case kGMSPlaceTypeElectrician:
            return .electrician
        case kGMSPlaceTypeElectronicsStore:
            return .electronicsStore
        case kGMSPlaceTypeEmbassy:
            return .embassy
        case kGMSPlaceTypeEstablishment:
            return .establishment
        case kGMSPlaceTypeFinance:
            return .finance
        case kGMSPlaceTypeFireStation:
            return .fireStation
        case kGMSPlaceTypeFloor:
            return .floor
        case kGMSPlaceTypeFlorist:
            return .florist
        case kGMSPlaceTypeFood:
            return .food
        case kGMSPlaceTypeFuneralHome:
            return .funeralHome
        case kGMSPlaceTypeFurnitureStore:
            return .furnitureStore
        case kGMSPlaceTypeGasStation:
            return .gasStation
        case kGMSPlaceTypeGeneralContractor:
            return .generalContractor
        case kGMSPlaceTypeGeocode:
            return .geocode
        case kGMSPlaceTypeGroceryOrSupermarket:
            return .groceryOrSupermarket
        case kGMSPlaceTypeGym:
            return .gym
        case kGMSPlaceTypeHairCare:
            return .hairCare
        case kGMSPlaceTypeHardwareStore:
            return .hardwareStore
        case kGMSPlaceTypeHealth:
            return .health
        case kGMSPlaceTypeHinduTemple:
            return .hinduTemple
        case kGMSPlaceTypeHomeGoodsStore:
            return .homeGoodsStore
        case kGMSPlaceTypeHospital:
            return .hospital
        case kGMSPlaceTypeInsuranceAgency:
            return .insuranceAgency
        case kGMSPlaceTypeIntersection:
            return .intersection
        case kGMSPlaceTypeJewelryStore:
            return .jewelryStore
        case kGMSPlaceTypeLaundry:
            return .laundry
        case kGMSPlaceTypeLawyer:
            return .lawyer
        case kGMSPlaceTypeLibrary:
            return .library
        case kGMSPlaceTypeLightRailStation:
            return .lightRailStation
        case kGMSPlaceTypeLiquorStore:
            return .liquorStore
        case kGMSPlaceTypeLocality:
            return .locality
        case kGMSPlaceTypeLocalGovernmentOffice:
            return .localGovernmentOffice
        case kGMSPlaceTypeLocksmith:
            return .locksmith
        case kGMSPlaceTypeLodging:
            return .lodging
        case kGMSPlaceTypeMealDelivery:
            return .mealDelivery
        case kGMSPlaceTypeMealTakeaway:
            return .mealTakeaway
        case kGMSPlaceTypeMosque:
            return .mosque
        case kGMSPlaceTypeMovieRental:
            return .movieRental
        case kGMSPlaceTypeMovieTheater:
            return .movieTheater
        case kGMSPlaceTypeMovingCompany:
            return .movingCompany
        case kGMSPlaceTypeMuseum:
            return .museum
        case kGMSPlaceTypeNaturalFeature:
            return .naturalFeature
        case kGMSPlaceTypeNeighborhood:
            return .neighborhood
        case kGMSPlaceTypeNightClub:
            return .nightClub
        // No const value available for this.
        case "other":
            return .other
        case kGMSPlaceTypePainter:
            return .painter
        case kGMSPlaceTypePark:
            return .park
        case kGMSPlaceTypeParking:
            return .parking
        case kGMSPlaceTypePetStore:
            return .petStore
        case kGMSPlaceTypePharmacy:
            return .pharmacy
        case kGMSPlaceTypePhysiotherapist:
            return .physiotherapist
        case kGMSPlaceTypePlaceOfWorship:
            return .placeOfWorship
        case kGMSPlaceTypePlumber:
            return .plumber
        // No const value available for this.
        case "plus_code":
            return .plusCode
        case kGMSPlaceTypePointOfInterest:
            return .pointOfInterest
        case kGMSPlaceTypePolice:
            return .police
        case kGMSPlaceTypePolitical:
            return .political
        case kGMSPlaceTypePostalCode:
            return .postalCode
        case kGMSPlaceTypePostalCodePrefix:
            return .postalCodePrefix
        case kGMSPlaceTypePostalCodeSuffix:
            return .postalCodePrefix
        case kGMSPlaceTypePostalTown:
            return .postalTown
        case kGMSPlaceTypePostBox:
            return .postBox
        case kGMSPlaceTypePostOffice:
            return .postOffice
        case kGMSPlaceTypePremise:
            return .premise
        case kGMSPlaceTypePrimarySchool:
            return .primarySchool
        case kGMSPlaceTypeRealEstateAgency:
            return .realEstateAgency
        case kGMSPlaceTypeRestaurant:
            return .restaurant
        case kGMSPlaceTypeRoofingContractor:
            return .roofingContractor
        case kGMSPlaceTypeRoom:
            return .room
        case kGMSPlaceTypeRoute:
            return .route
        case kGMSPlaceTypeRvPark:
            return .rvPark
        case kGMSPlaceTypeSchool:
            return .school
        case kGMSPlaceTypeSecondarySchool:
            return .secondarySchool
        case kGMSPlaceTypeShoeStore:
            return .shoeStore
        case kGMSPlaceTypeShoppingMall:
            return .shoppingMall
        case kGMSPlaceTypeSpa:
            return .spa
        case kGMSPlaceTypeStadium:
            return .stadium
        case kGMSPlaceTypeStorage:
            return .storage
        case kGMSPlaceTypeStore:
            return .store
        case kGMSPlaceTypeStreetAddress:
            return .streetAddress
        case kGMSPlaceTypeStreetNumber:
            return .streetNumber
        case kGMSPlaceTypeSublocality:
            return .sublocality
        case kGMSPlaceTypeSublocalityLevel1:
            return .sublocalityLevel1
        case kGMSPlaceTypeSublocalityLevel2:
            return .sublocalityLevel2
        case kGMSPlaceTypeSublocalityLevel3:
            return .sublocalityLevel3
        case kGMSPlaceTypeSublocalityLevel4:
            return .sublocalityLevel4
        case kGMSPlaceTypeSublocalityLevel5:
            return .sublocalityLevel5
        case kGMSPlaceTypeSubpremise:
            return .subpremise
        case kGMSPlaceTypeSubwayStation:
            return .subwayStation
        case kGMSPlaceTypeSupermarket:
            return .supermarket
        case kGMSPlaceTypeSynagogue:
            return .synagogue
        case kGMSPlaceTypeTaxiStand:
            return .taxiStand
        case kGMSPlaceTypeTouristAttraction:
            return .touristAttraction
        case kGMSPlaceTypeTownSquare:
            return .townSquare
        case kGMSPlaceTypeTrainStation:
            return .trainStation
        case kGMSPlaceTypeTransitStation:
            return .transitStation
        case kGMSPlaceTypeTravelAgency:
            return .travelAgency
        case kGMSPlaceTypeUniversity:
            return .university
        case kGMSPlaceTypeVeterinaryCare:
            return .veterinaryCare
        case kGMSPlaceTypeZoo:
            return .zoo
        default:
            return nil
        }
    }
}
