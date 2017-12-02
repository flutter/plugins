// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.firebaseauth;

import android.app.Activity;
import android.support.annotation.NonNull;
import android.util.Log;
import android.util.SparseArray;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseException;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.EmailAuthProvider;
import com.google.firebase.auth.FacebookAuthProvider;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GetTokenResult;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.auth.UserInfo;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.TimeUnit;

/** Flutter plugin for Firebase Auth. */
public class FirebaseAuthPlugin implements MethodCallHandler {
  private final Activity activity;
  private final FirebaseAuth firebaseAuth;
  private final SparseArray<FirebaseAuth.AuthStateListener> authStateListeners =
      new SparseArray<>();
  private final MethodChannel channel;

  // Handles are ints used as indexes into the sparse array of active observers
  private int nextHandle = 0;

  private static final String ERROR_REASON_EXCEPTION = "exception";
    private String verficationid;
  //mcallback varibles
  PhoneAuthProvider.OnVerificationStateChangedCallbacks mCallbacks;
  public static void registerWith(PluginRegistry.Registrar registrar) {
    MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_auth");
    channel.setMethodCallHandler(new FirebaseAuthPlugin(registrar.activity(), channel));
  }

  private FirebaseAuthPlugin(Activity activity, MethodChannel channel) {
    this.activity = activity;
    this.channel = channel;
    FirebaseApp.initializeApp(activity);
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
      case "signInWithEmailAndPassword":
        handleSignInWithEmailAndPassword(call, result);
        break;
      case "signInWithGoogle":
        handleSignInWithGoogle(call, result);
        break;
      case "signInWithCustomToken":
        handleSignInWithCustomToken(call, result);
        break;
      case "signInWithPhoneNumber":
        handleSignInWithPhoneNumber(call,result);
        break;
      case "verifyOtp":
          handleverifyotp(call, result);
          break;
      case "signInWithFacebook":
        handleSignInWithFacebook(call, result);
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
      case "startListeningAuthState":
        handleStartListeningAuthState(call, result);
        break;
      case "stopListeningAuthState":
        handleStopListeningAuthState(call, result);
        break;
        case "deleteCurrentUser":
            handledeletecurrentuser(result);
            break;
      default:
        result.notImplemented();
        break;
    }
  }
  private void handleSignInWithPhoneNumber(MethodCall call,final Result result) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String phoneNumber = arguments.get("phoneNumber");


    mCallbacks = new PhoneAuthProvider.OnVerificationStateChangedCallbacks() {

      @Override
      public void onVerificationCompleted(PhoneAuthCredential phoneAuthCredential) {
      }
      @Override
      public void onVerificationFailed(FirebaseException e) {
        Log.e("onVerificationFailed", e.toString());
        result.error(ERROR_REASON_EXCEPTION, e.getMessage(), null);
        Log.e("error", e.getMessage());
      }

      @Override
      public void onCodeSent(String verificationId,
                             PhoneAuthProvider.ForceResendingToken token) {
        Log.e("onCodeSent:", verificationId);
              verficationid =verificationId;
        result.success("sentotp");
      }
    };

    PhoneAuthProvider.getInstance().verifyPhoneNumber(phoneNumber,60, TimeUnit.SECONDS,this.activity,this.mCallbacks);
  }
    private void handledeletecurrentuser(final Result result) {
          @SuppressWarnings("unchecked")
        FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
        
        user.delete()
        .addOnCompleteListener(new OnCompleteListener<Void>() {
            @Override
            public void onComplete(@NonNull Task<Void> task) {
                if (task.isSuccessful()) {
                    Log.d("Status", "User account deleted.");
                      result.success("deleted");
                }else{
                     result.error(ERROR_REASON_EXCEPTION, task.getException().getMessage(), null);
                }
            }
        });
    }


    private void  handleverifyotp(MethodCall call, final Result result) {
        @SuppressWarnings("unchecked")
        Map<String, String> arguments = (Map<String, String>) call.arguments;
        String otp = arguments.get("otp");
        PhoneAuthCredential credential = PhoneAuthProvider.getCredential(verficationid, otp);
            firebaseAuth.signInWithCredential(credential)
                    .addOnCompleteListener(activity, new SignInCompleteListener(result));
        Log.e("otp", otp);
        Log.e("Phoneauthotp", "hit success");
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
        .addOnCompleteListener(activity, new SignInCompleteListener(result));
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
    firebaseAuth
        .signInAnonymously()
        .addOnCompleteListener(activity, new SignInCompleteListener(result));
  }

  private void handleCreateUserWithEmailAndPassword(MethodCall call, final Result result) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String email = arguments.get("email");
    String password = arguments.get("password");

    firebaseAuth
        .createUserWithEmailAndPassword(email, password)
        .addOnCompleteListener(activity, new SignInCompleteListener(result));
  }

  private void handleSignInWithEmailAndPassword(MethodCall call, final Result result) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String email = arguments.get("email");
    String password = arguments.get("password");

    firebaseAuth
        .signInWithEmailAndPassword(email, password)
        .addOnCompleteListener(activity, new SignInCompleteListener(result));
  }

  private void handleSignInWithGoogle(MethodCall call, final Result result) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String idToken = arguments.get("idToken");
    String accessToken = arguments.get("accessToken");
    AuthCredential credential = GoogleAuthProvider.getCredential(idToken, accessToken);
    firebaseAuth
        .signInWithCredential(credential)
        .addOnCompleteListener(activity, new SignInCompleteListener(result));
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
        .addOnCompleteListener(activity, new SignInCompleteListener(result));
  }

  private void handleSignInWithFacebook(MethodCall call, final Result result) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String accessToken = arguments.get("accessToken");
    AuthCredential credential = FacebookAuthProvider.getCredential(accessToken);
    firebaseAuth
        .signInWithCredential(credential)
        .addOnCompleteListener(activity, new SignInCompleteListener(result));
  }

  private void handleSignInWithCustomToken(MethodCall call, final Result result) {
    Map<String, String> arguments = call.arguments();
    String token = arguments.get("token");
    firebaseAuth
        .signInWithCustomToken(token)
        .addOnCompleteListener(activity, new SignInCompleteListener(result));
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
        Log.i("user", user.getUid());
        ImmutableMap<String, Object> userMap = mapFromUser(user);
        result.success(userMap);
      }
    }
  }

  private ImmutableMap.Builder<String, Object> userInfoToMap(UserInfo userInfo) {
    ImmutableMap.Builder<String, Object> builder =
        ImmutableMap.<String, Object>builder()
            .put("providerId", (userInfo.getProviderId()))
            .put("uid", (userInfo.getUid())!= null ?userInfo.getUid() : "x");
    if (userInfo.getDisplayName() != null) {
      builder.put("displayName", userInfo.getDisplayName());
    }
    if (userInfo.getPhotoUrl() != null) {
      builder.put("photoUrl", userInfo.getPhotoUrl().toString());
    }
    if (userInfo.getEmail() != null) {
      builder.put("email", userInfo.getEmail());
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
      ImmutableMap<String, Object> userMap =
          userInfoToMap(user)
              .put("isAnonymous", user.isAnonymous())
              .put("isEmailVerified", user.isEmailVerified())
              .put("providerData", providerDataBuilder.build())
              .build();
      return userMap;
    } else {
      return null;
    }
  }


}
