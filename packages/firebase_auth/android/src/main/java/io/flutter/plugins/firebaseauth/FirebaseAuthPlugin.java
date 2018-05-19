// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseauth;

import android.net.Uri;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.util.Log;
import android.util.SparseArray;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.firebase.FirebaseApiNotAvailableException;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseException;
import com.google.firebase.FirebaseTooManyRequestsException;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.EmailAuthProvider;
import com.google.firebase.auth.FacebookAuthProvider;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GetTokenResult;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.auth.UserInfo;
import com.google.firebase.auth.UserProfileChangeRequest;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/** Flutter plugin for Firebase Auth. */
public class FirebaseAuthPlugin implements MethodCallHandler {
  private static final String TAG = FirebaseAuthPlugin.class.getSimpleName();
  private final PluginRegistry.Registrar registrar;
  private final FirebaseAuth firebaseAuth;
  private final SparseArray<FirebaseAuth.AuthStateListener> authStateListeners =
      new SparseArray<>();
  private final MethodChannel channel;

  // Handles are ints used as indexes into the sparse array of active observers
  private int nextHandle = 0;

  private static final String ERROR_REASON_EXCEPTION = "exception";

  private String currentPhoneNumber;
  private String phoneVerificationId;
  private PhoneAuthProvider.ForceResendingToken phoneResendToken;

  private static final String PHONE_SIGN_IN_EVENTS_CHANNEL_NAME =
      "plugins.flutter.io/firebase_auth_phone_sign_in";
  private static final String PHONE_SIGN_IN_CODE_SENT_EVENT = "CODE_SENT";
  private static final String PHONE_SIGN_IN_CODE_AUTO_RETRIEVAL_TIMEOUT_EVENT =
      "CODE_AUTO_RETRIEVAL_TIMEOUT";
  private static EventChannel.EventSink phoneSignInEventsSink;

  private static final String PHONE_SIGN_IN_INVALID_REQUEST_ERROR = "INVALID_REQUEST";
  private static final String PHONE_SIGN_IN_SMS_QUOTA_EXCEEDED_ERROR = "SMS_QUOTA_EXCEEDED";
  private static final String PHONE_SIGN_IN_UNAUTHORIZED_ERROR = "UNAUTHORIZED";
  private static final String PHONE_SIGN_IN_API_NOT_AVAILABLE_ERROR = "API_NOT_AVAILABLE";
  private static final String PHONE_SIGN_IN_NO_FOREGROUND_ACTIVITY_ERROR = "NO_FOREGROUND_ACTIVITY";

  public static void registerWith(PluginRegistry.Registrar registrar) {
    MethodChannel methodChannel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_auth");
    methodChannel.setMethodCallHandler(new FirebaseAuthPlugin(registrar, methodChannel));

    final EventChannel phoneSignInEventChannel =
        new EventChannel(registrar.messenger(), PHONE_SIGN_IN_EVENTS_CHANNEL_NAME);
    phoneSignInEventChannel.setStreamHandler(new PhoneSignInStreamHandler());
  }

  private FirebaseAuthPlugin(PluginRegistry.Registrar registrar, MethodChannel channel) {
    this.registrar = registrar;
    this.channel = channel;
    FirebaseApp.initializeApp(registrar.context());
    this.firebaseAuth = FirebaseAuth.getInstance();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "currentUser":
        handleCurrentUser(call, result);
        break;
      case "signInAnonymously":
        handleSignInAnonymously(call, result);
        break;
      case "createUserWithEmailAndPassword":
        handleCreateUserWithEmailAndPassword(call, result);
        break;
      case "fetchProvidersForEmail":
        handleFetchProvidersForEmail(call, result);
        break;
      case "sendPasswordResetEmail":
        handleSendPasswordResetEmail(call, result);
        break;
      case "sendEmailVerification":
        handleSendEmailVerification(call, result);
        break;
      case "reload":
        handleReload(call, result);
        break;
      case "signInWithEmailAndPassword":
        handleSignInWithEmailAndPassword(call, result);
        break;
      case "signInWithGoogle":
        handleSignInWithGoogle(call, result);
        break;
      case "signInWithCustomToken":
        handleSignInWithCustomToken(call, result);
        break;
      case "signInWithFacebook":
        handleSignInWithFacebook(call, result);
        break;
      case "signInWithTwitter":
        handleSignInWithTwitter(call, result);
      case "signInWithPhoneNumber":
        handleSignInWithPhoneNumber(call, result);
        break;
      case "resendVerificationCode":
        handleResendVerificationCode(call, result);
        break;
      case "verifyPhoneNumber":
        handleVerifyPhoneNumber(call, result);
        break;
      case "signOut":
        handleSignOut(call, result);
        break;
      case "getIdToken":
        handleGetToken(call, result);
        break;
      case "linkWithEmailAndPassword":
        handleLinkWithEmailAndPassword(call, result);
        break;
      case "linkWithGoogleCredential":
        handleLinkWithGoogleCredential(call, result);
        break;
      case "linkWithFacebookCredential":
        handleLinkWithFacebookCredential(call, result);
        break;
      case "updateProfile":
        handleUpdateProfile(call, result);
        break;
      case "startListeningAuthState":
        handleStartListeningAuthState(call, result);
        break;
      case "stopListeningAuthState":
        handleStopListeningAuthState(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void handleLinkWithEmailAndPassword(MethodCall call, Result result) {
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

  private void handleCurrentUser(MethodCall call, final Result result) {
    final FirebaseAuth.AuthStateListener listener =
        new FirebaseAuth.AuthStateListener() {
          @Override
          public void onAuthStateChanged(@NonNull FirebaseAuth firebaseAuth) {
            firebaseAuth.removeAuthStateListener(this);
            FirebaseUser user = firebaseAuth.getCurrentUser();
            ImmutableMap<String, Object> userMap = mapFromUser(user);
            result.success(userMap);
          }
        };

    firebaseAuth.addAuthStateListener(listener);
  }

  private void handleSignInAnonymously(MethodCall call, final Result result) {
    firebaseAuth.signInAnonymously().addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleCreateUserWithEmailAndPassword(MethodCall call, final Result result) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String email = arguments.get("email");
    String password = arguments.get("password");

    firebaseAuth
        .createUserWithEmailAndPassword(email, password)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleFetchProvidersForEmail(MethodCall call, final Result result) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String email = arguments.get("email");

    firebaseAuth
        .fetchProvidersForEmail(email)
        .addOnCompleteListener(new ProvidersCompleteListener(result));
  }

  private void handleSendPasswordResetEmail(MethodCall call, final Result result) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String email = arguments.get("email");

    firebaseAuth
        .sendPasswordResetEmail(email)
        .addOnCompleteListener(new TaskVoidCompleteListener(result));
  }

  private void handleSendEmailVerification(MethodCall call, final Result result) {
    firebaseAuth
        .getCurrentUser()
        .sendEmailVerification()
        .addOnCompleteListener(new TaskVoidCompleteListener(result));
  }

  private void handleReload(MethodCall call, final Result result) {
    firebaseAuth
        .getCurrentUser()
        .reload()
        .addOnCompleteListener(new TaskVoidCompleteListener(result));
  }

  private void handleSignInWithEmailAndPassword(MethodCall call, final Result result) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String email = arguments.get("email");
    String password = arguments.get("password");

    firebaseAuth
        .signInWithEmailAndPassword(email, password)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleSignInWithGoogle(MethodCall call, final Result result) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String idToken = arguments.get("idToken");
    String accessToken = arguments.get("accessToken");
    AuthCredential credential = GoogleAuthProvider.getCredential(idToken, accessToken);
    firebaseAuth
        .signInWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleLinkWithGoogleCredential(MethodCall call, final Result result) {
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

  private void handleLinkWithFacebookCredential(MethodCall call, final Result result) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String accessToken = arguments.get("accessToken");
    AuthCredential credential = FacebookAuthProvider.getCredential(accessToken);
    firebaseAuth
        .getCurrentUser()
        .linkWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleSignInWithFacebook(MethodCall call, final Result result) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String accessToken = arguments.get("accessToken");
    AuthCredential credential = FacebookAuthProvider.getCredential(accessToken);
    firebaseAuth
        .signInWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleSignInWithTwitter(MethodCall call, final Result result) {
    String authToken = call.argument("authToken");
    String authTokenSecret = call.argument("authTokenSecret");
    AuthCredential credential = TwitterAuthProvider.getCredential(authToken, authTokenSecret);
    firebaseAuth
        .signInWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void handleSignInWithCustomToken(MethodCall call, final Result result) {
    Map<String, String> arguments = call.arguments();
    String token = arguments.get("token");
    firebaseAuth
        .signInWithCustomToken(token)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void startPhoneNumberVerification(String phoneNumber, long timeout, final Result result) {
    if (!runningInForegroundActivity(result)) return;

    Log.d(
        TAG,
        "[startPhoneNumberVerification] phoneNumber: "
            + phoneNumber
            + " Timeout: "
            + String.valueOf(timeout)
            + " seconds");

    PhoneAuthProvider.getInstance()
        .verifyPhoneNumber(
            phoneNumber,
            timeout,
            TimeUnit.SECONDS,
            registrar.activity(),
            new PhoneVerificationStateChangedCallbacks(result));
  }

  private void verifyPhoneNumberWithCode(String verificationId, String code, Result result) {
    Log.d(TAG, "[verifyPhoneNumberWithCode] verificationId: " + verificationId + " code: " + code);
    PhoneAuthCredential credential = PhoneAuthProvider.getCredential(verificationId, code);
    signInWithPhoneAuthCredential(credential, result);
  }

  private void signInWithPhoneAuthCredential(PhoneAuthCredential credential, Result result) {
    firebaseAuth
        .signInWithCredential(credential)
        .addOnCompleteListener(new SignInCompleteListener(result));
  }

  private void resendPhoneVerificationCode(
      String phoneNumber,
      long timeout,
      PhoneAuthProvider.ForceResendingToken token,
      Result result) {
    if (!runningInForegroundActivity(result)) return;

    Log.d(
        TAG,
        "[resendPhoneVerificationCode] phoneNumber: "
            + phoneNumber
            + " Timeout: "
            + String.valueOf(timeout)
            + " seconds");

    PhoneAuthProvider.getInstance()
        .verifyPhoneNumber(
            phoneNumber,
            timeout,
            TimeUnit.SECONDS,
            registrar.activity(),
            new PhoneVerificationStateChangedCallbacks(result),
            token);
  }

  private void handleSignInWithPhoneNumber(MethodCall call, final Result result) {
    if (!runningInForegroundActivity(result)) return;

    String phoneNumber = call.argument("phoneNumber");
    currentPhoneNumber = phoneNumber;

    Integer timeout = call.argument("timeout");

    startPhoneNumberVerification(phoneNumber, timeout.intValue(), result);
  }

  private void handleResendVerificationCode(MethodCall call, final Result result) {
    if (!runningInForegroundActivity(result)) return;

    String phoneNumber = call.argument("phoneNumber");
    Integer timeout = call.argument("timeout");

    // Reuse the resend token if it's for the same phone number it was generated for
    if (phoneResendToken != null && phoneNumber.equals(currentPhoneNumber)) {
      resendPhoneVerificationCode(currentPhoneNumber, timeout.intValue(), phoneResendToken, result);
    } else {
      currentPhoneNumber = phoneNumber;
      startPhoneNumberVerification(currentPhoneNumber, timeout.intValue(), result);
    }
  }

  private void handleVerifyPhoneNumber(MethodCall call, final Result result) {
    if (!runningInForegroundActivity(result)) return;

    if (TextUtils.isEmpty(phoneVerificationId)) {
      result.error(
          ERROR_REASON_EXCEPTION,
          "Missing verification id, " + "retry by calling signInWithPhoneNumber again",
          null);
      return;
    }

    String code = call.argument("code");
    verifyPhoneNumberWithCode(phoneVerificationId, code, result);
  }

  private void handleSignOut(MethodCall call, final Result result) {
    firebaseAuth.signOut();
    result.success(null);
  }

  private void handleGetToken(MethodCall call, final Result result) {
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

  private void handleUpdateProfile(MethodCall call, final Result result) {
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
        .addOnCompleteListener(
            new OnCompleteListener<Void>() {
              @Override
              public void onComplete(@NonNull Task<Void> task) {
                if (!task.isSuccessful()) {
                  Exception e = task.getException();
                  result.error(ERROR_REASON_EXCEPTION, e.getMessage(), null);
                } else {
                  result.success(null);
                }
              }
            });
  }

  private void handleStartListeningAuthState(MethodCall call, final Result result) {
    final int handle = nextHandle++;
    FirebaseAuth.AuthStateListener listener =
        new FirebaseAuth.AuthStateListener() {
          @Override
          public void onAuthStateChanged(@NonNull FirebaseAuth firebaseAuth) {
            FirebaseUser user = firebaseAuth.getCurrentUser();
            ImmutableMap<String, Object> userMap = mapFromUser(user);
            ImmutableMap.Builder<String, Object> builder =
                ImmutableMap.<String, Object>builder().put("id", handle);

            if (userMap != null) {
              builder.put("user", userMap);
            }
            channel.invokeMethod("onAuthStateChanged", builder.build());
          }
        };
    FirebaseAuth.getInstance().addAuthStateListener(listener);
    authStateListeners.append(handle, listener);
    result.success(handle);
  }

  private void handleStopListeningAuthState(MethodCall call, final Result result) {
    Map<String, Integer> arguments = call.arguments();
    Integer id = arguments.get("id");

    FirebaseAuth.AuthStateListener listener = authStateListeners.get(id);
    if (listener != null) {
      FirebaseAuth.getInstance().removeAuthStateListener(listener);
      authStateListeners.removeAt(id);
      result.success(null);
    } else {
      result.error(
          ERROR_REASON_EXCEPTION,
          String.format("Listener with identifier '%d' not found.", id),
          null);
    }
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
        ImmutableMap<String, Object> userMap = mapFromUser(user);
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

  private class PhoneVerificationStateChangedCallbacks
      extends PhoneAuthProvider.OnVerificationStateChangedCallbacks {
    private final Result result;

    PhoneVerificationStateChangedCallbacks(Result result) {
      this.result = result;
    }

    /**
     * This callback will be invoked in two situations: 1 - Instant verification. In some cases the
     * phone number can be instantly verified without needing to send or enter a verification code.
     * 2 - Auto-retrieval. On some devices Google Play services can automatically detect the
     * incoming verification SMS and perform verification without user action.
     *
     * @param credential authentication credentials
     */
    @Override
    public void onVerificationCompleted(PhoneAuthCredential credential) {
      Log.d(
          TAG,
          "onVerificationCompleted - Provider: "
              + credential.getProvider()
              + " , SmsCode: "
              + credential.getSmsCode());
      signInWithPhoneAuthCredential(credential, result);
    }

    /**
     * This callback is invoked when an invalid request for verification is made, for instance if
     * the the phone number format is not valid or the verification code is invalid.
     *
     * @param error the exception
     */
    @Override
    public void onVerificationFailed(FirebaseException error) {
      Log.w(TAG, "onVerificationFailed", error);

      if (error instanceof FirebaseAuthInvalidCredentialsException) {
        result.error(PHONE_SIGN_IN_INVALID_REQUEST_ERROR, "Invalid request.", error.getMessage());
      } else if (error instanceof FirebaseTooManyRequestsException) {
        result.error(
            PHONE_SIGN_IN_SMS_QUOTA_EXCEEDED_ERROR, "SMS quota exceeded.", error.getMessage());
      } else if (error instanceof FirebaseAuthException) {
        result.error(PHONE_SIGN_IN_UNAUTHORIZED_ERROR, "Unauthorized.", error.getMessage());
      } else if (error instanceof FirebaseApiNotAvailableException) {
        result.error(
            PHONE_SIGN_IN_API_NOT_AVAILABLE_ERROR,
            "API not available. " + "Missing Google Play Services?",
            error.getMessage());
      } else {
        result.error(ERROR_REASON_EXCEPTION, error.getMessage(), null);
      }
    }

    /**
     * The SMS verification code has been sent to the provided phone number, we now need to ask the
     * user to enter the code and then construct a credential by combining the code with a
     * verification ID.
     *
     * @param verificationId the verification id
     * @param resendToken the resend token
     */
    @Override
    public void onCodeSent(
        String verificationId, PhoneAuthProvider.ForceResendingToken resendToken) {
      Log.d(TAG, "onCodeSent: " + verificationId);
      phoneVerificationId = verificationId;
      phoneResendToken = resendToken;
      phoneSignInEventsSink.success(PHONE_SIGN_IN_CODE_SENT_EVENT);
    }

    /**
     * Called after the timeout duration specified to verifyPhoneNumber has passed without
     * onVerificationCompleted triggering first. On devices without SIM cards, this method is called
     * immediately because SMS auto-retrieval isn't possible.
     *
     * <p>Some apps block user input until the auto-verification period has timed out, and only then
     * display a UI that prompts the user to type the verification code from the SMS message (not
     * recommended).
     *
     * @param verificationId the verification id
     */
    @Override
    public void onCodeAutoRetrievalTimeOut(String verificationId) {
      phoneVerificationId = verificationId;
      phoneSignInEventsSink.success(PHONE_SIGN_IN_CODE_AUTO_RETRIEVAL_TIMEOUT_EVENT);
    }
  }

  private static class PhoneSignInStreamHandler implements EventChannel.StreamHandler {

    @Override
    public void onListen(Object args, final EventChannel.EventSink sink) {
      Log.d(TAG, "Adding phone sign in listener");
      phoneSignInEventsSink = sink;
    }

    @Override
    public void onCancel(Object args) {
      Log.d(TAG, "Cancelling phone sign in listener");
      phoneSignInEventsSink = null;
    }
  }

  private boolean runningInForegroundActivity(Result result) {
    if (registrar.activity() == null) {
      result.error(
          PHONE_SIGN_IN_NO_FOREGROUND_ACTIVITY_ERROR,
          "No foreground activity in the application",
          null);
      return false;
    }
    return true;
  }

  private ImmutableMap.Builder<String, Object> userInfoToMap(UserInfo userInfo) {
    ImmutableMap.Builder<String, Object> builder = ImmutableMap.<String, Object>builder();

    if (userInfo.getProviderId() != null) {
      builder.put("providerId", userInfo.getProviderId());
    }

    if (userInfo.getUid() != null) {
      builder.put("uid", userInfo.getUid());
    }

    if (userInfo.getDisplayName() != null) {
      builder.put("displayName", userInfo.getDisplayName());
    }

    if (userInfo.getPhotoUrl() != null) {
      builder.put("photoUrl", userInfo.getPhotoUrl().toString());
    }

    if (userInfo.getEmail() != null) {
      builder.put("email", userInfo.getEmail());
    }

    if (userInfo.getPhoneNumber() != null) {
      builder.put("phoneNumber", userInfo.getPhoneNumber());
    }

    return builder;
  }

  private ImmutableMap<String, Object> mapFromUser(FirebaseUser user) {
    if (user != null) {
      ImmutableList.Builder<ImmutableMap<String, Object>> providerDataBuilder =
          ImmutableList.<ImmutableMap<String, Object>>builder();

      for (UserInfo userInfo : user.getProviderData()) {
        providerDataBuilder.add(userInfoToMap(userInfo).build());
      }

      return userInfoToMap(user)
          .put("isAnonymous", user.isAnonymous())
          .put("isEmailVerified", user.isEmailVerified())
          .put("providerData", providerDataBuilder.build())
          .build();
    } else {
      return null;
    }
  }
}
