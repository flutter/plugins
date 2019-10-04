package io.flutter.plugins.connectivity;

import android.content.BroadcastReceiver;
import androidx.annotation.NonNull;

import io.flutter.plugin.common.EventChannel;

/**
 * Handles the event channel for the plugin.
 */
public class ConnectivityEventChannelHandler implements EventChannel.StreamHandler {
    private final BroadcastReceiverRegistrar broadcastReceiverRegistrar;
    private BroadcastReceiver broadcastReceiver;

    /** Constructs a ConnectivityEventChannelHandler
     *
     * @param broadcastReceiverRegistrar handling registration of the broadcastReceiver.
     */
    public ConnectivityEventChannelHandler( @NonNull BroadcastReceiverRegistrar broadcastReceiverRegistrar) {
        this.broadcastReceiverRegistrar = broadcastReceiverRegistrar;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        broadcastReceiver = broadcastReceiverRegistrar.createReceiver(events);
        broadcastReceiverRegistrar.readyToRegisterBroadcastReceiver(broadcastReceiver);
    }

    @Override
    public void onCancel(Object arguments) {
        broadcastReceiverRegistrar.readyToUnregisterBroadcastReceiver(broadcastReceiver);
        broadcastReceiver = null;
    }
}