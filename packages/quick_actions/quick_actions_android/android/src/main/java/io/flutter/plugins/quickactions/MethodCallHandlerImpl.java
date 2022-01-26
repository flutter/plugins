// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.quickactions;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ShortcutInfo;
import android.content.pm.ShortcutManager;
import android.content.res.Resources;
import android.graphics.drawable.Icon;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

class MethodCallHandlerImpl implements MethodChannel.MethodCallHandler {
  protected static final String EXTRA_ACTION = "some unique action key";
  private static final String CHANNEL_ID = "plugins.flutter.io/quick_actions_android";

  private final Context context;
  private Activity activity;

  MethodCallHandlerImpl(Context context, Activity activity) {
    this.context = context;
    this.activity = activity;
  }

  void setActivity(Activity activity) {
    this.activity = activity;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
      // We already know that this functionality does not work for anything
      // lower than API 25 so we chose not to return error. Instead we do nothing.
      result.success(null);
      return;
    }
    ShortcutManager shortcutManager =
        (ShortcutManager) context.getSystemService(Context.SHORTCUT_SERVICE);
    switch (call.method) {
      case "setShortcutItems":
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N_MR1) {
          List<Map<String, String>> serializedShortcuts = call.arguments();
          List<ShortcutInfo> shortcuts = deserializeShortcuts(serializedShortcuts);

          Executor uiThreadExecutor = new UiThreadExecutor();
          ThreadPoolExecutor executor =
              new ThreadPoolExecutor(
                  0, 1, 1, TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>());

          executor.execute(
              () -> {
                boolean dynamicShortcutsSet = false;
                try {
                  shortcutManager.setDynamicShortcuts(shortcuts);
                  dynamicShortcutsSet = true;
                } catch (Exception e) {
                  // Leave dynamicShortcutsSet as false
                }

                final boolean didSucceed = dynamicShortcutsSet;

                // TODO(camsim99): Move re-dispatch below to background thread when Flutter 2.8+ is stable.
                uiThreadExecutor.execute(
                    () -> {
                      if (didSucceed) {
                        result.success(null);
                      } else {
                        result.error(
                            "quick_action_setshortcutitems_failure",
                            "Exception thrown when setting dynamic shortcuts",
                            null);
                      }
                    });
              });
        }
        return;
      case "clearShortcutItems":
        shortcutManager.removeAllDynamicShortcuts();
        break;
      case "getLaunchAction":
        if (activity == null) {
          result.error(
              "quick_action_getlaunchaction_no_activity",
              "There is no activity available when launching action",
              null);
          return;
        }
        final Intent intent = activity.getIntent();
        final String launchAction = intent.getStringExtra(EXTRA_ACTION);
        if (launchAction != null && !launchAction.isEmpty()) {
          shortcutManager.reportShortcutUsed(launchAction);
          intent.removeExtra(EXTRA_ACTION);
        }
        result.success(launchAction);
        return;
      default:
        result.notImplemented();
        return;
    }
    result.success(null);
  }

  @TargetApi(Build.VERSION_CODES.N_MR1)
  private List<ShortcutInfo> deserializeShortcuts(List<Map<String, String>> shortcuts) {
    final List<ShortcutInfo> shortcutInfos = new ArrayList<>();

    for (Map<String, String> shortcut : shortcuts) {
      final String icon = shortcut.get("icon");
      final String type = shortcut.get("type");
      final String title = shortcut.get("localizedTitle");
      final ShortcutInfo.Builder shortcutBuilder = new ShortcutInfo.Builder(context, type);

      final int resourceId = loadResourceId(context, icon);
      final Intent intent = getIntentToOpenMainActivity(type);

      if (resourceId > 0) {
        shortcutBuilder.setIcon(Icon.createWithResource(context, resourceId));
      }

      final ShortcutInfo shortcutInfo =
          shortcutBuilder.setLongLabel(title).setShortLabel(title).setIntent(intent).build();
      shortcutInfos.add(shortcutInfo);
    }
    return shortcutInfos;
  }

  private int loadResourceId(Context context, String icon) {
    if (icon == null) {
      return 0;
    }
    final String packageName = context.getPackageName();
    final Resources res = context.getResources();
    final int resourceId = res.getIdentifier(icon, "drawable", packageName);

    if (resourceId == 0) {
      return res.getIdentifier(icon, "mipmap", packageName);
    } else {
      return resourceId;
    }
  }

  private Intent getIntentToOpenMainActivity(String type) {
    final String packageName = context.getPackageName();

    return context
        .getPackageManager()
        .getLaunchIntentForPackage(packageName)
        .setAction(Intent.ACTION_RUN)
        .putExtra(EXTRA_ACTION, type)
        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
  }

  private static class UiThreadExecutor implements Executor {
    private final Handler handler = new Handler(Looper.getMainLooper());

    @Override
    public void execute(Runnable command) {
      handler.post(command);
    }
  }
}
