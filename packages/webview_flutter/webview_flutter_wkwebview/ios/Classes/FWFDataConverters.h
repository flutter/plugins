// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFGeneratedWebKitApis.h"

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Converts an FWFNSUrlRequestData to an NSURLRequest.
 *
 * @param data The data object containing information to create an NSURLRequest.
 *
 * @return An NSURLRequest or nil if data could not be converted.
 */
extern NSURLRequest *_Nullable FWFNSURLRequestFromRequestData(FWFNSUrlRequestData *data);

/**
 * Converts an FWFNSHttpCookieData to an NSHTTPCookie.
 *
 * @param data The data object containing information to create an NSHTTPCookie.
 *
 * @return An NSHTTPCookie or nil if data could not be converted.
 */
extern NSHTTPCookie *_Nullable FWFNSHTTPCookieFromCookieData(FWFNSHttpCookieData *data);

/**
 * Converts an FWFNSKeyValueObservingOptionsEnumData to an NSKeyValueObservingOptions.
 *
 * @param data The data object containing information to create an NSKeyValueObservingOptions.
 *
 * @return An NSKeyValueObservingOptions or -1 if data could not be converted.
 */
extern NSKeyValueObservingOptions FWFNSKeyValueObservingOptionsFromEnumData(
    FWFNSKeyValueObservingOptionsEnumData *data);

/**
 * Converts an FWFNSHTTPCookiePropertyKeyEnumData to an NSHTTPCookiePropertyKey.
 *
 * @param data The data object containing information to create an NSHTTPCookiePropertyKey.
 *
 * @return An NSHttpCookiePropertyKey or nil if data could not be converted.
 */
extern NSHTTPCookiePropertyKey _Nullable FWFNSHTTPCookiePropertyKeyFromEnumData(
    FWFNSHttpCookiePropertyKeyEnumData *data);

/**
 * Converts a WKUserScriptData to a WKUserScript.
 *
 * @param data The data object containing information to create a WKUserScript.
 *
 * @return A WKUserScript or nil if data could not be converted.
 */
extern WKUserScript *FWFWKUserScriptFromScriptData(FWFWKUserScriptData *data);

/**
 * Converts an FWFWKUserScriptInjectionTimeEnumData to a WKUserScriptInjectionTime.
 *
 * @param data The data object containing information to create a WKUserScriptInjectionTime.
 *
 * @return A WKUserScriptInjectionTime or -1 if data could not be converted.
 */
extern WKUserScriptInjectionTime FWFWKUserScriptInjectionTimeFromEnumData(
    FWFWKUserScriptInjectionTimeEnumData *data);

/**
 * Converts an FWFWKAudiovisualMediaTypeEnumData to a WKAudiovisualMediaTypes.
 *
 * @param data The data object containing information to create a WKAudiovisualMediaTypes.
 *
 * @return A WKAudiovisualMediaType or -1 if data could not be converted.
 */
API_AVAILABLE(ios(10.0))
extern WKAudiovisualMediaTypes FWFWKAudiovisualMediaTypeFromEnumData(
    FWFWKAudiovisualMediaTypeEnumData *data);

/**
 * Converts an FWFWKWebsiteDataTypeEnumData to a WKWebsiteDataType.
 *
 * @param data The data object containing information to create a WKWebsiteDataType.
 *
 * @return A WKWebsiteDataType or nil if data could not be converted.
 */
extern NSString *_Nullable FWFWKWebsiteDataTypeFromEnumData(FWFWKWebsiteDataTypeEnumData *data);

NS_ASSUME_NONNULL_END
