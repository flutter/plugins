// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasemessagingexample;


import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.BitmapFactory;
import android.media.RingtoneManager;
import android.net.Uri;
import android.text.TextUtils;

import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;

import com.google.firebase.messaging.RemoteMessage;

import java.util.Map;

public class FlutterBackgroundMessagesReceiver extends BroadcastReceiver {

    private static final String DEFAULT_CHANNEL_ID = "default";
    public static final String EXTRA_REMOTE_MESSAGE = "notification";

    @Override
    public void onReceive(Context context, Intent intent) {
        showNotification(context, intent);
    }

    private void showNotification(Context context, Intent intent) {
        RemoteMessage remoteMessage = intent.getParcelableExtra(EXTRA_REMOTE_MESSAGE);

        Map<String, String> data = remoteMessage.getData();

        String title = data.get("title");
        String body = data.get("body");

        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

        setupNotificationChannel(notificationManager);

        Intent messageDataIntent = new Intent("FLUTTER_NOTIFICATION_CLICK");
        messageDataIntent.setPackage(context.getPackageName());
        for (Map.Entry<String, String> entry : data.entrySet()) {
            String key = entry.getKey();
            String value = entry.getValue();
            messageDataIntent.putExtra(key, value);
        }

        PendingIntent pendingIntent = PendingIntent.getActivity(context, 123, messageDataIntent, 0);

        Resources resources = context.getResources();

        int iconId = resources.getIdentifier("ic_launcher", "mipmap", context.getPackageName());
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, DEFAULT_CHANNEL_ID)
                .setColor(ContextCompat.getColor(context, android.R.color.black))
                .setSmallIcon(iconId)
                .setLargeIcon(BitmapFactory.decodeResource(context.getResources(), iconId))
                .setAutoCancel(true)
                .setContentIntent(pendingIntent);

        if (TextUtils.isEmpty(title)) {
            CharSequence appLabel = context.getApplicationInfo().loadLabel(context.getPackageManager());
            builder.setContentTitle(appLabel);
        } else {
            builder.setContentTitle(title);
        }

        if (!TextUtils.isEmpty(body)) {
            builder.setStyle((new NotificationCompat.BigTextStyle()).bigText(body))
                    .setContentText(body);
        }

        Uri uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        builder.setSound(uri);
        notificationManager.notify(System.currentTimeMillis() + "", 0, builder.build());
    }

    private void setupNotificationChannel(NotificationManager notificationManager) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            if (notificationManager.getNotificationChannel(DEFAULT_CHANNEL_ID) != null) {
                return;
            }

            NotificationChannel channel = new NotificationChannel(DEFAULT_CHANNEL_ID, "Primary Channel", NotificationManager.IMPORTANCE_HIGH);
            channel.enableLights(true);
            channel.enableVibration(true);
            channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);
            notificationManager.createNotificationChannel(channel);
        }
    }
}
