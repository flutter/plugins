package io.flutter.plugins.connectivity;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.EventChannel;

/**
 * The BroadcastReceiverRegistrar used for the plugin.
 */
public class ConnectivityBroadcastReceiverRegistrar implements BroadcastReceiverRegistrar {
    private Context context;
    private ConnectivityChecker checker;

    /**
     *
     * @param context used to register and unregister the broadcastReceiver.
     * @param checker used to check connectivity information.
     */
    ConnectivityBroadcastReceiverRegistrar(@NonNull Context context, @NonNull ConnectivityChecker checker) {
        this.context = context;
        this.checker = checker;
    }

    @Override
    public void readyToRegisterBroadcastReceiver(BroadcastReceiver receiver) {
        context.registerReceiver(receiver, new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION));
    }

    @Override
    public void readyToUnregisterBroadcastReceiver(BroadcastReceiver receiver) {
        context.unregisterReceiver(receiver);
    }

    @Override
    public BroadcastReceiver createReceiver(final EventChannel.EventSink events) {
        return new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                events.success(checker.checkNetworkType());
            }
        };
    }
}
