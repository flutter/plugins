// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.googlesignin;

import android.accounts.Account;
import android.app.Activity;
import android.content.Intent;
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

  private static final String METHOD_INIT = "init";
  private static final String METHOD_SIGN_IN_SILENTLY = "signInSilently";
  private static final String METHOD_SIGN_IN = "signIn";
  private static final String METHOD_GET_TOKENS = "getTokens";
  private static final String METHOD_SIGN_OUT = "signOut";
  private static final String METHOD_DISCONNECT = "disconnect";
  private static final String METHOD_IS_SIGNED_IN = "isSignedIn";
  private static final String METHOD_CLEAR_AUTH_CACHE = "clearAuthCache";

  private final IDelegate delegate;

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
        String signInOption = call.argument("signInOption");
        List<String> requestedScopes = call.argument("scopes");
        String hostedDomain = call.argument("hostedDomain");
        delegate.init(result, signInOption, requestedScopes, hostedDomain);
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

      default:
        result.notImplemented();
    }
  }

  /**
   * A delegate interface that exposes all of the sign-in functionality for other plugins to use.
   * The below {@link #Delegate} implementation should be used by any clients unless they need to
   * override some of these functions, such as for testing.
   */
  public interface IDelegate {
    /** Initializes this delegate so that it is ready to perform other operations. */
    public void init(
        Result result, String signInOption, List<String> requestedScopes, String hostedDomain);

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
  public static final class Delegate implements IDelegate, PluginRegistry.ActivityResultListener {
    private static final int REQUEST_CODE_SIGNIN = 53293;
    private static final int REQUEST_CODE_RECOVER_AUTH = 53294;

    private static final String ERROR_REASON_EXCEPTION = "exception";
    private static final String ERROR_REASON_STATUS = "status";
    // These error codes must match with ones declared on iOS and Dart sides.
    private static final String ERROR_REASON_SIGN_IN_CANCELED = "sign_in_canceled";
    private static final String ERROR_REASON_SIGN_IN_REQUIRED = "sign_in_required";
    private static final String ERROR_REASON_SIGN_IN_FAILED = "sign_in_failed";
    private static final String ERROR_FAILURE_TO_RECOVER_AUTH = "failed_to_recover_auth";
    private static final String ERROR_USER_RECOVERABLE_AUTH = "user_recoverable_auth";

    private static final String DEFAULT_SIGN_IN = "SignInOption.standard";
    private static final String DEFAULT_GAMES_SIGN_IN = "SignInOption.games";

    private final PluginRegistry.Registrar registrar;
    private final BackgroundTaskRunner backgroundTaskRunner = new BackgroundTaskRunner(1);

    private GoogleSignInClient signInClient;
    private List<String> requestedScopes;
    private PendingOperation pendingOperation;

    public Delegate(PluginRegistry.Registrar registrar) {
      this.registrar = registrar;
      registrar.addActivityResultListener(this);
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
        Result result, String signInOption, List<String> requestedScopes, String hostedDomain) {
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

        // Only requests a clientId if google-services.json was present and parsed
        // by the google-services Gradle script.
        // TODO(jackson): Perhaps we should provide a mechanism to override this
        // behavior.
        int clientIdIdentifier =
            registrar
                .context()
                .getResources()
                .getIdentifier(
                    "default_web_client_id", "string", registrar.context().getPackageName());
        if (clientIdIdentifier != 0) {
          optionsBuilder.requestIdToken(registrar.context().getString(clientIdIdentifier));
        }
        for (String scope : requestedScopes) {
          optionsBuilder.requestScopes(new Scope(scope));
        }
        if (!Strings.isNullOrEmpty(hostedDomain)) {
          optionsBuilder.setHostedDomain(hostedDomain);
        }

        this.requestedScopes = requestedScopes;
        signInClient = GoogleSignIn.getClient(registrar.context(), optionsBuilder.build());
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
      if (registrar.activity() == null) {
        throw new IllegalStateException("signIn needs a foreground activity");
      }
      checkAndSetPendingOperation(METHOD_SIGN_IN, result);

      Intent signInIntent = signInClient.getSignInIntent();
      registrar.activity().startActivityForResult(signInIntent, REQUEST_CODE_SIGNIN);
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
      boolean value = GoogleSignIn.getLastSignedInAccount(registrar.context()) != null;
      result.success(value);
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
              GoogleAuthUtil.clearToken(registrar.context(), token);
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
              return GoogleAuthUtil.getToken(registrar.context(), account, scopesStr);
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
                    checkAndSetPendingOperation(METHOD_GET_TOKENS, result, email);
                    Intent recoveryIntent =
                        ((UserRecoverableAuthException) e.getCause()).getIntent();
                    registrar
                        .activity()
                        .startActivityForResult(recoveryIntent, REQUEST_CODE_RECOVER_AUTH);
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
        default:
          return false;
      }
    }
  }
}
