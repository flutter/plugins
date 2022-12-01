// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
@testable import google_maps_places_ios
@testable import GooglePlaces

final class AutoCompleteTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    let plugin = SwiftGoogleMapsPlacesIosPlugin()
    let queryString:String = "Koulu"
    let hasApiKey:Bool = ProcessInfo.processInfo.environment["MAPS_API_KEY"] != nil
    
    func testFindAutoCompletePredictionsWithEmptyDataSet() throws {
        
        try XCTSkipIf(!hasApiKey)
        
        let expectation = XCTestExpectation(description: "Run find auto complete predictions with empty data set")
        plugin.findAutocompletePredictionsIOS(query: "", locationBias: nil, locationRestriction: nil, origin: nil, countries: nil, typeFilter: nil, refreshToken: nil, completion: { (result) in
            XCTAssertNil(result)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFindAutoCompletePredictionsOnlyWithQuery() throws {
        
        try XCTSkipIf(!hasApiKey)
        
        let expectation = XCTestExpectation(description: "Run find auto complete predictions with minimum data set")
        plugin.findAutocompletePredictionsIOS(query: queryString, locationBias: nil, locationRestriction: nil, origin: nil, countries: nil, typeFilter: nil, refreshToken: nil, completion: { (result) in
            XCTAssertNotNil(result)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFindAutoCompelePredictionsWithLocationBias() throws {
        
        try XCTSkipIf(!hasApiKey)
        
        let expectation = XCTestExpectation(description: "Run find auto complete predictions with location bias")
        plugin.findAutocompletePredictionsIOS(query: queryString, locationBias: LatLngBoundsIOS(
            southwest: LatLngIOS(latitude: 60.4518, longitude: 22.2666),
            northeast: LatLngIOS(latitude: 70.0821, longitude: 27.8718)
        ), locationRestriction: nil, origin: LatLngIOS(latitude: 65.0121, longitude: 25.4651), countries: nil, typeFilter: nil, refreshToken: nil, completion: { (result) in
            XCTAssertNotNil(result)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFindAutoCompelePredictionsWithLocationRestriction() throws {
        
        try XCTSkipIf(!hasApiKey)
        
        let expectation = XCTestExpectation(description: "Run find auto complete predictions with location restriction")
        plugin.findAutocompletePredictionsIOS(query: queryString, locationBias: nil, locationRestriction: LatLngBoundsIOS(
            southwest: LatLngIOS(latitude: 60.4518, longitude: 22.2666),
            northeast: LatLngIOS(latitude: 70.0821, longitude: 27.8718)
        ), origin: LatLngIOS(latitude: 65.0121, longitude: 25.4651), countries: nil, typeFilter: nil, refreshToken: nil, completion: { (result) in
            XCTAssertNotNil(result)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFindAutoCompelePredictionsWithLocationBiasAndRestriction() throws {
        
        try XCTSkipIf(!hasApiKey)
        
        let expectation = XCTestExpectation(description: "Run find auto complete predictions with location bias and restriction")
        plugin.findAutocompletePredictionsIOS(query: queryString, locationBias: LatLngBoundsIOS(
            southwest: LatLngIOS(latitude: 60.4518, longitude: 22.2666),
            northeast: LatLngIOS(latitude: 70.0821, longitude: 27.8718)
        ), locationRestriction: LatLngBoundsIOS(
            southwest: LatLngIOS(latitude: 60.4518, longitude: 22.2666),
            northeast: LatLngIOS(latitude: 70.0821, longitude: 27.8718)
        ), origin: LatLngIOS(latitude: 65.0121, longitude: 25.4651), countries: nil, typeFilter: nil, refreshToken: nil, completion: { (result) in
            XCTAssertNil(result)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFindAutoCompelePredictionsWithCountriesAndTypeFilter() throws {
        
        try XCTSkipIf(!hasApiKey)
        
        let expectation = XCTestExpectation(description: "Run find auto complete predictions with country and type filter")
        plugin.findAutocompletePredictionsIOS(query: queryString, locationBias: LatLngBoundsIOS(
            southwest: LatLngIOS(latitude: 60.4518, longitude: 22.2666),
            northeast: LatLngIOS(latitude: 70.0821, longitude: 27.8718)
        ), locationRestriction: nil, origin: LatLngIOS(latitude: 65.0121, longitude: 25.4651), countries: ["fi"], typeFilter: [Int32(TypeFilterIOS.establishment.rawValue)], refreshToken: nil, completion: { (result) in
            XCTAssertNotNil(result)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFindAutoCompletePredictionsWithTokenRefresh() throws {
        
        try XCTSkipIf(!hasApiKey)
        
        let expectation = XCTestExpectation(description: "Run find auto complete predictions with token refresh")
        plugin.findAutocompletePredictionsIOS(query: queryString, locationBias: nil, locationRestriction: nil, origin: nil, countries: nil, typeFilter: nil, refreshToken: nil, completion: { (result) in
            XCTAssertNotNil(result)
            SwiftGoogleMapsPlacesIosPlugin().findAutocompletePredictionsIOS(query: "Koulu", locationBias: nil, locationRestriction: nil, origin: nil, countries: nil, typeFilter: nil, refreshToken: true, completion: { (result) in
                XCTAssertNotNil(result)
                expectation.fulfill()
            })
        })
        wait(for: [expectation], timeout: 10.0)
    }
}
