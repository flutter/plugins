package io.flutter.plugins.connectivity;

import android.content.BroadcastReceiver;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.EventChannel;

/** Responsible for constructing a BroadcastReceiver as well as registering and unregistering it. */
public interface BroadcastReceiverRegistrar {

  /**
   * Triggered when it is ready for the BroadcastReceiver to be registered. Register the receiver in
   * this method body.
   *
   * @param receiver the receiver is going to be registered.
   */
  void readyToRegisterBroadcastReceiver(@NonNull BroadcastReceiver receiver);

  /**
   * Triggered when it is ready for the BroadcastReceiver to be unregistered. Unregister the
   * receiver in this method body.
   *
   * @param receiver the receiver is going to be unregistered.
   */
  void readyToUnregisterBroadcastReceiver(@NonNull BroadcastReceiver receiver);

  /**
   * Creates a Broadcast receiver.
   *
   * @param events The events helps the broadcast receiver to dump information to the event channel.
   * @return A BroadcastReceiver.
   */
  @NonNull
  BroadcastReceiver createReceiver(@NonNull final EventChannel.EventSink events);
}
