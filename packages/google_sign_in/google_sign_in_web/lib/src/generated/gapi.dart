// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library gapi;

import "package:js/js.dart";
import "package:js/js_util.dart" show promiseToFuture;

/// Type definitions for Google API Client
/// Project: https://github.com/google/google-api-javascript-client
/// Definitions by: Frank M <https://github.com/sgtfrankieboy>, grant <https://github.com/grant>
/// Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped
/// TypeScript Version: 2.3

/// The OAuth 2.0 token object represents the OAuth 2.0 token and any associated data.
@anonymous
@JS()
abstract class GoogleApiOAuth2TokenObject {
  /// The OAuth 2.0 token. Only present in successful responses
  external String get access_token;
  external set access_token(String v);

  /// Details about the error. Only present in error responses
  external String get error;
  external set error(String v);

  /// The duration, in seconds, the token is valid for. Only present in successful responses
  external String get expires_in;
  external set expires_in(String v);
  external GoogleApiOAuth2TokenSessionState get session_state;
  external set session_state(GoogleApiOAuth2TokenSessionState v);

  /// The Google API scopes related to this token
  external String get state;
  external set state(String v);
  external factory GoogleApiOAuth2TokenObject(
      {String access_token,
      String error,
      String expires_in,
      GoogleApiOAuth2TokenSessionState session_state,
      String state});
}

@anonymous
@JS()
abstract class GoogleApiOAuth2TokenSessionState {
  external dynamic /*{
        authuser: string,
    }*/
      get extraQueryParams;
  external set extraQueryParams(
      dynamic
          /*{
        authuser: string,
    }*/
          v);
  external factory GoogleApiOAuth2TokenSessionState(
      {dynamic
          /*{
        authuser: string,
    }*/
          extraQueryParams});
}

/// Fix for #8215
/// https://github.com/DefinitelyTyped/DefinitelyTyped/issues/8215
/// Usage example:
/// https://developers.google.com/identity/sign-in/web/session-state

// Module gapi
typedef void LoadCallback(
    [dynamic args1,
    dynamic args2,
    dynamic args3,
    dynamic args4,
    dynamic args5]);

@anonymous
@JS()
abstract class LoadConfig {
  external LoadCallback get callback;
  external set callback(LoadCallback v);
  external Function get onerror;
  external set onerror(Function v);
  external num get timeout;
  external set timeout(num v);
  external Function get ontimeout;
  external set ontimeout(Function v);
  external factory LoadConfig(
      {LoadCallback callback,
      Function onerror,
      num timeout,
      Function ontimeout});
}

/*type CallbackOrConfig = LoadConfig | LoadCallback;*/
/// Pragmatically initialize gapi class member.
/// Reference: https://developers.google.com/api-client-library/javascript/reference/referencedocs#gapiloadlibraries-callbackorconfig
@JS("gapi.load")
external void load(
    String apiName, dynamic /*LoadConfig|LoadCallback*/ callback);
// End module gapi

// Module gapi.auth
/// Initiates the OAuth 2.0 authorization process. The browser displays a popup window prompting the user authenticate and authorize. After the user authorizes, the popup closes and the callback function fires.
@JS("gapi.auth.authorize")
external void authorize(
    dynamic
        /*{
        /**
         * The application's client ID.
         */
        client_id?: string;
        /**
         * If true, then login uses "immediate mode", which means that the token is refreshed behind the scenes, and no UI is shown to the user.
         */
        immediate?: boolean;
        /**
         * The OAuth 2.0 response type property. Default: token
         */
        response_type?: string;
        /**
         * The auth scope or scopes to authorize. Auth scopes for individual APIs can be found in their documentation.
         */
        scope?: any;
        /**
         * The user to sign in as. -1 to toggle a multi-account chooser, 0 to default to the user's current account, and 1 to automatically sign in if the user is signed into Google Plus.
         */
        authuser?: number;
    }*/
        params,
    dynamic callback(GoogleApiOAuth2TokenObject token));

/// Initializes the authorization feature. Call this when the client loads to prevent popup blockers from blocking the auth window on gapi.auth.authorize calls.
@JS("gapi.auth.init")
external void init(dynamic callback());

/// Retrieves the OAuth 2.0 token for the application.
@JS("gapi.auth.getToken")
external GoogleApiOAuth2TokenObject getToken();

/// Sets the OAuth 2.0 token for the application.
@JS("gapi.auth.setToken")
external void setToken(GoogleApiOAuth2TokenObject token);

/// Initiates the client-side Google+ Sign-In OAuth 2.0 flow.
/// When the method is called, the OAuth 2.0 authorization dialog is displayed to the user and when they accept, the callback function is called.
@JS("gapi.auth.signIn")
external void signIn(
    dynamic
        /*{
        /**
         * Your OAuth 2.0 client ID that you obtained from the Google Developers Console.
         */
        clientid?: string;
        /**
         * Directs the sign-in button to store user and session information in a session cookie and HTML5 session storage on the user's client for the purpose of minimizing HTTP traffic and distinguishing between multiple Google accounts a user might be signed into.
         */
        cookiepolicy?: string;
        /**
         * A function in the global namespace, which is called when the sign-in button is rendered and also called after a sign-in flow completes.
         */
        callback?: () => void;
        /**
         * If true, all previously granted scopes remain granted in each incremental request, for incremental authorization. The default value true is correct for most use cases; use false only if employing delegated auth, where you pass the bearer token to a less-trusted component with lower programmatic authority.
         */
        includegrantedscopes?: boolean;
        /**
         * If your app will write moments, list the full URI of the types of moments that you intend to write.
         */
        requestvisibleactions?: any;
        /**
         * The OAuth 2.0 scopes for the APIs that you would like to use as a space-delimited list.
         */
        scope?: any;
        /**
         * If you have an Android app, you can drive automatic Android downloads from your web sign-in flow.
         */
        apppackagename?: string;
    }*/
        params);

/// Signs a user out of your app without logging the user out of Google. This method will only work when the user is signed in with Google+ Sign-In.
@JS("gapi.auth.signOut")
external void signOut();
// End module gapi.auth

// Module gapi.client
@anonymous
@JS()
abstract class RequestOptions {
  /// The URL to handle the request
  external String get path;
  external set path(String v);

  /// The HTTP request method to use. Default is GET
  external String get method;
  external set method(String v);

  /// URL params in key-value pair form
  external dynamic get params;
  external set params(dynamic v);

  /// Additional HTTP request headers
  external dynamic get headers;
  external set headers(dynamic v);

  /// The HTTP request body (applies to PUT or POST).
  external dynamic get body;
  external set body(dynamic v);

  /// If supplied, the request is executed immediately and no gapi.client.HttpRequest object is returned
  external dynamic Function() get callback;
  external set callback(dynamic Function() v);
  external factory RequestOptions(
      {String path,
      String method,
      dynamic params,
      dynamic headers,
      dynamic body,
      dynamic Function() callback});
}

@anonymous
@JS()
abstract class _RequestOptions {
  @JS("gapi.client.init")
  external Promise<void> client_init(
      dynamic
          /*{
        /**
         * The API Key to use.
         */
        apiKey?: string;
        /**
         * An array of discovery doc URLs or discovery doc JSON objects.
         */
        discoveryDocs?: string[];
        /**
         * The app's client ID, found and created in the Google Developers Console.
         */
        clientId?: string;
        /**
         * The scopes to request, as a space-delimited string.
         */
        scope?: string,

        hosted_domain?: string;
    }*/
          args);
}

extension RequestOptionsExtensions on RequestOptions {}

@anonymous
@JS()
abstract class TokenObject {
  /// The access token to use in requests.
  external String get access_token;
  external set access_token(String v);
  external factory TokenObject({String access_token});
}

/// Creates a HTTP request for making RESTful requests.
/// An object encapsulating the various arguments for this method.
@JS("gapi.client.request")
external HttpRequest<dynamic> request(RequestOptions args);

/// Creates an RPC Request directly. The method name and version identify the method to be executed and the RPC params are provided upon RPC creation.
@JS("gapi.client.rpcRequest")
external RpcRequest rpcRequest(String method,
    [String version, dynamic rpcParams]);

/// Sets the API key for the application.
@JS("gapi.client.setApiKey")
external void setApiKey(String apiKey);

/// Retrieves the OAuth 2.0 token for the application.
@JS("gapi.client.getToken")
external GoogleApiOAuth2TokenObject client_getToken();

/// Sets the authentication token to use in requests.
/// Reference: https://developers.google.com/api-client-library/javascript/reference/referencedocs#gapiclientsettokentokenobject
@JS("gapi.client.setToken")
external void client_setToken(TokenObject /*TokenObject|Null*/ token);

@anonymous
@JS()
abstract class HttpRequestFulfilled<T> {
  external T get result;
  external set result(T v);
  external String get body;
  external set body(String v);
  external List<dynamic> get headers;
  external set headers(List<dynamic> v);
  external num get status;
  external set status(num v);
  external String get statusText;
  external set statusText(String v);
  external factory HttpRequestFulfilled(
      {T result,
      String body,
      List<dynamic> headers,
      num status,
      String statusText});
}

@anonymous
@JS()
abstract class _HttpRequestFulfilled<T> {
  /*external Promise<void> client_load(String name, String version);*/
  /*external void client_load(String name, String version, dynamic callback(),
    [String url]);
*/
  @JS("gapi.client.load")
  external dynamic /*Promise<void>|void*/ client_load(
      String name, String version,
      [dynamic callback(), String url]);
}

extension HttpRequestFulfilledExtensions<T> on HttpRequestFulfilled<T> {}

@anonymous
@JS()
abstract class HttpRequestRejected {
  external dynamic /*dynamic|bool*/ get result;
  external set result(dynamic /*dynamic|bool*/ v);
  external String get body;
  external set body(String v);
  external List<dynamic> get headers;
  external set headers(List<dynamic> v);
  external num get status;
  external set status(num v);
  external String get statusText;
  external set statusText(String v);
  external factory HttpRequestRejected(
      {dynamic /*dynamic|bool*/ result,
      String body,
      List<dynamic> headers,
      num status,
      String statusText});
}

/// HttpRequest supports promises.
/// See Google API Client JavaScript Using Promises https://developers.google.com/api-client-library/javascript/features/promises
@JS("gapi.client.HttpRequestPromise")
class HttpRequestPromise<T> {}

@JS("gapi.client.HttpRequestPromise")
abstract class _HttpRequestPromise<T> {
  /// Taken and adapted from https://github.com/Microsoft/TypeScript/blob/v2.3.1/lib/lib.es5.d.ts#L1343
  external Promise<dynamic /*TResult1|TResult2*/ > then/*<TResult1, TResult2>*/(
      [dynamic /*TResult1|PromiseLike<TResult1> Function(HttpRequestFulfilled<T>)|dynamic|Null*/ onfulfilled,
      dynamic /*TResult2|PromiseLike<TResult2> Function(HttpRequestRejected)|dynamic|Null*/ onrejected,
      dynamic opt_context]);
}

extension HttpRequestPromiseExtensions<T> on HttpRequestPromise<T> {
  Future<dynamic /*TResult1|TResult2*/ > then(
      [dynamic /*TResult1|PromiseLike<TResult1> Function(HttpRequestFulfilled<T>)|dynamic|Null*/ onfulfilled,
      dynamic /*TResult2|PromiseLike<TResult2> Function(HttpRequestRejected)|dynamic|Null*/ onrejected,
      dynamic opt_context]) {
    final Object t = this;
    final _HttpRequestPromise<T> tt = t;
    return promiseToFuture(tt.then(onfulfilled, onrejected, opt_context));
  }
}

/// An object encapsulating an HTTP request. This object is not instantiated directly, rather it is returned by gapi.client.request.
@JS("gapi.client.HttpRequest")
class HttpRequest<T> extends HttpRequestPromise<T> {
  /// Executes the request and runs the supplied callback on response.
  external void execute(
      dynamic callback(

          /// contains the response parsed as JSON. If the response is not JSON, this field will be false.
          T jsonResp,

          /// is the HTTP response. It is JSON, and can be parsed to an object
          dynamic
              /*{
                body: string;
                headers: any[];
                status: number;
                statusText: string;
            }*/
              rawResp));
}

/// Represents an HTTP Batch operation. Individual HTTP requests are added with the add method and the batch is executed using execute.
@JS("gapi.client.HttpBatch")
class HttpBatch {
  /// Adds a gapi.client.HttpRequest to the batch.
  external void add(HttpRequest<dynamic> httpRequest,
      [dynamic
          /*{
            /**
             * Identifies the response for this request in the map of batch responses. If one is not provided, the system generates a random ID.
             */
            id: string;
            callback: (
                /**
                 * is the response for this request only. Its format is defined by the API method being called.
                 */
                individualResponse: any,
                /**
                 * is the raw batch ID-response map as a string. It contains all responses to all requests in the batch.
                 */
                rawBatchResponse: any
                ) => any
        }*/
          opt_params]);

  /// Executes all requests in the batch. The supplied callback is executed on success or failure.
  external void execute(
      dynamic callback(

          /// is an ID-response map of each requests response.
          dynamic responseMap,

          /// is the same response, but as an unparsed JSON-string.
          String rawBatchResponse));
}

/// Similar to gapi.client.HttpRequest except this object encapsulates requests generated by registered methods.
@JS("gapi.client.RpcRequest")
class RpcRequest {
  /// Executes the request and runs the supplied callback with the response.
  external void callback(
      void callback(

          /// contains the response parsed as JSON. If the response is not JSON, this field will be false.
          dynamic jsonResp,

          /// is the same as jsonResp, except it is a raw string that has not been parsed. It is typically used when the response is not JSON.
          String rawResp));
}

// End module gapi.client
@JS()
abstract class Promise<T> {
  external factory Promise(
      void executor(void resolve(T result), Function reject));
  external Promise then(void onFulfilled(T result), [Function onRejected]);
}
