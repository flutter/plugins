package io.flutter.plugins.firebasemessaging;

import android.app.ActivityManager;
import android.app.KeyguardManager;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Process;

import java.util.List;

/**
 * Created by Ivan Kuznetsov
 * on 04/12/2018.
 */
public class FlutterFirebaseMessagingUtils {

    private static final String DATA_MESSAGES_KEY = "flutter.firebase.data.message";

    public static boolean isDataMessages(Context context) {
        try {
            ApplicationInfo info = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
            Bundle bundle = info.metaData;
            return bundle.getBoolean(DATA_MESSAGES_KEY);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean isApplicationForeground(Context context) {
        KeyguardManager keyguardManager = (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);

        if (keyguardManager.inKeyguardRestrictedInputMode()) {
            return false;
        }
        int myPid = Process.myPid();

        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);

        List<ActivityManager.RunningAppProcessInfo> list;

        if ((list = activityManager.getRunningAppProcesses()) != null) {
            for (ActivityManager.RunningAppProcessInfo aList : list) {
                ActivityManager.RunningAppProcessInfo info;
                if ((info = aList).pid == myPid) {
                    return info.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND;
                }
            }
        }
        return false;
    }
}
