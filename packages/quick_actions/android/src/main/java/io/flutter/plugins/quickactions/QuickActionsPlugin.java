// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.quickactions;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ShortcutInfo;
import android.content.pm.ShortcutManager;
import android.content.res.Resources;
import android.graphics.drawable.Icon;
import android.os.Build;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** QuickActionsPlugin */
public class QuickActionsPlugin implements MethodCallHandler {
  private static final String CHANNEL_ID = "plugins.flutter.io/quick_actions";
  private static final String EXTRA_ACTION = "some unique action key";

  private final Registrar registrar;

  private QuickActionsPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  /**
   * Plugin registration.
   *
   * <p>Must be called when the application is created.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_ID);
    channel.setMethodCallHandler(new QuickActionsPlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
      // We already know that this functionality does not work for anything
      // lower than API 25 so we chose not to return error. Instead we do nothing.
      result.success(null);
      return;
    }
    Context context = registrar.context();
    ShortcutManager shortcutManager =
        (ShortcutManager) context.getSystemService(Context.SHORTCUT_SERVICE);
    switch (call.method) {
      case "setShortcutItems":
        List<Map<String, String>> serializedShortcuts = call.arguments();
        List<ShortcutInfo> shortcuts = deserializeShortcuts(serializedShortcuts);
        shortcutManager.setDynamicShortcuts(shortcuts);
        break;
      case "clearShortcutItems":
        shortcutManager.removeAllDynamicShortcuts();
        break;
      case "getLaunchAction":
        final Intent intent = registrar.activity().getIntent();
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
    final Context context = registrar.context();

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
    final Context context = registrar.context();
    final String packageName = context.getPackageName();

    return context
        .getPackageManager()
        .getLaunchIntentForPackage(packageName)
        .setAction(Intent.ACTION_RUN)
        .putExtra(EXTRA_ACTION, type)
        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
  }
}
