// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesignin;

import android.accounts.Account;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import com.google.android.gms.auth.GoogleAuthUtil;
import com.google.android.gms.auth.UserRecoverableAuthException;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.GoogleSignInStatusCodes;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.RuntimeExecutionException;
import com.google.android.gms.tasks.Task;
import com.google.common.base.Joiner;
import com.google.common.base.Strings;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

/** Google sign-in plugin for Flutter. */
public class GoogleSignInPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {
  private static final String CHANNEL_NAME = "plugins.flutter.io/google_sign_in_android";

  private static final String METHOD_INIT = "init";
  private static final String METHOD_SIGN_IN_SILENTLY = "signInSilently";
  private static final String METHOD_SIGN_IN = "signIn";
  private static final String METHOD_GET_TOKENS = "getTokens";
  private static final String METHOD_SIGN_OUT = "signOut";
  private static final String METHOD_DISCONNECT = "disconnect";
  private static final String METHOD_IS_SIGNED_IN = "isSignedIn";
  private static final String METHOD_CLEAR_AUTH_CACHE = "clearAuthCache";
  private static final String METHOD_REQUEST_SCOPES = "requestScopes";

  private Delegate delegate;
  private MethodChannel channel;
  private ActivityPluginBinding activityPluginBinding;

  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    GoogleSignInPlugin instance = new GoogleSignInPlugin();
    instance.initInstance(registrar.messenger(), registrar.context(), new GoogleSignInWrapper());
    instance.setUpRegistrar(registrar);
  }

  @VisibleForTesting
  public void initInstance(
      BinaryMessenger messenger, Context context, GoogleSignInWrapper googleSignInWrapper) {
    channel = new MethodChannel(messenger, CHANNEL_NAME);
    delegate = new Delegate(context, googleSignInWrapper);
    channel.setMethodCallHandler(this);
  }

  @VisibleForTesting
  @SuppressWarnings("deprecation")
  public void setUpRegistrar(PluginRegistry.Registrar registrar) {
    delegate.setUpRegistrar(registrar);
  }

  private void dispose() {
    delegate = null;
    channel.setMethodCallHandler(null);
    channel = null;
  }

  private void attachToActivity(ActivityPluginBinding activityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding;
    activityPluginBinding.addActivityResultListener(delegate);
    delegate.setActivity(activityPluginBinding.getActivity());
  }

  private void disposeActivity() {
    activityPluginBinding.removeActivityResultListener(delegate);
    delegate.setActivity(null);
    activityPluginBinding = null;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    initInstance(
        binding.getBinaryMessenger(), binding.getApplicationContext(), new GoogleSignInWrapper());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    dispose();
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    attachToActivity(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    disposeActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    attachToActivity(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivity() {
    disposeActivity();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case METHOD_INIT:
        String signInOption = call.argument("signInOption");
        List<String> requestedScopes = call.argument("scopes");
        String hostedDomain = call.argument("hostedDomain");
        String clientId = call.argument("clientId");
        String serverClientId = call.argument("serverClientId");
        boolean forceCodeForRefreshToken = call.argument("forceCodeForRefreshToken");
        delegate.init(
            result,
            signInOption,
            requestedScopes,
            hostedDomain,
            clientId,
            serverClientId,
            forceCodeForRefreshToken);
        break;

      case METHOD_SIGN_IN_SILENTLY:
        delegate.signInSilently(result);
        break;

      case METHOD_SIGN_IN:
        delegate.signIn(result);
        break;

      case METHOD_GET_TOKENS:
        String email = call.argument("email");
        boolean shouldRecoverAuth = call.argument("shouldRecoverAuth");
        delegate.getTokens(result, email, shouldRecoverAuth);
        break;

      case METHOD_SIGN_OUT:
        delegate.signOut(result);
        break;

      case METHOD_CLEAR_AUTH_CACHE:
        String token = call.argument("token");
        delegate.clearAuthCache(result, token);
        break;

      case METHOD_DISCONNECT:
        delegate.disconnect(result);
        break;

      case METHOD_IS_SIGNED_IN:
        delegate.isSignedIn(result);
        break;

      case METHOD_REQUEST_SCOPES:
        List<String> scopes = call.argument("scopes");
        delegate.requestScopes(result, scopes);
        break;

      default:
        result.notImplemented();
    }
  }

  /**
   * A delegate interface that exposes all of the sign-in functionality for other plugins to use.
   * The below {@link Delegate} implementation should be used by any clients unless they need to
   * override some of these functions, such as for testing.
   */
  public interface IDelegate {
    /** Initializes this delegate so that it is ready to perform other operations. */
    public void init(
        Result result,
        String signInOption,
        List<String> requestedScopes,
        String hostedDomain,
        String clientId,
        String serverClientId,
        boolean forceCodeForRefreshToken);

    /**
     * Returns the account information for the user who is signed in to this app. If no user is
     * signed in, tries to sign the user in without displaying any user interface.
     */
    public void signInSilently(Result result);

    /**
     * Signs the user in via the sign-in user interface, including the OAuth consent flow if scopes
     * were requested.
     */
    public void signIn(Result result);

    /**
     * Gets an OAuth access token with the scopes that were specified during initialization for the
     * user with the specified email address.
     *
     * <p>If shouldRecoverAuth is set to true and user needs to recover authentication for method to
     * complete, the method will attempt to recover authentication and rerun method.
     */
    public void getTokens(final Result result, final String email, final boolean shouldRecoverAuth);

    /**
     * Clears the token from any client cache forcing the next {@link #getTokens} call to fetch a
     * new one.
     */
    public void clearAuthCache(final Result result, final String token);

    /**
     * Signs the user out. Their credentials may remain valid, meaning they'll be able to silently
     * sign back in.
     */
    public void signOut(Result result);

    /** Signs the user out, and revokes their credentials. */
    public void disconnect(Result result);

    /** Checks if there is a signed in user. */
    public void isSignedIn(Result result);

    /** Prompts the user to grant an additional Oauth scopes. */
    public void requestScopes(final Result result, final List<String> scopes);
  }

  /**
   * Delegate class that does the work for the Google sign-in plugin. This is exposed as a dedicated
   * class for use in other plugins that wrap basic sign-in functionality.
   *
   * <p>All methods in this class assume that they are run to completion before any other method is
   * invoked. In this context, "run to completion" means that their {@link Result} argument has been
   * completed (either successfully or in error). This class provides no synchronization constructs
   * to guarantee such behavior; callers are responsible for providing such guarantees.
   */
  public static class Delegate implements IDelegate, PluginRegistry.ActivityResultListener {
    private static final int REQUEST_CODE_SIGNIN = 53293;
    private static final int REQUEST_CODE_RECOVER_AUTH = 53294;
    @VisibleForTesting static final int REQUEST_CODE_REQUEST_SCOPE = 53295;

    private static final String ERROR_REASON_EXCEPTION = "exception";
    private static final String ERROR_REASON_STATUS = "status";
    // These error codes must match with ones declared on iOS and Dart sides.
    private static final String ERROR_REASON_SIGN_IN_CANCELED = "sign_in_canceled";
    private static final String ERROR_REASON_SIGN_IN_REQUIRED = "sign_in_required";
    private static final String ERROR_REASON_NETWORK_ERROR = "network_error";
    private static final String ERROR_REASON_SIGN_IN_FAILED = "sign_in_failed";
    private static final String ERROR_FAILURE_TO_RECOVER_AUTH = "failed_to_recover_auth";
    private static final String ERROR_USER_RECOVERABLE_AUTH = "user_recoverable_auth";

    private static final String DEFAULT_SIGN_IN = "SignInOption.standard";
    private static final String DEFAULT_GAMES_SIGN_IN = "SignInOption.games";

    private final Context context;
    // Only set registrar for v1 embedder.
    @SuppressWarnings("deprecation")
    private PluginRegistry.Registrar registrar;
    // Only set activity for v2 embedder. Always access activity from getActivity() method.
    private Activity activity;
    private final BackgroundTaskRunner backgroundTaskRunner = new BackgroundTaskRunner(1);
    private final GoogleSignInWrapper googleSignInWrapper;

    private GoogleSignInClient signInClient;
    private List<String> requestedScopes;
    private PendingOperation pendingOperation;

    public Delegate(Context context, GoogleSignInWrapper googleSignInWrapper) {
      this.context = context;
      this.googleSignInWrapper = googleSignInWrapper;
    }

    @SuppressWarnings("deprecation")
    public void setUpRegistrar(PluginRegistry.Registrar registrar) {
      this.registrar = registrar;
      registrar.addActivityResultListener(this);
    }

    public void setActivity(Activity activity) {
      this.activity = activity;
    }

    // Only access activity with this method.
    public Activity getActivity() {
      return registrar != null ? registrar.activity() : activity;
    }

    private void checkAndSetPendingOperation(String method, Result result) {
      checkAndSetPendingOperation(method, result, null);
    }

    private void checkAndSetPendingOperation(String method, Result result, Object data) {
      if (pendingOperation != null) {
        throw new IllegalStateException(
            "Concurrent operations detected: " + pendingOperation.method + ", " + method);
      }
      pendingOperation = new PendingOperation(method, result, data);
    }

    /**
     * Initializes this delegate so that it is ready to perform other operations. The Dart code
     * guarantees that this will be called and completed before any other methods are invoked.
     */
    @Override
    public void init(
        Result result,
        String signInOption,
        List<String> requestedScopes,
        String hostedDomain,
        String clientId,
        String serverClientId,
        boolean forceCodeForRefreshToken) {
      try {
        GoogleSignInOptions.Builder optionsBuilder;

        switch (signInOption) {
          case DEFAULT_GAMES_SIGN_IN:
            optionsBuilder =
                new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN);
            break;
          case DEFAULT_SIGN_IN:
            optionsBuilder =
                new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).requestEmail();
            break;
          default:
            throw new IllegalStateException("Unknown signInOption");
        }

        // The clientId parameter is not supported on Android.
        // Android apps are identified by their package name and the SHA-1 of their signing key.
        // https://developers.google.com/android/guides/client-auth
        // https://developers.google.com/identity/sign-in/android/start#configure-a-google-api-project
        if (!Strings.isNullOrEmpty(clientId) && Strings.isNullOrEmpty(serverClientId)) {
          Log.w(
              "google_sign_in",
              "clientId is not supported on Android and is interpreted as serverClientId. "
                  + "Use serverClientId instead to suppress this warning.");
          serverClientId = clientId;
        }

        if (Strings.isNullOrEmpty(serverClientId)) {
          // Only requests a clientId if google-services.json was present and parsed
          // by the google-services Gradle script.
          // TODO(jackson): Perhaps we should provide a mechanism to override this
          // behavior.
          int webClientIdIdentifier =
              context
                  .getResources()
                  .getIdentifier("default_web_client_id", "string", context.getPackageName());
          if (webClientIdIdentifier != 0) {
            serverClientId = context.getString(webClientIdIdentifier);
          }
        }
        if (!Strings.isNullOrEmpty(serverClientId)) {
          optionsBuilder.requestIdToken(serverClientId);
          optionsBuilder.requestServerAuthCode(serverClientId, forceCodeForRefreshToken);
        }
        for (String scope : requestedScopes) {
          optionsBuilder.requestScopes(new Scope(scope));
        }
        if (!Strings.isNullOrEmpty(hostedDomain)) {
          optionsBuilder.setHostedDomain(hostedDomain);
        }

        this.requestedScopes = requestedScopes;
        signInClient = googleSignInWrapper.getClient(context, optionsBuilder.build());
        result.success(null);
      } catch (Exception e) {
        result.error(ERROR_REASON_EXCEPTION, e.getMessage(), null);
      }
    }

    /**
     * Returns the account information for the user who is signed in to this app. If no user is
     * signed in, tries to sign the user in without displaying any user interface.
     */
    @Override
    public void signInSilently(Result result) {
      checkAndSetPendingOperation(METHOD_SIGN_IN_SILENTLY, result);
      Task<GoogleSignInAccount> task = signInClient.silentSignIn();
      if (task.isSuccessful()) {
        // There's immediate result available.
        onSignInAccount(task.getResult());
      } else {
        task.addOnCompleteListener(
            new OnCompleteListener<GoogleSignInAccount>() {
              @Override
              public void onComplete(Task<GoogleSignInAccount> task) {
                onSignInResult(task);
              }
            });
      }
    }

    /**
     * Signs the user in via the sign-in user interface, including the OAuth consent flow if scopes
     * were requested.
     */
    @Override
    public void signIn(Result result) {
      if (getActivity() == null) {
        throw new IllegalStateException("signIn needs a foreground activity");
      }
      checkAndSetPendingOperation(METHOD_SIGN_IN, result);

      Intent signInIntent = signInClient.getSignInIntent();
      getActivity().startActivityForResult(signInIntent, REQUEST_CODE_SIGNIN);
    }

    /**
     * Signs the user out. Their credentials may remain valid, meaning they'll be able to silently
     * sign back in.
     */
    @Override
    public void signOut(Result result) {
      checkAndSetPendingOperation(METHOD_SIGN_OUT, result);

      signInClient
          .signOut()
          .addOnCompleteListener(
              new OnCompleteListener<Void>() {
                @Override
                public void onComplete(Task<Void> task) {
                  if (task.isSuccessful()) {
                    finishWithSuccess(null);
                  } else {
                    finishWithError(ERROR_REASON_STATUS, "Failed to signout.");
                  }
                }
              });
    }

    /** Signs the user out, and revokes their credentials. */
    @Override
    public void disconnect(Result result) {
      checkAndSetPendingOperation(METHOD_DISCONNECT, result);

      signInClient
          .revokeAccess()
          .addOnCompleteListener(
              new OnCompleteListener<Void>() {
                @Override
                public void onComplete(Task<Void> task) {
                  if (task.isSuccessful()) {
                    finishWithSuccess(null);
                  } else {
                    finishWithError(ERROR_REASON_STATUS, "Failed to disconnect.");
                  }
                }
              });
    }

    /** Checks if there is a signed in user. */
    @Override
    public void isSignedIn(final Result result) {
      boolean value = GoogleSignIn.getLastSignedInAccount(context) != null;
      result.success(value);
    }

    @Override
    public void requestScopes(Result result, List<String> scopes) {
      checkAndSetPendingOperation(METHOD_REQUEST_SCOPES, result);

      GoogleSignInAccount account = googleSignInWrapper.getLastSignedInAccount(context);
      if (account == null) {
        finishWithError(ERROR_REASON_SIGN_IN_REQUIRED, "No account to grant scopes.");
        return;
      }

      List<Scope> wrappedScopes = new ArrayList<>();

      for (String scope : scopes) {
        Scope wrappedScope = new Scope(scope);
        if (!googleSignInWrapper.hasPermissions(account, wrappedScope)) {
          wrappedScopes.add(wrappedScope);
        }
      }

      if (wrappedScopes.isEmpty()) {
        finishWithSuccess(true);
        return;
      }

      googleSignInWrapper.requestPermissions(
          getActivity(), REQUEST_CODE_REQUEST_SCOPE, account, wrappedScopes.toArray(new Scope[0]));
    }

    private void onSignInResult(Task<GoogleSignInAccount> completedTask) {
      try {
        GoogleSignInAccount account = completedTask.getResult(ApiException.class);
        onSignInAccount(account);
      } catch (ApiException e) {
        // Forward all errors and let Dart side decide how to handle.
        String errorCode = errorCodeForStatus(e.getStatusCode());
        finishWithError(errorCode, e.toString());
      } catch (RuntimeExecutionException e) {
        finishWithError(ERROR_REASON_EXCEPTION, e.toString());
      }
    }

    private void onSignInAccount(GoogleSignInAccount account) {
      Map<String, Object> response = new HashMap<>();
      response.put("email", account.getEmail());
      response.put("id", account.getId());
      response.put("idToken", account.getIdToken());
      response.put("serverAuthCode", account.getServerAuthCode());
      response.put("displayName", account.getDisplayName());
      if (account.getPhotoUrl() != null) {
        response.put("photoUrl", account.getPhotoUrl().toString());
      }
      finishWithSuccess(response);
    }

    private String errorCodeForStatus(int statusCode) {
      if (statusCode == GoogleSignInStatusCodes.SIGN_IN_CANCELLED) {
        return ERROR_REASON_SIGN_IN_CANCELED;
      } else if (statusCode == CommonStatusCodes.SIGN_IN_REQUIRED) {
        return ERROR_REASON_SIGN_IN_REQUIRED;
      } else if (statusCode == CommonStatusCodes.NETWORK_ERROR) {
        return ERROR_REASON_NETWORK_ERROR;
      } else {
        return ERROR_REASON_SIGN_IN_FAILED;
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
      final Object data;

      PendingOperation(String method, Result result, Object data) {
        this.method = method;
        this.result = result;
        this.data = data;
      }
    }

    /** Clears the token kept in the client side cache. */
    @Override
    public void clearAuthCache(final Result result, final String token) {
      Callable<Void> clearTokenTask =
          new Callable<Void>() {
            @Override
            public Void call() throws Exception {
              GoogleAuthUtil.clearToken(context, token);
              return null;
            }
          };

      backgroundTaskRunner.runInBackground(
          clearTokenTask,
          new BackgroundTaskRunner.Callback<Void>() {
            @Override
            public void run(Future<Void> clearTokenFuture) {
              try {
                result.success(clearTokenFuture.get());
              } catch (ExecutionException e) {
                result.error(ERROR_REASON_EXCEPTION, e.getCause().getMessage(), null);
              } catch (InterruptedException e) {
                result.error(ERROR_REASON_EXCEPTION, e.getMessage(), null);
                Thread.currentThread().interrupt();
              }
            }
          });
    }

    /**
     * Gets an OAuth access token with the scopes that were specified during initialization for the
     * user with the specified email address.
     *
     * <p>If shouldRecoverAuth is set to true and user needs to recover authentication for method to
     * complete, the method will attempt to recover authentication and rerun method.
     */
    @Override
    public void getTokens(
        final Result result, final String email, final boolean shouldRecoverAuth) {
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
              return GoogleAuthUtil.getToken(context, account, scopesStr);
            }
          };

      // Background task runner has a single thread effectively serializing
      // the getToken calls. 1p apps can then enjoy the token cache if multiple
      // getToken calls are coming in.
      backgroundTaskRunner.runInBackground(
          getTokenTask,
          new BackgroundTaskRunner.Callback<String>() {
            @Override
            public void run(Future<String> tokenFuture) {
              try {
                String token = tokenFuture.get();
                HashMap<String, String> tokenResult = new HashMap<>();
                tokenResult.put("accessToken", token);
                result.success(tokenResult);
              } catch (ExecutionException e) {
                if (e.getCause() instanceof UserRecoverableAuthException) {
                  if (shouldRecoverAuth && pendingOperation == null) {
                    Activity activity = getActivity();
                    if (activity == null) {
                      result.error(
                          ERROR_USER_RECOVERABLE_AUTH,
                          "Cannot recover auth because app is not in foreground. "
                              + e.getLocalizedMessage(),
                          null);
                    } else {
                      checkAndSetPendingOperation(METHOD_GET_TOKENS, result, email);
                      Intent recoveryIntent =
                          ((UserRecoverableAuthException) e.getCause()).getIntent();
                      activity.startActivityForResult(recoveryIntent, REQUEST_CODE_RECOVER_AUTH);
                    }
                  } else {
                    result.error(ERROR_USER_RECOVERABLE_AUTH, e.getLocalizedMessage(), null);
                  }
                } else {
                  result.error(ERROR_REASON_EXCEPTION, e.getCause().getMessage(), null);
                }
              } catch (InterruptedException e) {
                result.error(ERROR_REASON_EXCEPTION, e.getMessage(), null);
                Thread.currentThread().interrupt();
              }
            }
          });
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
      if (pendingOperation == null) {
        return false;
      }
      switch (requestCode) {
        case REQUEST_CODE_RECOVER_AUTH:
          if (resultCode == Activity.RESULT_OK) {
            // Recover the previous result and data and attempt to get tokens again.
            Result result = pendingOperation.result;
            String email = (String) pendingOperation.data;
            pendingOperation = null;
            getTokens(result, email, false);
          } else {
            finishWithError(
                ERROR_FAILURE_TO_RECOVER_AUTH, "Failed attempt to recover authentication");
          }
          return true;
        case REQUEST_CODE_SIGNIN:
          // Whether resultCode is OK or not, the Task returned by GoogleSigIn will determine
          // failure with better specifics which are extracted in onSignInResult method.
          if (data != null) {
            onSignInResult(GoogleSignIn.getSignedInAccountFromIntent(data));
          } else {
            // data is null which is highly unusual for a sign in result.
            finishWithError(ERROR_REASON_SIGN_IN_FAILED, "Signin failed");
          }
          return true;
        case REQUEST_CODE_REQUEST_SCOPE:
          finishWithSuccess(resultCode == Activity.RESULT_OK);
          return true;
        default:
          return false;
      }
    }
  }
}
