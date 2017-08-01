// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.firebaseauth;

import android.app.Activity;
import android.support.annotation.NonNull;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FacebookAuthProvider;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GetTokenResult;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.auth.UserInfo;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.Map;

/** Flutter plugin for Firebase Auth. */
public class FirebaseAuthPlugin implements MethodCallHandler {
  private final Activity activity;
  private final FirebaseAuth firebaseAuth;

  private static final String ERROR_REASON_EXCEPTION = "exception";

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_auth");
    channel.setMethodCallHandler(new FirebaseAuthPlugin(registrar.activity()));
  }

  private FirebaseAuthPlugin(Activity activity) {
    this.activity = activity;
    FirebaseApp.initializeApp(activity);
    this.firebaseAuth = FirebaseAuth.getInstance();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
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
      case "signInWithFacebook":
        handleSignInWithFacebook(call, result);
        break;
      case "signOut":
        handleSignOut(call, result);
        break;
      case "getToken":
        handleGetToken(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
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

  private void handleSignInWithFacebook(MethodCall call, final Result result) {
    @SuppressWarnings("unchecked")
    Map<String, String> arguments = (Map<String, String>) call.arguments;
    String accessToken = arguments.get("accessToken");
    AuthCredential credential = FacebookAuthProvider.getCredential(accessToken);
    firebaseAuth
        .signInWithCredential(credential)
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
        .getToken(refresh)
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

  private class SignInCompleteListener implements OnCompleteListener<AuthResult> {
    private final Result result;

    SignInCompleteListener(Result result) {
      this.result = result;
    }

    private ImmutableMap.Builder<String, Object> userInfoToMap(UserInfo userInfo) {
      ImmutableMap.Builder<String, Object> builder =
          ImmutableMap.<String, Object>builder()
              .put("providerId", userInfo.getProviderId())
              .put("uid", userInfo.getUid());
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

    @Override
    public void onComplete(@NonNull Task<AuthResult> task) {
      if (!task.isSuccessful()) {
        Exception e = task.getException();
        result.error(ERROR_REASON_EXCEPTION, e.getMessage(), null);
      } else {
        FirebaseUser user = task.getResult().getUser();
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
          result.success(userMap);
        } else {
          result.success(null);
        }
      }
    }
  }
}
