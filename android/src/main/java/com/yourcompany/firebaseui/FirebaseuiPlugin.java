package com.yourcompany.firebaseui;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import android.app.Activity;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.util.Log;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

import com.firebase.ui.auth.AuthUI;
import com.firebase.ui.auth.ErrorCodes;
import com.firebase.ui.auth.IdpResponse;
import com.firebase.ui.auth.ResultCodes;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.UserInfo;

import java.util.Arrays;
import java.util.Collections;

/**
 * FirebaseuiPlugin
 */
public class FirebaseuiPlugin implements MethodCallHandler, PluginRegistry.ActivityResultListener {

  private final Activity activity;
  private final FirebaseAuth firebaseAuth;
  private String is;
  private static final int RC_SIGN_IN = 123;
  private static final int RC_SIGN_INPHONE = 124;

  // Pending method call to obtain an image
  private Result pendingResult;

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "firebaseui");
    FirebaseuiPlugin plugin = new FirebaseuiPlugin(registrar.activity());
    registrar.addActivityResultListener(plugin);
    channel.setMethodCallHandler(plugin);
  }

  private FirebaseuiPlugin(Activity activity) {
    this.activity = activity;
    FirebaseApp.initializeApp(activity);
    this.firebaseAuth = FirebaseAuth.getInstance();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (pendingResult != null) {
      result.error("ALREADY_ACTIVE", "firebases sign is already active", null);
      return;
    }
    pendingResult = result;

    switch (call.method){
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "getCurrentUser":
        handleGetCurrentUser(call, result);
        break;
      case "signIn":
        hanleSignin(call, result);
        break;
      case "signinPhone":
        hanleSigninPhone(call, result);
        break;
      case "signOut":
        //hanleSignout(call, result);
        result.notImplemented();
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private ImmutableMap.Builder<String, Object> userInfoToMap(UserInfo userInfo) {
    ImmutableMap.Builder<String, Object> builder =
            ImmutableMap.<String, Object>builder()
                    .put("providerId", userInfo.getProviderId());
    if (userInfo.getProviderId().equals("phone")){
      System.out.println("电话号码user："+ userInfo.getPhoneNumber() +" :" + userInfo.getUid());
    }

    if (userInfo.getPhoneNumber() != null) {
      builder.put("phoneNumber", userInfo.getPhoneNumber());
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
    return builder;
  }

  private void handleGetCurrentUser(MethodCall call, final Result result){
    FirebaseUser user = firebaseAuth.getCurrentUser();
    if (user!=null){
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
    }else {
      result.success(null);
    }
    pendingResult = null;

  }

//  private void hanleSignout(MethodCall call, final Result result) {
//    AuthUI.getInstance().signOut(activity)
//            .addOnCompleteListener(new OnCompleteListener<Void>() {
//              @Override
//              public void onComplete(@NonNull Task<Void> task) {
//                result.success(true);
//                pendingResult = null;
//              }
//            });
//  }

  private void hanleSignin(MethodCall call, Result result) {
    if (firebaseAuth.getCurrentUser() != null){
      result.success(firebaseAuth.getCurrentUser().getDisplayName());
//      result.success(firebaseAuth.getCurrentUser().getDisplayName());
      pendingResult=null;
    }else {
      activity.startActivityForResult(AuthUI.getInstance()
                      .createSignInIntentBuilder()
                      .setProviders(Collections.singletonList(new AuthUI.IdpConfig.Builder(AuthUI.EMAIL_PROVIDER).build()))
                      .build(),
              RC_SIGN_IN);
    }
  }

  private void hanleSigninPhone(MethodCall call, Result result) {
    if (firebaseAuth.getCurrentUser() != null){
      System.out.println(firebaseAuth.getCurrentUser().getPhoneNumber());
      result.success(firebaseAuth.getCurrentUser().getPhoneNumber());
      pendingResult=null;
    }else {
      activity.startActivityForResult(
                          AuthUI.getInstance()
                                  .createSignInIntentBuilder()
                                  .setAvailableProviders(
                                          Collections.singletonList(new AuthUI.IdpConfig.Builder(AuthUI.PHONE_VERIFICATION_PROVIDER).build()))
//                                  .setIsSmartLockEnabled(!BuildConfig.DEBUG)
                                  .build(),
              RC_SIGN_INPHONE);
    }
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode == RC_SIGN_IN) {
      IdpResponse response = IdpResponse.fromResultIntent(data);

      // Successfully signed in
      if (resultCode == ResultCodes.OK) {
        pendingResult.success(firebaseAuth.getCurrentUser().getDisplayName());
//        pendingResult.success(response);
        pendingResult = null;
        return true;
      } else {
        // Sign in failed
        if (response == null) {
          // User pressed back button
          pendingResult.error("登录","登录失败",null);
          pendingResult = null;
          return true;
        }

        if (response.getErrorCode() == ErrorCodes.NO_NETWORK) {
          pendingResult.error("登录","网络错误",null);
          pendingResult = null;
          return true;
        }

        if (response.getErrorCode() == ErrorCodes.UNKNOWN_ERROR) {
          pendingResult.error("登录","未知错误",null);
          pendingResult = null;
          return true;
        }
      }
    }
    if (requestCode == RC_SIGN_INPHONE) {
          IdpResponse response = IdpResponse.fromResultIntent(data);

          // Successfully signed in
          if (resultCode == ResultCodes.OK) {
            pendingResult.success(firebaseAuth.getCurrentUser().getPhoneNumber());
    //        pendingResult.success(response);
            pendingResult = null;
            return true;
          } else {
            // Sign in failed
            if (response == null) {
              // User pressed back button
              pendingResult.error("登录","登录失败",null);
              pendingResult = null;
              return true;
            }

            if (response.getErrorCode() == ErrorCodes.NO_NETWORK) {
              pendingResult.error("登录","网络错误",null);
              pendingResult = null;
              return true;
            }

            if (response.getErrorCode() == ErrorCodes.UNKNOWN_ERROR) {
              pendingResult.error("登录","未知错误",null);
              pendingResult = null;
              return true;
            }
          }
        }
    return false;
  }
}
