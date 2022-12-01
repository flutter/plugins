// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit
import GooglePlaces

/// GoogleMapsPlacesIOSPlugin
public class SwiftGoogleMapsPlacesIosPlugin: NSObject, FlutterPlugin, GoogleMapsPlacesApiIOS {
    
    private var placesClient: GMSPlacesClient!
    private var previousSessionToken: GMSAutocompleteSessionToken?
    
    /// Register Flutter API communications
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let api : GoogleMapsPlacesApiIOS & NSObjectProtocol = SwiftGoogleMapsPlacesIosPlugin.init()
        GoogleMapsPlacesApiIOSSetup.setUp(binaryMessenger: messenger, api: api)
    }
    
    /// Finds Autocomplete Predictions API call
    func findAutocompletePredictionsIOS(query: String, locationBias: LatLngBoundsIOS?, locationRestriction: LatLngBoundsIOS?, origin: LatLngIOS?, countries: [String?]?, typeFilter: [Int32?]?, refreshToken: Bool?, completion: @escaping ([AutocompletePredictionIOS?]?) -> Void) {
        
        guard !query.isEmpty else {
            print("Missing required field query")
            completion(nil)
            return
        }
        
        guard locationBias == nil || locationRestriction == nil else {
            print("Only locationBias or locationRestriction is allowed")
            completion(nil)
            return
        }
        
        let filter = GMSAutocompleteFilter()
        filter.type = Converts.convertTypeFiltersToSingle(typeFilter);
        filter.countries = countries as? [String]
        filter.origin = Converts.convertLatLng(origin)
        
        if (locationBias != nil) {
            filter.locationBias = Converts.convertLocationBias(locationBias)
        } else if (locationRestriction != nil) {
            filter.locationRestriction = Converts.convertLocationRestrction(locationRestriction)
        }
        findAutocompletePredictions(query: query, filter: filter, refreshToken: refreshToken == true, callback: { (results, error) in
            if let error = error {
                print("findPlacesAutoComplete error: \(error)")
                // Pigeon does not generate flutter error callback at the moment so returning nil.
                // TODO(TimoPieti): Fix to return flutter error https://github.com/flutter/flutter/issues/112483 is fixed in stable.
                /*completion(FlutterError(
                 code: "API_ERROR",
                 message: error.localizedDescription,
                 details: nil
                 ))*/
                completion(nil)
            } else {
                completion(Converts.convertResults(results))
            }
        })
    }
    
    /// Finds Autocomplete Predictions
    /// ref: https://developers.google.com/maps/documentation/places/ios-sdk/autocomplete#get_place_predictions
    internal func findAutocompletePredictions(query: String, filter: GMSAutocompleteFilter, refreshToken: Bool, callback: @escaping (GMSAutocompletePredictionsCallback)) {
        let sessionToken = initialize(refreshToken)
        guard sessionToken != nil else {
            print("failed to initialize API CLIENT")
            callback(nil, NSErrorDomain(string: "failed to initialize API CLIENT") as? Error)
            return
        }
        placesClient.findAutocompletePredictions(
            fromQuery: query, filter: filter, sessionToken: sessionToken,
            callback: { (results, error) in
                if (error != nil) {
                    self.previousSessionToken = sessionToken
                }
                callback(results, error)
            })
    }
    
    /// Initializes Places client
    internal func initialize(_ refresh: Bool) -> GMSAutocompleteSessionToken? {
        guard (placesClient == nil) else {
            return getSessionToken(refresh)
        }
        placesClient = GMSPlacesClient.shared()
        return getSessionToken(refresh)
    }
    
    /// Fetches new session token if needed
    private func getSessionToken(_ refresh: Bool) -> GMSAutocompleteSessionToken? {
        let localToken = previousSessionToken
        if (refresh || localToken == nil) {
            return GMSAutocompleteSessionToken.init()
        }
        return localToken
    }
}
