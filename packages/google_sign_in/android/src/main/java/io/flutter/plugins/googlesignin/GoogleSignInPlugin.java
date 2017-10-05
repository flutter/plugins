// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.googlesignin;

import android.accounts.Account;
import android.app.Activity;
import android.app.Application.ActivityLifecycleCallbacks;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentSender.SendIntentException;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;
import com.google.android.gms.auth.GoogleAuthUtil;
import com.google.android.gms.auth.api.Auth;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.GoogleSignInResult;
import com.google.android.gms.auth.api.signin.GoogleSignInStatusCodes;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.OptionalPendingResult;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.common.api.Status;
import com.google.common.base.Joiner;
import com.google.common.base.Strings;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

/** Google sign-in plugin for Flutter. */
public class GoogleSignInPlugin implements MethodCallHandler {
  private static final String CHANNEL_NAME = "plugins.flutter.io/google_sign_in";

  private static final String TAG = "flutter";

  private static final String METHOD_INIT = "init";
  private static final String METHOD_SIGN_IN_SILENTLY = "signInSilently";
  private static final String METHOD_SIGN_IN = "signIn";
  private static final String METHOD_GET_TOKENS = "getTokens";
  private static final String METHOD_SIGN_OUT = "signOut";
  private static final String METHOD_DISCONNECT = "disconnect";

  private final Delegate delegate;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    final GoogleSignInPlugin instance = new GoogleSignInPlugin(registrar);
    channel.setMethodCallHandler(instance);
  }

  private GoogleSignInPlugin(PluginRegistry.Registrar registrar) {
    delegate = new Delegate(registrar);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case METHOD_INIT:
        List<String> requestedScopes = call.argument("scopes");
        String hostedDomain = call.argument("hostedDomain");
        delegate.init(result, requestedScopes, hostedDomain);
        break;

      case METHOD_SIGN_IN_SILENTLY:
        delegate.signInSilently(result);
        break;

      case METHOD_SIGN_IN:
        delegate.signIn(result);
        break;

      case METHOD_GET_TOKENS:
        String email = call.argument("email");
        delegate.getTokens(result, email);
        break;

      case METHOD_SIGN_OUT:
        delegate.signOut(result);
        break;

      case METHOD_DISCONNECT:
        delegate.disconnect(result);
        break;

      default:
        result.notImplemented();
    }
  }

  /**
   * Delegate class that does the work for the Google sign-in plugin. This is exposed as a dedicated
   * class for use in other plugins that wrap basic sign-in functionality.
   *
   * <p>All methods in this class assume that they are run to completion before any other method is
   * invoked. In this context, "run to completion" means that their {@link Result} argument has been
   * completed (either successfully or in error). This class provides no synchronization consructs
   * to guarantee such behavior; callers are responsible for providing such guarantees.
   */
  public static final class Delegate {
    private static final int REQUEST_CODE = 53293;
    private static final int REQUEST_CODE_RESOLVE_ERROR = 1001;

    private static final String ERROR_REASON_EXCEPTION = "exception";
    private static final String ERROR_REASON_STATUS = "status";
    private static final String ERROR_REASON_CONNECTION_FAILED = "connection_failed";

    private static final String STATE_RESOLVING_ERROR = "resolving_error";

    private final Activity activity;
    private final Handler handler = new Handler();
    private final BackgroundTaskRunner backgroundTaskRunner = new BackgroundTaskRunner(1);

    private boolean resolvingError = false; // Whether we are currently resolving a sign-in error
    private GoogleApiClient googleApiClient;
    private List<String> requestedScopes;
    private PendingOperation pendingOperation;
    private volatile GoogleSignInAccount currentAccount;

    public Delegate(PluginRegistry.Registrar registrar) {
      activity = registrar.activity();
      activity.getApplication().registerActivityLifecycleCallbacks(handler);
      registrar.addActivityResultListener(handler);
    }

    /** Returns the most recently signed-in account, or null if there was none. */
    public GoogleSignInAccount getCurrentAccount() {
      return currentAccount;
    }

    private void checkAndSetPendingOperation(String method, Result result) {
      if (pendingOperation != null) {
        throw new IllegalStateException(
            "Concurrent operations detected: " + pendingOperation.method + ", " + method);
      }
      pendingOperation = new PendingOperation(method, result);
    }

    /**
     * Initializes this delegate so that it is ready to perform other operations. The Dart code
     * guarantees that this will be called and completed before any other methods are invoked.
     */
    public void init(Result result, List<String> requestedScopes, String hostedDomain) {
      // We're not initialized until we receive `onConnected`.
      // If initialization fails, we'll receive `onConnectionFailed`
      checkAndSetPendingOperation(METHOD_INIT, result);

      try {
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
        googleApiClient =
            new GoogleApiClient.Builder(activity)
                .addApi(Auth.GOOGLE_SIGN_IN_API, optionsBuilder.build())
                .addConnectionCallbacks(handler)
                .addOnConnectionFailedListener(handler)
                .build();
        googleApiClient.connect();
      } catch (Exception e) {
        Log.e(TAG, "Initialization error", e);
        result.error(ERROR_REASON_EXCEPTION, e.getMessage(), null);
      }
    }

    /**
     * Returns the account information for the user who is signed in to this app. If no user is
     * signed in, tries to sign the user in without displaying any user interface.
     */
    public void signInSilently(Result result) {
      checkAndSetPendingOperation(METHOD_SIGN_IN_SILENTLY, result);

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
    public void signIn(Result result) {
      checkAndSetPendingOperation(METHOD_SIGN_IN, result);

      Intent signInIntent = Auth.GoogleSignInApi.getSignInIntent(googleApiClient);
      activity.startActivityForResult(signInIntent, REQUEST_CODE);
    }

    /**
     * Gets an OAuth access token with the scopes that were specified during initialization for the
     * user with the specified email address.
     */
    public void getTokens(final Result result, final String email) {
      // TODO(issue/11107): Add back the checkAndSetPendingOperation once getTokens is properly
      // gated from Dart code. Change result.success/error calls below to use finishWith()
      if (email == null) {
        result.error(ERROR_REASON_EXCEPTION, "Email is null", null);
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
                HashMap<String, String> tokenResult = new HashMap<>();
                tokenResult.put("accessToken", token);
                // TODO(jackson): If we had a way to get the current user at this
                // point, we could use that to obtain an up-to-date idToken here
                // instead of the value we cached during sign in. At least, that's
                // how it works on iOS.
                result.success(tokenResult);
              } catch (ExecutionException e) {
                Log.e(TAG, "Exception getting access token", e);
                result.error(ERROR_REASON_EXCEPTION, e.getCause().getMessage(), null);
              } catch (InterruptedException e) {
                result.error(ERROR_REASON_EXCEPTION, e.getMessage(), null);
                Thread.currentThread().interrupt();
              }
            }
          });
    }

    /**
     * Signs the user out. Their credentials may remain valid, meaning they'll be able to silently
     * sign back in.
     */
    public void signOut(Result result) {
      checkAndSetPendingOperation(METHOD_SIGN_OUT, result);

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
    public void disconnect(Result result) {
      checkAndSetPendingOperation(METHOD_DISCONNECT, result);

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

    private void onSignInResult(GoogleSignInResult result) {
      if (result.isSuccess()) {
        GoogleSignInAccount account = result.getSignInAccount();
        currentAccount = account;
        Map<String, Object> response = new HashMap<>();
        response.put("email", account.getEmail());
        response.put("id", account.getId());
        response.put("idToken", account.getIdToken());
        response.put("displayName", account.getDisplayName());
        if (account.getPhotoUrl() != null) {
          response.put("photoUrl", account.getPhotoUrl().toString());
        }
        finishWithSuccess(response);
      } else if (result.getStatus().getStatusCode() == CommonStatusCodes.SIGN_IN_REQUIRED
          || result.getStatus().getStatusCode() == GoogleSignInStatusCodes.SIGN_IN_CANCELLED) {
        // This isn't an error from the caller's (Dart's) perspective; this just
        // means that the user didn't sign in.
        finishWithSuccess(null);
      } else {
        finishWithError(ERROR_REASON_STATUS, result.getStatus().toString());
      }
    }

    private void finishWithSuccess(Object data) {
      pendingOperation.result.success(data);
      pendingOperation = null;
    }

    private void finishWithError(String errorCode, String errorMessage) {
      pendingOperation.result.error(errorCode, errorMessage, null);
      pendingOperation = null;
    }

    private static class PendingOperation {
      final String method;
      final Result result;

      PendingOperation(String method, Result result) {
        this.method = method;
        this.result = result;
      }
    }

    private class Handler
        implements ActivityLifecycleCallbacks,
            PluginRegistry.ActivityResultListener,
            GoogleApiClient.ConnectionCallbacks,
            GoogleApiClient.OnConnectionFailedListener {
      @Override
      public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_RESOLVE_ERROR) {
          // Deal with result of `onConnectionFailed` error resolution.
          resolvingError = false;
          if (resultCode == Activity.RESULT_OK) {
            // Make sure the app is not already connected or attempting to connect
            if (!googleApiClient.isConnecting() && !googleApiClient.isConnected()) {
              googleApiClient.connect();
            }
          } else if (pendingOperation != null && pendingOperation.method.equals(METHOD_INIT)) {
            finishWithError(ERROR_REASON_CONNECTION_FAILED, String.valueOf(resultCode));
          }
          return true;
        }

        if (requestCode != REQUEST_CODE) {
          // We're only interested in the "sign in" activity result
          return false;
        }

        if (pendingOperation == null || !pendingOperation.method.equals(METHOD_SIGN_IN)) {
          Log.w(TAG, "Unexpected activity result; sign-in not in progress");
          return false;
        }

        if (data == null) {
          finishWithError(ERROR_REASON_STATUS, "No intent data: " + resultCode);
          return true;
        }

        onSignInResult(Auth.GoogleSignInApi.getSignInResultFromIntent(data));
        return true;
      }

      @Override
      public void onActivityCreated(Activity activity, Bundle bundle) {
        resolvingError = bundle != null && bundle.getBoolean(STATE_RESOLVING_ERROR, false);
      }

      @Override
      public void onActivityDestroyed(Activity activity) {}

      @Override
      public void onActivityPaused(Activity activity) {}

      @Override
      public void onActivityResumed(Activity activity) {}

      @Override
      public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
        outState.putBoolean(STATE_RESOLVING_ERROR, resolvingError);
      }

      @Override
      public void onActivityStarted(Activity activity) {
        if (!resolvingError && activity == Delegate.this.activity && googleApiClient != null) {
          googleApiClient.connect();
        }
      }

      @Override
      public void onActivityStopped(Activity activity) {
        if (activity == Delegate.this.activity && googleApiClient != null) {
          googleApiClient.disconnect();
        }
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
       * Invoked when the GMS client was unable to connect to the GMS server, either because of an
       * error the user was unable to resolve, or because the user canceled the resolution (e.g.
       * cancelling a dialog instructing them to upgrade Google Play Services). This signals that we
       * were unable to properly initialize this listener.
       */
      @Override
      public void onConnectionFailed(@NonNull final ConnectionResult result) {
        if (resolvingError) {
          // Already attempting to resolve an error.
          return;
        } else if (result.hasResolution()) {
          resolvingError = true;
          try {
            result.startResolutionForResult(activity, REQUEST_CODE_RESOLVE_ERROR);
          } catch (SendIntentException e) {
            resolvingError = false;
            finishWithError(ERROR_REASON_CONNECTION_FAILED, String.valueOf(result.getErrorCode()));
          }
        } else {
          resolvingError = true;
          GoogleApiAvailability.getInstance()
              .showErrorDialogFragment(
                  activity,
                  result.getErrorCode(),
                  REQUEST_CODE_RESOLVE_ERROR,
                  new DialogInterface.OnCancelListener() {
                    @Override
                    public void onCancel(DialogInterface dialog) {
                      if (pendingOperation != null && pendingOperation.method.equals(METHOD_INIT)) {
                        finishWithError(
                            ERROR_REASON_CONNECTION_FAILED, String.valueOf(result.getErrorCode()));
                      }
                      resolvingError = false;
                    }
                  });
        }
      }

      @Override
      public void onConnectionSuspended(int cause) {
        // TODO(jackson): implement
        Log.w(TAG, "The GMS server connection has been suspended (" + cause + ")");
      }
    }
  }
}
