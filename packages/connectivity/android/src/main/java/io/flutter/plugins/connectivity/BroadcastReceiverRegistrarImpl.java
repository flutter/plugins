package io.flutter.plugins.connectivity;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.EventChannel;

/** The BroadcastReceiverRegistrar used for the plugin. */
public class BroadcastReceiverRegistrarImpl implements BroadcastReceiverRegistrar {
  private Context context;
  private Connectivity connectivity;

  /**
   * @param context used to register and unregister the broadcastReceiver.
   * @param connectivity used to check connectivity information.
   */
  public BroadcastReceiverRegistrarImpl(
      @NonNull Context context, @NonNull Connectivity connectivity) {
    this.context = context;
    this.connectivity = connectivity;
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
        events.success(connectivity.checkNetworkType());
      }
    };
  }
}
