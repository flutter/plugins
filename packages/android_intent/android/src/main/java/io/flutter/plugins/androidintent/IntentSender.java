package io.flutter.plugins.androidintent;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Bundle;
import android.os.Parcelable;
import android.text.TextUtils;
import android.util.Log;
import androidx.annotation.Nullable;
import java.util.ArrayList;
import java.util.List;

/** Forms and launches intents. */
public final class IntentSender {
  private static final String TAG = "IntentSender";

  @Nullable private Activity activity;
  @Nullable private Context applicationContext;

  /**
   * Caches the given {@code activity} and {@code applicationContext} to use for sending intents
   * later.
   *
   * <p>Either may be null initially, but at least {@code applicationContext} should be set before
   * calling {@link #send}.
   *
   * <p>See also {@link #setActivity}, {@link #setApplicationContext}, and {@link #send}.
   */
  public IntentSender(@Nullable Activity activity, @Nullable Context applicationContext) {
    this.activity = activity;
    this.applicationContext = applicationContext;
  }

  /**
   * Creates and launches an intent with the given params using the cached {@link Activity} and
   * {@link Context}.
   *
   * <p>This will fail to create and send the intent if {@code applicationContext} hasn't been set
   * at the time of calling.
   *
   * <p>This uses {@code activity} to start the intent whenever it's not null. Otherwise it falls
   * back to {@code applicationContext} and adds {@link Intent#FLAG_ACTIVITY_NEW_TASK} to the intent
   * before launching it.
   */
  void send(Intent intent) {
    if (applicationContext == null) {
      Log.wtf(TAG, "Trying to send an intent before the applicationContext was initialized.");
      return;
    }

    Log.v(TAG, "Sending intent " + intent);

    if (activity != null) {
      activity.startActivity(intent);
    } else {
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      applicationContext.startActivity(intent);
    }
  }

  /**
   * Verifies the given intent and returns whether the application context class can resolve it.
   *
   * <p>This will fail to create and send the intent if {@code applicationContext} hasn't been set *
   * at the time of calling.
   *
   * <p>This currently only supports resolving activities.
   *
   * @param intent Fully built intent.
   * @see #buildIntent(String, Integer, String, Uri, Bundle, String, ComponentName, List, Boolean,
   *     String)
   * @return Whether the package manager found {@link android.content.pm.ResolveInfo} using its
   *     {@link PackageManager#resolveActivity(Intent, int)} method.
   */
  boolean canResolveActivity(Intent intent) {
    if (applicationContext == null) {
      Log.wtf(TAG, "Trying to resolve an activity before the applicationContext was initialized.");
      return false;
    }

    final PackageManager packageManager = applicationContext.getPackageManager();

    return packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY) != null;
  }

  /** Caches the given {@code activity} to use for {@link #send}. */
  void setActivity(@Nullable Activity activity) {
    this.activity = activity;
  }

  /** Caches the given {@code applicationContext} to use for {@link #send}. */
  void setApplicationContext(@Nullable Context applicationContext) {
    this.applicationContext = applicationContext;
  }

  /**
   * Constructs a new intent with the data specified.
   *
   * @param action the Intent action, such as {@code ACTION_VIEW}.
   * @param flags forwarded to {@link Intent#addFlags(int)} if non-null.
   * @param category forwarded to {@link Intent#addCategory(String)} if non-null.
   * @param data forwarded to {@link Intent#setData(Uri)} if non-null and 'type' parameter is null.
   *     If both 'data' and 'type' is non-null they're forwarded to {@link
   *     Intent#setDataAndType(Uri, String)}
   * @param arguments forwarded to {@link Intent#putExtras(Bundle)} if non-null.
   * @param packageName forwarded to {@link Intent#setPackage(String)} if non-null. This is forced
   *     to null if it can't be resolved.
   * @param componentName forwarded to {@link Intent#setComponent(ComponentName)} if non-null.
   * @param ignoredPackages list of package names that should not by displayed in the chooser and
   *     should not be used to resolve this intent.
   * @param showChooser forces to show the default selection dialog.
   * @param type forwarded to {@link Intent#setType(String)} if non-null and 'data' parameter is
   *     null. If both 'data' and 'type' is non-null they're forwarded to {@link
   *     Intent#setDataAndType(Uri, String)}
   * @return Fully built intent.
   */
  Intent buildIntent(
      @Nullable String action,
      @Nullable Integer flags,
      @Nullable String category,
      @Nullable Uri data,
      @Nullable Bundle arguments,
      @Nullable String packageName,
      @Nullable ComponentName componentName,
      @Nullable List<String> ignoredPackages,
      @Nullable Boolean showChooser,
      @Nullable String type) {
    if (applicationContext == null) {
      Log.wtf(TAG, "Trying to build an intent before the applicationContext was initialized.");
      return null;
    }
    showChooser = showChooser != null && showChooser;

    Intent intent = new Intent();

    if (action != null) {
      intent.setAction(action);
    }
    if (flags != null) {
      intent.addFlags(flags);
    }
    if (!TextUtils.isEmpty(category)) {
      intent.addCategory(category);
    }
    if (data != null && type == null) {
      intent.setData(data);
    }
    if (type != null && data == null) {
      intent.setType(type);
    }
    if (type != null && data != null) {
      intent.setDataAndType(data, type);
    }
    if (arguments != null) {
      intent.putExtras(arguments);
    }
    if (!TextUtils.isEmpty(packageName)) {
      intent.setPackage(packageName);
      if (componentName != null) {
        intent.setComponent(componentName);
      }
      if (intent.resolveActivity(applicationContext.getPackageManager()) == null) {
        Log.i(TAG, "Cannot resolve explicit intent - ignoring package");
        intent.setPackage(null);
      }
    }
    Boolean needIgnore = ignoredPackages != null && ignoredPackages.size() > 0;
    if (needIgnore || showChooser) {
      PackageManager packageManager;
      if (activity != null) {
        packageManager = activity.getPackageManager();
      } else {
        packageManager = applicationContext.getPackageManager();
      }
      List<ResolveInfo> activities = packageManager.queryIntentActivities(intent, 0);
      ArrayList<Intent> targetIntents = new ArrayList<Intent>();

      if (needIgnore) {
        for (ResolveInfo currentInfo : activities) {
          if (ignoredPackages.indexOf(currentInfo.activityInfo.packageName) == -1) {
            Intent targetIntent = new Intent(intent);
            targetIntent.setPackage(currentInfo.activityInfo.packageName);
            targetIntents.add(targetIntent);
          }
        }
      }

      if (!showChooser) {
        String packageToLaunch;
        try {
          if (ignoredPackages != null) {
            packageToLaunch = targetIntents.get(0).getPackage();
          } else {
            packageToLaunch = activities.get(0).activityInfo.packageName;
          }
          intent.setPackage(packageToLaunch);
          Log.v(TAG, "Resolve this intent with package: " + packageToLaunch);
        } catch (IndexOutOfBoundsException exception) {
          Log.v(TAG, "Not found packages to resolve this intent: " + exception);
        }
      } else {
        intent = Intent.createChooser(targetIntents.remove(0), "");
        intent.putExtra(Intent.EXTRA_INITIAL_INTENTS, targetIntents.toArray(new Parcelable[] {}));
      }
    }

    return intent;
  }
}
