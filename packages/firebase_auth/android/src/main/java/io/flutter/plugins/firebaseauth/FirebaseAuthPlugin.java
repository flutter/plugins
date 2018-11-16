// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseauth;

import android.net.Uri;
import android.support.annotation.NonNull;
import android.util.SparseArray;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApiNotAvailableException;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseException;
import com.google.firebase.FirebaseTooManyRequestsException;
import com.google.firebase.auth.*;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/** Flutter plugin for Firebase Auth. */
public class FirebaseAuthPlugin implements MethodCallHandler {
  private final PluginRegistry.Registrar registrar;
  private final SparseArray<FirebaseAuth.AuthStateListener> authStateListeners =
      new SparseArray<>();
  private final SparseArray<PhoneAuthProvider.ForceResendingToken> forceResendingTokens =
      new SparseArray<>();
  private final MethodChannel channel;

  // Handles are ints used as indexes into the sparse array of active observers
  private int nextHandle = 0;

  private static final String ERROR_REASON_EXCEPTION = "exception";

  public static void registerWith(PluginRegistry.Registrar registrar) {
    MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_auth");
    channel.setMethodCallHandler(new FirebaseAuthPlugin(registrar, channel));
  }

  private FirebaseAuthPlugin(PluginRegistry.Registrar registrar, MethodChannel channel) {
    this.registrar = registrar;
    this.channel = channel;
    FirebaseApp.initializeApp(registrar.context());
  }

  private FirebaseAuth getAuth(MethodCall call) {
    Map<String, Object> arguments = (Map<String, Object>) call.arguments;
    String appName = (String) arguments.get("app");
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseAuth.getInstance(app);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "currentUser":
        handleCurrentUser(call, result, getAuth(call));
        break;
      case "signInAnonymously":
        handleSignInAnonymously(call, result, getAuth(call));
        break;
      case "createUserWithEmailAndPassword":
        handleCreateUserWithEmailAndPassword(call, result, getAuth(call));
        break;
      case "fetchProvidersForEmail":
        handleFetchProvidersForEmail(call, result, getAuth(call));
        break;
      case "sendPasswordResetEmail":
        handleSendPasswordResetEmail(call, result, getAuth(call));
        break;
      case "sendEmailVerification":
        handleSendEmailVerification(call, result, getAuth(call));
        break;
      case "reload":
        handleReload(call, result, getAuth(call));
        break;
      case "delete":
        handleDelete(call, result, getAuth(call));
        break;
      case "signInWithEmailAndPassword":
        handleSignInWithEmailAndPassword(call, result, getAuth(call));
        break;
      case "signInWithGoogle":
        handleSignInWithGoogle(call, result, getAuth(call));
        break;
      case "signInWithCustomToken":
        handleSignInWithCustomToken(call, result, getAuth(call));
        break;
      case "signInWithFacebook":
        handleSignInWithFacebook(call, result, getAuth(call));
        break;
      case "signInWithTwitter":
        handleSignInWithTwitter(call, result, getAuth(call));
        break;
      case "signInWithGithub":
        handleSignInWithGithub(call, result, getAuth(call));
        break;
      case "signOut":
        handleSignOut(call, result, getAuth(call));
        break;
      case "getIdToken":
        handleGetToken(call, result, getAuth(call));
        break;
      case "linkWithEmailAndPassword":
        handleLinkWithEmailAndPassword(call, result, getAuth(call));
        break;
      case "linkWithGoogleCredential":
        handleLinkWithGoogleCredential(call, result, getAuth(call));
        break;
      case "linkWithFacebookCredential":
        handleLinkWithFacebookCredential(call, result, getAuth(call));
        break;
      case "linkWithTwitterCredential":
        handleLinkWithTwitterCredential(call, result, getAuth(call));
        break;
      case "linkWithGithubCredential":
        handleLinkWithGithubCredential(call, result, getAuth(call));
        break;
      case "updateEmail":
        handleUpdateEmail(call, result, getAuth(call));
        break;
      case "updatePassword":
        handleUpdatePassword(call, result, getAuth(call));
        break;
      case "updateProfile":
        handleUpdateProfile(call, result, getAuth(call));
        break;
      case "startListeningAuthState":
        handleStartListeningAuthState(call, result, getAuth(call));
        break;
      case "stopListeningAuthState":
        handleStopListeningAuthState(call, result, getAuth(call));
        break;
      case "verifyPhoneNumber":
        handleVerifyPhoneNumber(call, result, getAuth(call));
        break;
      case "signInWithPhoneNumber":
        handleSignInWithPhoneNumber(call, result, getAuth(call));
        break;
      case "setLanguageCode":
        handleSetLanguageCode(call, result, getAuth(call));
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void handleSignInWithPhoneNumber(
      MethodCall call, Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String verificationId = arguments.get("verificationId");
    String smsCode = arguments.get("smsCode");

    PhoneAuthCredential phoneAuthCredential =
        PhoneAuthProvider.getCredential(verificationId, smsCode);
    firebaseAuth
        .signInWithCredential(phoneAuthCredential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleVerifyPhoneNumber(
      MethodCall call, Result result, final FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    final int handle = call.argument("handle");
    String phoneNumber = call.argument("phoneNumber");
    int timeout = call.argument("timeout");

    PhoneAuthProvider.OnVerificationStateChangedCallbacks verificationCallbacks =
        new PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
          @Override
          public void onVerificationCompleted(PhoneAuthCredential phoneAuthCredential) {
            firebaseAuth
                .signInWithCredential(phoneAuthCredential)
                .addOnCompleteListener(
                    new OnCompleteListener<AuthResult>() {
                      @Override
                      public void onComplete(@NonNull Task<AuthResult> task) {
                        if (task.isSuccessful()) {
                          Map<String, Object> arguments = new HashMap<>();
                          arguments.put("handle", handle);
                          channel.invokeMethod("phoneVerificationCompleted", arguments);
                        }
                      }
                    });
          }

          @Override
          public void onVerificationFailed(FirebaseException e) {
            Map<String, Object> arguments = new HashMap<>();
            arguments.put("handle", handle);
            arguments.put("exception", getVerifyPhoneNumberExceptionMap(e));
            channel.invokeMethod("phoneVerificationFailed", arguments);
          }

          @Override
          public void onCodeSent(
              String verificationId, PhoneAuthProvider.ForceResendingToken forceResendingToken) {
            Map<String, Object> arguments = new HashMap<>();
            arguments.put("handle", handle);
            arguments.put("verificationId", verificationId);
            arguments.put("forceResendingToken", forceResendingToken.hashCode());
            channel.invokeMethod("phoneCodeSent", arguments);
          }

          @Override
          public void onCodeAutoRetrievalTimeOut(String verificationId) {
            Map<String, Object> arguments = new HashMap<>();
            arguments.put("handle", handle);
            arguments.put("verificationId", verificationId);
            channel.invokeMethod("phoneCodeAutoRetrievalTimeout", arguments);
          }
        };

    if (call.argument("forceResendingToken") != null) {
      int forceResendingTokenKey = call.argument("forceResendingToken");
      PhoneAuthProvider.ForceResendingToken forceResendingToken =
          forceResendingTokens.get(forceResendingTokenKey);
      PhoneAuthProvider.getInstance()
          .verifyPhoneNumber(
              phoneNumber,
              timeout,
              TimeUnit.MILLISECONDS,
              registrar.activity(),
              verificationCallbacks,
              forceResendingToken);
    } else {
      PhoneAuthProvider.getInstance()
          .verifyPhoneNumber(
              phoneNumber,
              timeout,
              TimeUnit.MILLISECONDS,
              registrar.activity(),
              verificationCallbacks);
    }

    result.success(null);
  }

  private Map<String, Object> getVerifyPhoneNumberExceptionMap(FirebaseException e) {
    Map<String, Object> exceptionMap = new HashMap<>();
    String errorCode = "verifyPhoneNumberError";

    if (e instanceof FirebaseAuthInvalidCredentialsException) {
      errorCode = "invalidCredential";
    } else if (e instanceof FirebaseAuthException) {
      errorCode = "firebaseAuth";
    } else if (e instanceof FirebaseTooManyRequestsException) {
      errorCode = "quotaExceeded";
    } else if (e instanceof FirebaseApiNotAvailableException) {
      errorCode = "apiNotAvailable";
    }
    exceptionMap.put("code", errorCode);
    exceptionMap.put("message", e.getMessage());
    return exceptionMap;
  }

  private void handleLinkWithEmailAndPassword(
      MethodCall call, Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String email = arguments.get("email");
    String password = arguments.get("password");

    AuthCredential credential = EmailAuthProvider.getCredential(email, password);
    firebaseAuth
        .getCurrentUser()
        .linkWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleCurrentUser(MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    FirebaseUser user = firebaseAuth.getCurrentUser();
    if (user == null) {
      result.success(null);
      return;
    }
    Map<String, Object> userMap = mapFromUser(user);
    result.success(userMap);
  }

  private void handleSignInAnonymously(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    firebaseAuth.signInAnonymously().addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleCreateUserWithEmailAndPassword(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String email = arguments.get("email");
    String password = arguments.get("password");

    firebaseAuth
        .createUserWithEmailAndPassword(email, password)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleFetchProvidersForEmail(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String email = arguments.get("email");

    firebaseAuth
        .fetchProvidersForEmail(email)
        .addOnCompleteListener(new ProvidersCompleteListener(result));
  }

  private void handleSendPasswordResetEmail(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String email = arguments.get("email");

    firebaseAuth
        .sendPasswordResetEmail(email)
        .addOnCompleteListener(new TaskVoidCompleteListener(result));
  }

  private void handleSendEmailVerification(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    firebaseAuth
        .getCurrentUser()
        .sendEmailVerification()
        .addOnCompleteListener(new TaskVoidCompleteListener(result));
  }

  private void handleReload(MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    firebaseAuth
        .getCurrentUser()
        .reload()
        .addOnCompleteListener(new TaskVoidCompleteListener(result));
  }

  private void handleSignInWithEmailAndPassword(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String email = arguments.get("email");
    String password = arguments.get("password");

    firebaseAuth
        .signInWithEmailAndPassword(email, password)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleDelete(MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    firebaseAuth
        .getCurrentUser()
        .delete()
        .addOnCompleteListener(new TaskVoidCompleteListener(result));
  }

  private void handleSignInWithGoogle(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String idToken = arguments.get("idToken");
    String accessToken = arguments.get("accessToken");
    AuthCredential credential = GoogleAuthProvider.getCredential(idToken, accessToken);
    firebaseAuth
        .signInWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleLinkWithGoogleCredential(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String idToken = arguments.get("idToken");
    String accessToken = arguments.get("accessToken");
    AuthCredential credential = GoogleAuthProvider.getCredential(idToken, accessToken);
    firebaseAuth
        .getCurrentUser()
        .linkWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleLinkWithFacebookCredential(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String accessToken = arguments.get("accessToken");
    AuthCredential credential = FacebookAuthProvider.getCredential(accessToken);
    firebaseAuth
        .getCurrentUser()
        .linkWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleLinkWithTwitterCredential(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String authToken = arguments.get("authToken");
    String authTokenSecret = arguments.get("authTokenSecret");
    AuthCredential credential = TwitterAuthProvider.getCredential(authToken, authTokenSecret);
    firebaseAuth
        .getCurrentUser()
        .linkWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleLinkWithGithubCredential(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    String token = call.argument("token");
    AuthCredential credential = GithubAuthProvider.getCredential(token);
    firebaseAuth
        .getCurrentUser()
        .linkWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleSignInWithFacebook(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String accessToken = arguments.get("accessToken");
    AuthCredential credential = FacebookAuthProvider.getCredential(accessToken);
    firebaseAuth
        .signInWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleSignInWithTwitter(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    String authToken = call.argument("authToken");
    String authTokenSecret = call.argument("authTokenSecret");
    AuthCredential credential = TwitterAuthProvider.getCredential(authToken, authTokenSecret);
    firebaseAuth
        .signInWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleSignInWithGithub(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    String token = call.argument("token");
    AuthCredential credential = GithubAuthProvider.getCredential(token);
    firebaseAuth
        .signInWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleSignInWithCustomToken(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    Map<String, String> arguments = call.arguments();
    String token = arguments.get("token");
    firebaseAuth
        .signInWithCustomToken(token)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleSignOut(MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    firebaseAuth.signOut();
    result.success(null);
  }

  private void handleGetToken(MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, Boolean> arguments = (Map<String, Boolean>) call.arguments;
    boolean refresh = arguments.get("refresh");
    firebaseAuth
        .getCurrentUser()
        .getIdToken(refresh)
        .addOnCompleteListener(
            new OnCompleteListener<GetTokenResult>() {
              public void onComplete(@NonNull Task<GetTokenResult> task) {
                if (task.isSuccessful()) {
                  String idToken = task.getResult().getToken();
                  result.success(idToken);
                } else {
                  result.error(ERROR_REASON_EXCEPTION, task.getException().getMessage(), null);
                }
              }
            });
  }

  private void handleUpdateEmail(MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    firebaseAuth
        .getCurrentUser()
        .updateEmail(arguments.get("email"))
        .addOnCompleteListener(new TaskVoidCompleteListener(result));
  }

  private void handleUpdatePassword(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    firebaseAuth
        .getCurrentUser()
        .updatePassword(arguments.get("password"))
        .addOnCompleteListener(new TaskVoidCompleteListener(result));
  }

  private void handleUpdateProfile(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;

    UserProfileChangeRequest.Builder builder = new UserProfileChangeRequest.Builder();
    if (arguments.containsKey("displayName")) {
      builder.setDisplayName(arguments.get("displayName"));
    }
    if (arguments.containsKey("photoUrl")) {
      builder.setPhotoUri(Uri.parse(arguments.get("photoUrl")));
    }

    firebaseAuth
        .getCurrentUser()
        .updateProfile(builder.build())
        .addOnCompleteListener(new TaskVoidCompleteListener(result));
  }

  private void handleStartListeningAuthState(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    final int handle = nextHandle++;
    FirebaseAuth.AuthStateListener listener =
        new FirebaseAuth.AuthStateListener() {
          @Override
          public void onAuthStateChanged(@NonNull FirebaseAuth firebaseAuth) {
            FirebaseUser user = firebaseAuth.getCurrentUser();
            Map<String, Object> userMap = mapFromUser(user);
            Map<String, Object> map = new HashMap<>();
            map.put("id", handle);

            if (userMap != null) {
              map.put("user", userMap);
            }
            channel.invokeMethod("onAuthStateChanged", Collections.unmodifiableMap(map));
          }
        };
    firebaseAuth.addAuthStateListener(listener);
    authStateListeners.append(handle, listener);
    result.success(handle);
  }

  private void handleStopListeningAuthState(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    Map<String, Integer> arguments = call.arguments();
    Integer id = arguments.get("id");

    FirebaseAuth.AuthStateListener listener = authStateListeners.get(id);
    if (listener != null) {
      firebaseAuth.removeAuthStateListener(listener);
      authStateListeners.remove(id);
      result.success(null);
    } else {
      result.error(
          ERROR_REASON_EXCEPTION,
          String.format("Listener with identifier '%d' not found.", id),
          null);
    }
  }

  private void handleSetLanguageCode(
      MethodCall call, final Result result, FirebaseAuth firebaseAuth) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String language = arguments.get("language");

    firebaseAuth.setLanguageCode(language);
    result.success(null);
  }

  private class SignInCompleteListener implements OnCompleteListener<AuthResult> {
    private final Result result;

    SignInCompleteListener(Result result) {
      this.result = result;
    }

    @Override
    public void onComplete(@NonNull Task<AuthResult> task) {
      if (!task.isSuccessful()) {
        Exception e = task.getException();
        result.error(ERROR_REASON_EXCEPTION, e.getMessage(), null);
      } else {
        FirebaseUser user = task.getResult().getUser();
        Map<String, Object> userMap = Collections.unmodifiableMap(mapFromUser(user));
        result.success(userMap);
      }
    }
  }

  private class TaskVoidCompleteListener implements OnCompleteListener<Void> {
    private final Result result;

    TaskVoidCompleteListener(Result result) {
      this.result = result;
    }

    @Override
    public void onComplete(@NonNull Task<Void> task) {
      if (!task.isSuccessful()) {
        Exception e = task.getException();
        result.error(ERROR_REASON_EXCEPTION, e.getMessage(), null);
      } else {
        result.success(null);
      }
    }
  }

  private class ProvidersCompleteListener implements OnCompleteListener<ProviderQueryResult> {
    private final Result result;

    ProvidersCompleteListener(Result result) {
      this.result = result;
    }

    @Override
    public void onComplete(@NonNull Task<ProviderQueryResult> task) {
      if (!task.isSuccessful()) {
        Exception e = task.getException();
        result.error(ERROR_REASON_EXCEPTION, e.getMessage(), null);
      } else {
        List<String> providers = task.getResult().getProviders();
        result.success(providers);
      }
    }
  }

  private Map<String, Object> userInfoToMap(UserInfo userInfo) {
    Map<String, Object> map = new HashMap<>();
    map.put("providerId", userInfo.getProviderId());
    map.put("uid", userInfo.getUid());
    if (userInfo.getDisplayName() != null) {
      map.put("displayName", userInfo.getDisplayName());
    }
    if (userInfo.getPhotoUrl() != null) {
      map.put("photoUrl", userInfo.getPhotoUrl().toString());
    }
    if (userInfo.getEmail() != null) {
      map.put("email", userInfo.getEmail());
    }
    if (userInfo.getPhoneNumber() != null) {
      map.put("phoneNumber", userInfo.getPhoneNumber());
    }
    return map;
  }

  private Map<String, Object> mapFromUser(FirebaseUser user) {
    if (user != null) {
      List<Map<String, Object>> providerData = new ArrayList<>();
      for (UserInfo userInfo : user.getProviderData()) {
        // Ignore phone provider since firebase provider is a super set of the phone provider.
        if (userInfo.getProviderId().equals("phone")) {
          continue;
        }
        providerData.add(Collections.unmodifiableMap(userInfoToMap(userInfo)));
      }
      Map<String, Object> userMap = userInfoToMap(user);
      userMap.put("creationTimestamp", user.getMetadata().getCreationTimestamp());
      userMap.put("lastSignInTimestamp", user.getMetadata().getLastSignInTimestamp());
      userMap.put("isAnonymous", user.isAnonymous());
      userMap.put("isEmailVerified", user.isEmailVerified());
      userMap.put("providerData", Collections.unmodifiableList(providerData));
      return Collections.unmodifiableMap(userMap);
    } else {
      return null;
    }
  }
}
