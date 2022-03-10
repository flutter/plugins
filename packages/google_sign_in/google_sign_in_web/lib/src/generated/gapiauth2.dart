// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Type definitions for non-npm package Google Sign-In API 0.0
/// Project: https://developers.google.com/identity/sign-in/web/
/// Definitions by: Derek Lawless <https://github.com/flawless2011>
/// Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped
/// TypeScript Version: 2.3

/// <reference types="gapi" />

// https://github.com/DefinitelyTyped/DefinitelyTyped/blob/master/types/gapi.auth2

// ignore_for_file: public_member_api_docs, unused_element, non_constant_identifier_names, sort_constructors_first, always_specify_types

@JS()
library gapiauth2;

import 'package:js/js.dart';
import 'package:js/js_util.dart' show promiseToFuture;

@anonymous
@JS()
class GoogleAuthInitFailureError {
  external String get error;
  external set error(String? value);

  external String get details;
  external set details(String? value);
}

@anonymous
@JS()
class GoogleAuthSignInError {
  external String get error;
  external set error(String value);
}

@anonymous
@JS()
class OfflineAccessResponse {
  external String? get code;
  external set code(String? value);
}

// Module gapi.auth2
/// GoogleAuth is a singleton class that provides methods to allow the user to sign in with a Google account,
/// get the user's current sign-in status, get specific data from the user's Google profile,
/// request additional scopes, and sign out from the current account.
@JS('gapi.auth2.GoogleAuth')
class GoogleAuth {
  external IsSignedIn get isSignedIn;
  external set isSignedIn(IsSignedIn v);
  external CurrentUser? get currentUser;
  external set currentUser(CurrentUser? v);

  /// Calls the onInit function when the GoogleAuth object is fully initialized, or calls the onFailure function if
  /// initialization fails.
  external dynamic then(dynamic onInit(GoogleAuth googleAuth),
      [dynamic onFailure(GoogleAuthInitFailureError reason)]);

  /// Signs out all accounts from the application.
  external dynamic signOut();

  /// Revokes all of the scopes that the user granted.
  external dynamic disconnect();

  /// Attaches the sign-in flow to the specified container's click handler.
  external dynamic attachClickHandler(
      dynamic container,
      SigninOptions options,
      dynamic onsuccess(GoogleUser googleUser),
      dynamic onfailure(String reason));
}

@anonymous
@JS()
abstract class _GoogleAuth {
  external Promise<GoogleUser> signIn(
      [dynamic /*SigninOptions|SigninOptionsBuilder*/ options]);
  external Promise<OfflineAccessResponse> grantOfflineAccess(
      [OfflineAccessOptions? options]);
}

extension GoogleAuthExtensions on GoogleAuth {
  Future<GoogleUser> signIn(
      [dynamic /*SigninOptions|SigninOptionsBuilder*/ options]) {
    final _GoogleAuth tt = this as _GoogleAuth;
    return promiseToFuture(tt.signIn(options));
  }

  Future<OfflineAccessResponse> grantOfflineAccess(
      [OfflineAccessOptions? options]) {
    final _GoogleAuth tt = this as _GoogleAuth;
    return promiseToFuture(tt.grantOfflineAccess(options));
  }
}

@anonymous
@JS()
abstract class IsSignedIn {
  /// Returns whether the current user is currently signed in.
  external bool get();

  /// Listen for changes in the current user's sign-in state.
  external void listen(dynamic listener(bool signedIn));
}

@anonymous
@JS()
abstract class CurrentUser {
  /// Returns a GoogleUser object that represents the current user. Note that in a newly-initialized
  /// GoogleAuth instance, the current user has not been set. Use the currentUser.listen() method or the
  /// GoogleAuth.then() to get an initialized GoogleAuth instance.
  external GoogleUser get();

  /// Listen for changes in currentUser.
  external void listen(dynamic listener(GoogleUser user));
}

@anonymous
@JS()
abstract class SigninOptions {
  /// The package name of the Android app to install over the air.
  /// See Android app installs from your web site:
  /// https://developers.google.com/identity/sign-in/web/android-app-installs
  external String? get app_package_name;
  external set app_package_name(String? v);

  /// Fetch users' basic profile information when they sign in.
  /// Adds 'profile', 'email' and 'openid' to the requested scopes.
  /// True if unspecified.
  external bool? get fetch_basic_profile;
  external set fetch_basic_profile(bool? v);

  /// Specifies whether to prompt the user for re-authentication.
  /// See OpenID Connect Request Parameters:
  /// https://openid.net/specs/openid-connect-basic-1_0.html#RequestParameters
  external String? get prompt;
  external set prompt(String? v);

  /// The scopes to request, as a space-delimited string.
  /// Optional if fetch_basic_profile is not set to false.
  external String? get scope;
  external set scope(String? v);

  /// The UX mode to use for the sign-in flow.
  /// By default, it will open the consent flow in a popup.
  external String? /*'popup'|'redirect'*/ get ux_mode;
  external set ux_mode(String? /*'popup'|'redirect'*/ v);

  /// If using ux_mode='redirect', this parameter allows you to override the default redirect_uri that will be used at the end of the consent flow.
  /// The default redirect_uri is the current URL stripped of query parameters and hash fragment.
  external String? get redirect_uri;
  external set redirect_uri(String? v);

  // When your app knows which user it is trying to authenticate, it can provide this parameter as a hint to the authentication server.
  // Passing this hint suppresses the account chooser and either pre-fill the email box on the sign-in form, or select the proper session (if the user is using multiple sign-in),
  // which can help you avoid problems that occur if your app logs in the wrong user account. The value can be either an email address or the sub string,
  // which is equivalent to the user's Google ID.
  // https://developers.google.com/identity/protocols/OpenIDConnect?hl=en#authenticationuriparameters
  external String? get login_hint;
  external set login_hint(String? v);

  external factory SigninOptions(
      {String app_package_name,
      bool fetch_basic_profile,
      String prompt,
      String scope,
      String /*'popup'|'redirect'*/ ux_mode,
      String redirect_uri,
      String login_hint});
}

/// Definitions by: John <https://github.com/jhcao23>
/// Interface that represents the different configuration parameters for the GoogleAuth.grantOfflineAccess(options) method.
/// Reference: https://developers.google.com/api-client-library/javascript/reference/referencedocs#gapiauth2offlineaccessoptions
@anonymous
@JS()
abstract class OfflineAccessOptions {
  external String? get scope;
  external set scope(String? v);
  external String? /*'select_account'|'consent'*/ get prompt;
  external set prompt(String? /*'select_account'|'consent'*/ v);
  external String? get app_package_name;
  external set app_package_name(String? v);
  external factory OfflineAccessOptions(
      {String scope,
      String /*'select_account'|'consent'*/ prompt,
      String app_package_name});
}

/// Interface that represents the different configuration parameters for the gapi.auth2.init method.
/// Reference: https://developers.google.com/api-client-library/javascript/reference/referencedocs#gapiauth2clientconfig
@anonymous
@JS()
abstract class ClientConfig {
  /// The app's client ID, found and created in the Google Developers Console.
  external String? get client_id;
  external set client_id(String? v);

  /// The domains for which to create sign-in cookies. Either a URI, single_host_origin, or none.
  /// Defaults to single_host_origin if unspecified.
  external String? get cookie_policy;
  external set cookie_policy(String? v);

  /// The scopes to request, as a space-delimited string. Optional if fetch_basic_profile is not set to false.
  external String? get scope;
  external set scope(String? v);

  /// Fetch users' basic profile information when they sign in. Adds 'profile' and 'email' to the requested scopes. True if unspecified.
  external bool? get fetch_basic_profile;
  external set fetch_basic_profile(bool? v);

  /// The Google Apps domain to which users must belong to sign in. This is susceptible to modification by clients,
  /// so be sure to verify the hosted domain property of the returned user. Use GoogleUser.getHostedDomain() on the client,
  /// and the hd claim in the ID Token on the server to verify the domain is what you expected.
  external String? get hosted_domain;
  external set hosted_domain(String? v);

  /// Used only for OpenID 2.0 client migration. Set to the value of the realm that you are currently using for OpenID 2.0,
  /// as described in <a href="https://developers.google.com/accounts/docs/OpenID#openid-connect">OpenID 2.0 (Migration)</a>.
  external String? get openid_realm;
  external set openid_realm(String? v);

  /// The UX mode to use for the sign-in flow.
  /// By default, it will open the consent flow in a popup.
  external String? /*'popup'|'redirect'*/ get ux_mode;
  external set ux_mode(String? /*'popup'|'redirect'*/ v);

  /// If using ux_mode='redirect', this parameter allows you to override the default redirect_uri that will be used at the end of the consent flow.
  /// The default redirect_uri is the current URL stripped of query parameters and hash fragment.
  external String? get redirect_uri;
  external set redirect_uri(String? v);
  external factory ClientConfig(
      {String client_id,
      String cookie_policy,
      String scope,
      bool fetch_basic_profile,
      String? hosted_domain,
      String openid_realm,
      String /*'popup'|'redirect'*/ ux_mode,
      String redirect_uri});
}

@JS('gapi.auth2.SigninOptionsBuilder')
class SigninOptionsBuilder {
  external dynamic setAppPackageName(String name);
  external dynamic setFetchBasicProfile(bool fetch);
  external dynamic setPrompt(String prompt);
  external dynamic setScope(String scope);
  external dynamic setLoginHint(String hint);
}

@anonymous
@JS()
abstract class BasicProfile {
  external String? getId();
  external String? getName();
  external String? getGivenName();
  external String? getFamilyName();
  external String? getImageUrl();
  external String? getEmail();
}

/// Reference: https://developers.google.com/api-client-library/javascript/reference/referencedocs#gapiauth2authresponse
@anonymous
@JS()
abstract class AuthResponse {
  external String? get access_token;
  external set access_token(String? v);
  external String? get id_token;
  external set id_token(String? v);
  external String? get login_hint;
  external set login_hint(String? v);
  external String? get scope;
  external set scope(String? v);
  external num? get expires_in;
  external set expires_in(num? v);
  external num? get first_issued_at;
  external set first_issued_at(num? v);
  external num? get expires_at;
  external set expires_at(num? v);
  external factory AuthResponse(
      {String? access_token,
      String? id_token,
      String? login_hint,
      String? scope,
      num? expires_in,
      num? first_issued_at,
      num? expires_at});
}

/// Reference: https://developers.google.com/api-client-library/javascript/reference/referencedocs#gapiauth2authorizeconfig
@anonymous
@JS()
abstract class AuthorizeConfig {
  external String get client_id;
  external set client_id(String v);
  external String get scope;
  external set scope(String v);
  external String? get response_type;
  external set response_type(String? v);
  external String? get prompt;
  external set prompt(String? v);
  external String? get cookie_policy;
  external set cookie_policy(String? v);
  external String? get hosted_domain;
  external set hosted_domain(String? v);
  external String? get login_hint;
  external set login_hint(String? v);
  external String? get app_package_name;
  external set app_package_name(String? v);
  external String? get openid_realm;
  external set openid_realm(String? v);
  external bool? get include_granted_scopes;
  external set include_granted_scopes(bool? v);
  external factory AuthorizeConfig(
      {String client_id,
      String scope,
      String response_type,
      String prompt,
      String cookie_policy,
      String hosted_domain,
      String login_hint,
      String app_package_name,
      String openid_realm,
      bool include_granted_scopes});
}

/// Reference: https://developers.google.com/api-client-library/javascript/reference/referencedocs#gapiauth2authorizeresponse
@anonymous
@JS()
abstract class AuthorizeResponse {
  external String get access_token;
  external set access_token(String v);
  external String get id_token;
  external set id_token(String v);
  external String get code;
  external set code(String v);
  external String get scope;
  external set scope(String v);
  external num get expires_in;
  external set expires_in(num v);
  external num get first_issued_at;
  external set first_issued_at(num v);
  external num get expires_at;
  external set expires_at(num v);
  external String get error;
  external set error(String v);
  external String get error_subtype;
  external set error_subtype(String v);
  external factory AuthorizeResponse(
      {String access_token,
      String id_token,
      String code,
      String scope,
      num expires_in,
      num first_issued_at,
      num expires_at,
      String error,
      String error_subtype});
}

/// A GoogleUser object represents one user account.
@anonymous
@JS()
abstract class GoogleUser {
  /// Get the user's unique ID string.
  external String? getId();

  /// Returns true if the user is signed in.
  external bool isSignedIn();

  /// Get the user's Google Apps domain if the user signed in with a Google Apps account.
  external String? getHostedDomain();

  /// Get the scopes that the user granted as a space-delimited string.
  external String? getGrantedScopes();

  /// Get the user's basic profile information.
  external BasicProfile? getBasicProfile();

  /// Get the response object from the user's auth session.
  // This returns an empty JS object when the user hasn't attempted to sign in.
  external AuthResponse getAuthResponse([bool includeAuthorizationData]);

  /// Returns true if the user granted the specified scopes.
  external bool hasGrantedScopes(String scopes);

  // Has the API for grant and grantOfflineAccess changed?
  /// Request additional scopes to the user.
  ///
  /// See GoogleAuth.signIn() for the list of parameters and the error code.
  external dynamic grant(
      [dynamic /*SigninOptions|SigninOptionsBuilder*/ options]);

  /// Get permission from the user to access the specified scopes offline.
  /// When you use GoogleUser.grantOfflineAccess(), the sign-in flow skips the account chooser step.
  /// See GoogleUser.grantOfflineAccess().
  external void grantOfflineAccess(String scopes);

  /// Revokes all of the scopes that the user granted.
  external void disconnect();
}

@anonymous
@JS()
abstract class _GoogleUser {
  /// Forces a refresh of the access token, and then returns a Promise for the new AuthResponse.
  external Promise<AuthResponse> reloadAuthResponse();
}

extension GoogleUserExtensions on GoogleUser {
  Future<AuthResponse> reloadAuthResponse() {
    final _GoogleUser tt = this as _GoogleUser;
    return promiseToFuture(tt.reloadAuthResponse());
  }
}

/// Initializes the GoogleAuth object.
/// Reference: https://developers.google.com/api-client-library/javascript/reference/referencedocs#gapiauth2initparams
@JS('gapi.auth2.init')
external GoogleAuth init(ClientConfig params);

/// Returns the GoogleAuth object. You must initialize the GoogleAuth object with gapi.auth2.init() before calling this method.
@JS('gapi.auth2.getAuthInstance')
external GoogleAuth? getAuthInstance();

/// Performs a one time OAuth 2.0 authorization.
/// Reference: https://developers.google.com/api-client-library/javascript/reference/referencedocs#gapiauth2authorizeparams-callback
@JS('gapi.auth2.authorize')
external void authorize(
    AuthorizeConfig params, void callback(AuthorizeResponse response));
// End module gapi.auth2

// Module gapi.signin2
@JS('gapi.signin2.render')
external void render(
    dynamic id,
    dynamic
        /*{
    /**
     * The auth scope or scopes to authorize. Auth scopes for individual APIs can be found in their documentation.
     */
    scope?: string;

    /**
     * The width of the button in pixels (default: 120).
     */
    width?: number;

    /**
     * The height of the button in pixels (default: 36).
     */
    height?: number;

    /**
     * Display long labels such as "Sign in with Google" rather than "Sign in" (default: false).
     */
    longtitle?: boolean;

    /**
     * The color theme of the button: either light or dark (default: light).
     */
    theme?: string;

    /**
     * The callback function to call when a user successfully signs in (default: none).
     */
    onsuccess?(user: auth2.GoogleUser): void;

    /**
     * The callback function to call when sign-in fails (default: none).
     */
    onfailure?(reason: { error: string }): void;

    /**
     * The package name of the Android app to install over the air. See
     * <a href="https://developers.google.com/identity/sign-in/web/android-app-installs">Android app installs from your web site</a>.
     * Optional. (default: none)
     */
    app_package_name?: string;
  }*/
        options);

// End module gapi.signin2
@JS()
abstract class Promise<T> {
  external factory Promise(
      void executor(void resolve(T result), Function reject));
  external Promise then(void onFulfilled(T result), [Function onRejected]);
}
