// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.googlesignin;

import android.accounts.Account;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import com.google.android.gms.auth.GoogleAuthUtil;
import com.google.android.gms.auth.api.Auth;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.GoogleSignInResult;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.OptionalPendingResult;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.common.api.Status;
import com.google.common.base.Joiner;
import com.google.common.base.Preconditions;
import com.google.common.base.Strings;
import io.flutter.app.FlutterFragmentActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

/** Google sign-in plugin for Flutter. */
public class GoogleSignInPlugin
    implements MethodCallHandler,
        PluginRegistry.ActivityResultListener,
        GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener {

  private static final int REQUEST_CODE = 53293;

  private static final String CHANNEL_NAME = "plugins.flutter.io/google_sign_in";

  private static final String TAG = "flutter";

  private static final String ERROR_REASON_EXCEPTION = "exception";
  private static final String ERROR_REASON_STATUS = "status";
  private static final String ERROR_REASON_CANCELED = "canceled";
  private static final String ERROR_REASON_OPERATION_IN_PROGRESS = "operation_in_progress";
  private static final String ERROR_REASON_CONNECTION_FAILED = "connection_failed";

  private static final String METHOD_INIT = "init";
  private static final String METHOD_SIGN_IN_SILENTLY = "signInSilently";
  private static final String METHOD_SIGN_IN = "signIn";
  private static final String METHOD_GET_TOKENS = "getTokens";
  private static final String METHOD_SIGN_OUT = "signOut";
  private static final String METHOD_DISCONNECT = "disconnect";

  private static final class PendingOperation {

    final String method;
    final Queue<Result> resultQueue = new LinkedList<>();

    PendingOperation(String method, Result result) {
      this.method = Preconditions.checkNotNull(method);
      resultQueue.add(Preconditions.checkNotNull(result));
    }
  }

  private final FragmentActivity activity;
  private final BackgroundTaskRunner backgroundTaskRunner;
  private final int requestCode;

  private GoogleApiClient googleApiClient;
  private List<String> requestedScopes;
  private PendingOperation pendingOperation;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    Activity activity = registrar.activity();
    if (!(activity instanceof FragmentActivity)) {
      throw new IllegalArgumentException(
          GoogleSignInPlugin.class.getSimpleName()
              + " requires your activity to be an instance of "
              + FragmentActivity.class.getName()
              + ". You may want to use "
              + FlutterFragmentActivity.class.getName());
    }
    FragmentActivity fragmentActivity = (FragmentActivity) activity;
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    final GoogleSignInPlugin instance =
        new GoogleSignInPlugin(fragmentActivity, new BackgroundTaskRunner(1), REQUEST_CODE);
    registrar.addActivityResultListener(instance);
    channel.setMethodCallHandler(instance);
  }

  private GoogleSignInPlugin(
      FragmentActivity activity, BackgroundTaskRunner backgroundTaskRunner, int requestCode) {
    this.activity = activity;
    this.backgroundTaskRunner = backgroundTaskRunner;
    this.requestCode = requestCode;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case METHOD_INIT:
        List<String> requestedScopes = call.argument("scopes");
        String hostedDomain = call.argument("hostedDomain");
        init(result, requestedScopes, hostedDomain);
        break;

      case METHOD_SIGN_IN_SILENTLY:
        signInSilently(result);
        break;

      case METHOD_SIGN_IN:
        signIn(result);
        break;

      case METHOD_GET_TOKENS:
        String email = call.argument("email");
        getTokens(result, email);
        break;

      case METHOD_SIGN_OUT:
        signOut(result);
        break;

      case METHOD_DISCONNECT:
        disconnect(result);
        break;

      default:
        result.notImplemented();
    }
  }

  /**
   * Initializes this listener so that it is ready to perform other operations. The Dart code
   * guarantees that this will be called and completed before any other methods are invoked.
   */
  private void init(Result result, List<String> requestedScopes, String hostedDomain) {
    try {
      if (googleApiClient != null) {
        // This can happen if the scopes change, or a full restart hot reload
        googleApiClient.stopAutoManage(activity);
        googleApiClient = null;
      }
      GoogleSignInOptions.Builder optionsBuilder =
          new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).requestEmail();
      // Only requests a clientId if google-services.json was present and parsed
      // by the google-services Gradle script.
      // TODO(jackson): Perhaps we should provide a mechanism to override this
      // behavior.
      int clientIdIdentifier =
          activity
              .getResources()
              .getIdentifier("default_web_client_id", "string", activity.getPackageName());
      if (clientIdIdentifier != 0) {
        optionsBuilder.requestIdToken(activity.getString(clientIdIdentifier));
      }
      for (String scope : requestedScopes) {
        optionsBuilder.requestScopes(new Scope(scope));
      }
      if (!Strings.isNullOrEmpty(hostedDomain)) {
        optionsBuilder.setHostedDomain(hostedDomain);
      }

      this.requestedScopes = requestedScopes;
      this.googleApiClient =
          new GoogleApiClient.Builder(activity)
              .enableAutoManage(activity, this)
              .addApi(Auth.GOOGLE_SIGN_IN_API, optionsBuilder.build())
              .addConnectionCallbacks(this)
              .addOnConnectionFailedListener(this)
              .build();
    } catch (Exception e) {
      Log.e(TAG, "Initialization error", e);
      result.error(ERROR_REASON_EXCEPTION, e.getMessage(), null);
    }

    // We're not initialized until we receive `onConnected`.
    // If initialization fails, we'll receive `onConnectionFailed`
    pendingOperation = new PendingOperation(METHOD_INIT, result);
  }

  /**
   * Handles the case of a concurrent operation already in progress.
   *
   * <p>Only one type of operation is allowed to be executed at a time, so if there's a pending
   * operation for a method type other than the current invocation, this will report failure on the
   * specified result object. Alternatively, if there's a pending operation for the same method
   * type, this will signal that the method is already being handled and add the specified result to
   * the pending operation's result queue.
   *
   * <p>If there's no pending operation, this method will set the pending operation to the current
   * invocation.
   *
   * @param currentMethod The current invocation.
   * @param result receives the result of the current invocation.
   * @return true iff an operation is already in progress (and thus the response is already being
   *     handled).
   */
  private boolean checkAndSetPendingOperation(String currentMethod, Result result) {
    if (pendingOperation == null) {
      pendingOperation = new PendingOperation(currentMethod, result);
      return false;
    }

    if (pendingOperation.method.equals(currentMethod)) {
      // This method is already being handled
      pendingOperation.resultQueue.add(result);
    } else {
      // Only one type of operation can be in progress at a time
      result.error(ERROR_REASON_OPERATION_IN_PROGRESS, pendingOperation.method, null);
    }

    return true;
  }

  /**
   * Returns the account information for the user who is signed in to this app. If no user is signed
   * in, tries to sign the user in without displaying any user interface.
   */
  private void signInSilently(Result result) {
    if (checkAndSetPendingOperation(METHOD_SIGN_IN, result)) {
      return;
    }

    OptionalPendingResult<GoogleSignInResult> pendingResult =
        Auth.GoogleSignInApi.silentSignIn(googleApiClient);
    if (pendingResult.isDone()) {
      onSignInResult(pendingResult.get());
    } else {
      pendingResult.setResultCallback(
          new ResultCallback<GoogleSignInResult>() {
            @Override
            public void onResult(@NonNull GoogleSignInResult signInResult) {
              onSignInResult(signInResult);
            }
          });
    }
  }

  /**
   * Signs the user in via the sign-in user interface, including the OAuth consent flow if scopes
   * were requested.
   */
  private void signIn(Result result) {
    if (checkAndSetPendingOperation(METHOD_SIGN_IN, result)) {
      return;
    }

    Intent signInIntent = Auth.GoogleSignInApi.getSignInIntent(googleApiClient);
    activity.startActivityForResult(signInIntent, requestCode);
  }

  /**
   * Gets an OAuth access token with the scopes that were specified during initialization for the
   * user with the specified email address.
   */
  private void getTokens(Result result, final String email) {
    if (email == null) {
      result.error(ERROR_REASON_EXCEPTION, "Email is null", null);
      return;
    }

    if (checkAndSetPendingOperation(METHOD_GET_TOKENS, result)) {
      return;
    }

    Callable<String> getTokenTask =
        new Callable<String>() {
          @Override
          public String call() throws Exception {
            Account account = new Account(email, "com.google");
            String scopesStr = "oauth2:" + Joiner.on(' ').join(requestedScopes);
            return GoogleAuthUtil.getToken(activity.getApplication(), account, scopesStr);
          }
        };

    backgroundTaskRunner.runInBackground(
        getTokenTask,
        new BackgroundTaskRunner.Callback<String>() {
          @Override
          public void run(Future<String> tokenFuture) {
            try {
              String token = tokenFuture.get();
              HashMap<String, String> result = new HashMap<>();
              result.put("accessToken", token);
              // TODO(jackson): If we had a way to get the current user at this
              // point, we could use that to obtain an up-to-date idToken here
              // instead of the value we cached during sign in. At least, that's
              // how it works on iOS.
              finishWithSuccess(result);
            } catch (ExecutionException e) {
              Log.e(TAG, "Exception getting access token", e);
              finishWithError(ERROR_REASON_EXCEPTION, e.getCause().getMessage());
            } catch (InterruptedException e) {
              finishWithError(ERROR_REASON_EXCEPTION, e.getMessage());
              Thread.currentThread().interrupt();
            }
          }
        });
  }

  /**
   * Signs the user out. Their credentials may remain valid, meaning they'll be able to silently
   * sign back in.
   */
  private void signOut(Result result) {
    if (checkAndSetPendingOperation(METHOD_SIGN_OUT, result)) {
      return;
    }

    Auth.GoogleSignInApi.signOut(googleApiClient)
        .setResultCallback(
            new ResultCallback<Status>() {
              @Override
              public void onResult(@NonNull Status status) {
                // TODO(tvolkert): communicate status back to user
                finishWithSuccess(null);
              }
            });
  }

  /** Signs the user out, and revokes their credentials. */
  private void disconnect(Result result) {
    if (checkAndSetPendingOperation(METHOD_DISCONNECT, result)) {
      return;
    }

    Auth.GoogleSignInApi.revokeAccess(googleApiClient)
        .setResultCallback(
            new ResultCallback<Status>() {
              @Override
              public void onResult(@NonNull Status status) {
                // TODO(tvolkert): communicate status back to user
                finishWithSuccess(null);
              }
            });
  }

  /**
   * Invoked when the GMS client has successfully connected to the GMS server. This signals that
   * this listener is properly initialized.
   */
  @Override
  public void onConnected(Bundle connectionHint) {
    // We can get reconnected if, e.g. the activity is paused and resumed.
    if (pendingOperation != null && pendingOperation.method.equals(METHOD_INIT)) {
      finishWithSuccess(null);
    }
  }

  /**
   * Invoked when the GMS client was unable to connect to the GMS server, either because of an error
   * the user was unable to resolve, or because the user canceled the resolution (e.g. cancelling a
   * dialog instructing them to upgrade Google Play Services). This signals that we were unable to
   * properly initialize this listener.
   */
  @Override
  public void onConnectionFailed(@NonNull ConnectionResult result) {
    // We can attempt to reconnect if, e.g. the activity is paused and resumed.
    if (pendingOperation != null && pendingOperation.method.equals(METHOD_INIT)) {
      finishWithError(ERROR_REASON_CONNECTION_FAILED, result.toString());
    }
  }

  @Override
  public void onConnectionSuspended(int cause) {
    // TODO(jackson): implement
    Log.w(TAG, "The GMS server connection has been suspended (" + cause + ")");
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode != this.requestCode) {
      // We're only interested in the "sign in" activity result
      return false;
    }

    if (pendingOperation == null || !pendingOperation.method.equals(METHOD_SIGN_IN)) {
      Log.w(TAG, "Unexpected activity result; sign-in not in progress");
      return false;
    }

    if (resultCode != Activity.RESULT_OK) {
      finishWithError(ERROR_REASON_CANCELED, String.valueOf(resultCode));
      return true;
    }

    onSignInResult(Auth.GoogleSignInApi.getSignInResultFromIntent(data));
    return true;
  }

  private void onSignInResult(GoogleSignInResult result) {
    if (result.isSuccess()) {
      GoogleSignInAccount account = result.getSignInAccount();
      Map<String, Object> response = new HashMap<>();
      response.put("displayName", account.getDisplayName());
      response.put("email", account.getEmail());
      response.put("id", account.getId());
      response.put("idToken", account.getIdToken());
      Uri photoUrl = account.getPhotoUrl();
      if (photoUrl != null) {
        response.put("photoUrl", photoUrl.toString());
      }
      finishWithSuccess(response);
    } else if (result.getStatus().getStatusCode() == CommonStatusCodes.SIGN_IN_REQUIRED) {
      finishWithSuccess(null);
    } else {
      finishWithError(ERROR_REASON_STATUS, result.getStatus().toString());
    }
  }

  private void finishWithSuccess(Object data) {
    for (Result result : pendingOperation.resultQueue) {
      result.success(data);
    }
    pendingOperation = null;
  }

  private void finishWithError(String errorCode, String errorMessage) {
    for (Result result : pendingOperation.resultQueue) {
      result.error(errorCode, errorMessage, null);
    }
    pendingOperation = null;
  }
}
