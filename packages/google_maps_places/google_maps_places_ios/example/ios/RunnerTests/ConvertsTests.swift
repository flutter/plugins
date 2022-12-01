// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
@testable import google_maps_places_ios
@testable import GooglePlaces

final class ConvertsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    let plugin = SwiftGoogleMapsPlacesIosPlugin()
    let queryString:String = "Koulu"
    let hasApiKey:Bool = ProcessInfo.processInfo.environment["MAPS_API_KEY"] != nil
    
    func testConvertsLatLng() {
        let data:LatLngIOS = LatLngIOS(latitude: 65.0121, longitude: 25.4651)
        let converted = Converts.convertLatLng(data)
        XCTAssertNotNil(converted)
        XCTAssertNotNil(converted?.coordinate)
        XCTAssertEqual(converted?.coordinate.latitude, data.latitude)
        XCTAssertEqual(converted?.coordinate.longitude, data.longitude)
        XCTAssertNil(Converts.convertLatLng(nil))
        XCTAssertNil(Converts.convertLatLng(LatLngIOS(latitude: 65.0121, longitude: nil)))
        XCTAssertNil(Converts.convertLatLng(LatLngIOS(latitude: nil, longitude: 25.4651)))
        XCTAssertNil(Converts.convertLatLng(LatLngIOS(latitude: nil, longitude: nil)))
    }
    
    func testConvertsLocationBias() {
        XCTAssertNotNil(Converts.convertLocationBias(LatLngBoundsIOS(
            southwest: LatLngIOS(latitude: 60.4518, longitude: 22.2666),
            northeast: LatLngIOS(latitude: 70.0821, longitude: 27.8718)
        )))
        XCTAssertNil(Converts.convertLocationBias(nil))
        XCTAssertNil(Converts.convertLocationBias(LatLngBoundsIOS(
            southwest: nil,
            northeast: LatLngIOS(latitude: 70.0821, longitude: 27.8718)
        )))
        XCTAssertNil(Converts.convertLocationBias(LatLngBoundsIOS(
            southwest: LatLngIOS(latitude: 60.4518, longitude: 22.2666),
            northeast: nil
        )))
        XCTAssertNil(Converts.convertLocationBias(LatLngBoundsIOS(
            southwest: LatLngIOS(latitude: nil, longitude: 22.2666),
            northeast: LatLngIOS(latitude: 70.0821, longitude: 27.8718)
        )))
        XCTAssertNil(Converts.convertLocationBias(LatLngBoundsIOS(
            southwest: nil,
            northeast: nil
        )))
    }
    
    func testConvertsLocationRestriction() {
        XCTAssertNotNil(Converts.convertLocationRestrction(LatLngBoundsIOS(
            southwest: LatLngIOS(latitude: 60.4518, longitude: 22.2666),
            northeast: LatLngIOS(latitude: 70.0821, longitude: 27.8718)
        )))
        XCTAssertNil(Converts.convertLocationRestrction(nil))
        XCTAssertNil(Converts.convertLocationRestrction(LatLngBoundsIOS(
            southwest: nil,
            northeast: LatLngIOS(latitude: 70.0821, longitude: 27.8718)
        )))
        XCTAssertNil(Converts.convertLocationRestrction(LatLngBoundsIOS(
            southwest: LatLngIOS(latitude: 60.4518, longitude: 22.2666),
            northeast: nil
        )))
        XCTAssertNil(Converts.convertLocationRestrction(LatLngBoundsIOS(
            southwest: LatLngIOS(latitude: nil, longitude: 22.2666),
            northeast: LatLngIOS(latitude: 70.0821, longitude: 27.8718)
        )))
        XCTAssertNil(Converts.convertLocationRestrction(LatLngBoundsIOS(
            southwest: nil,
            northeast: nil
        )))
    }
    
    func testConvertsTypeFilters() {
        let values:[Int32] = [Int32(TypeFilterIOS.address.rawValue)]
        XCTAssertNotNil(Converts.convertTypeFilters(values))
        XCTAssertEqual(Converts.convertTypeFilters(values), [GMSPlacesAutocompleteTypeFilter.address])
        XCTAssertNil(Converts.convertTypeFilters(nil))
    }
    
    func testConvertsTypeFiltersToSingle() {
        let values:[Int32] = [Int32(TypeFilterIOS.address.rawValue)]
        XCTAssertNotNil(Converts.convertTypeFiltersToSingle(values))
        XCTAssertEqual(Converts.convertTypeFiltersToSingle(values), GMSPlacesAutocompleteTypeFilter.address)
        XCTAssertNotNil(Converts.convertTypeFiltersToSingle([]))
        XCTAssertEqual(Converts.convertTypeFiltersToSingle(nil), GMSPlacesAutocompleteTypeFilter.noFilter)
    }
    
    func testConvertsTypeFilter() {
        XCTAssertEqual(Converts.convertTypeFilter(Int32(TypeFilterIOS.address.rawValue)), GMSPlacesAutocompleteTypeFilter.address)
        XCTAssertEqual(Converts.convertTypeFilter(Int32(TypeFilterIOS.cities.rawValue)), GMSPlacesAutocompleteTypeFilter.city)
        XCTAssertEqual(Converts.convertTypeFilter(Int32(TypeFilterIOS.establishment.rawValue)), GMSPlacesAutocompleteTypeFilter.establishment)
        XCTAssertEqual(Converts.convertTypeFilter(Int32(TypeFilterIOS.geocode.rawValue)), GMSPlacesAutocompleteTypeFilter.geocode)
        XCTAssertEqual(Converts.convertTypeFilter(Int32(TypeFilterIOS.regions.rawValue)), GMSPlacesAutocompleteTypeFilter.region)
        XCTAssertEqual(Converts.convertTypeFilter(nil), GMSPlacesAutocompleteTypeFilter.noFilter)
    }
    
    func testConversAutocompleteResults() throws {
        
        try XCTSkipIf(!hasApiKey)
        
        let expectation = XCTestExpectation(description: "Converts find autocomplete predictions response to pigeon generated values")
        plugin.findAutocompletePredictions(query: queryString, filter: GMSAutocompleteFilter(), refreshToken: true, callback: { (results, error) in
            if let error = error {
                XCTAssertNotNil(error)
            } else {
                XCTAssertNotNil(results)
                if (results!.count > 0) {
                    XCTAssertEqual(Converts.convertResults(results).count, results!.count)
                    let result = results?.first
                    XCTAssertNotNil(result)
                    let converted = Converts.convertPrediction(result!)
                    XCTAssertNotNil(converted)
                    if (result!.distanceMeters == nil) {
                        XCTAssertNil(converted!.distanceMeters)
                    } else {
                        XCTAssertEqual(converted!.distanceMeters, Int32(truncating: result!.distanceMeters!))
                    }
                    XCTAssertEqual(converted!.fullText, result!.attributedFullText.string)
                    XCTAssertEqual(converted!.primaryText, result!.attributedPrimaryText.string)
                    XCTAssertEqual(converted!.secondaryText, result!.attributedSecondaryText?.string)
                    XCTAssertEqual(converted!.placeId, result!.placeID)
                    XCTAssertEqual(converted!.placeTypes.count, result!.types.count)
                }
            }

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testConvertsPlaceTypes() {
        let values:[String] = [kGMSPlaceTypeGeocode]
        XCTAssertNotNil(Converts.convertPlaceTypes(values))
        XCTAssertEqual(Converts.convertPlaceTypes(values), [Int32(PlaceTypeIOS.geocode.rawValue)])
        XCTAssertNotNil(Converts.convertPlaceTypes([""]))
        XCTAssertEqual(Converts.convertPlaceTypes([""]), [-1])
    }
    
    func testConvertsPlaceType() {
        XCTAssertNotNil(Converts.convertPlaceType(kGMSPlaceTypeGeocode))
        XCTAssertEqual(Converts.convertPlaceType(kGMSPlaceTypeGeocode), PlaceTypeIOS.geocode)
        XCTAssertNil(Converts.convertPlaceType(""))
    }
}
