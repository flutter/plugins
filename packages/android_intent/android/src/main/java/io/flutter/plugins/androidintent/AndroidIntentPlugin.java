package io.flutter.plugins.androidintent;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

/**
 * Plugin implementation that uses the new {@code io.flutter.embedding} package.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public final class AndroidIntentPlugin implements FlutterPlugin, ActivityAware {
  private final IntentSender sender;
  private final MethodCallHandlerImpl impl;

  /**
   * Initialize this within the {@code #configureFlutterEngine} of a Flutter activity or fragment.
   *
   * <p>See {@code io.flutter.plugins.androidintentexample.MainActivity} for an example.
   */
  public AndroidIntentPlugin() {
    sender = new IntentSender(/*activity=*/ null, /*applicationContext=*/ null);
    impl = new MethodCallHandlerImpl(sender);
  }

  /**
   * Registers a plugin implementation that uses the stable {@code io.flutter.plugin.common}
   * package.
   *
   * <p>Calling this automatically initializes the plugin. However plugins initialized this way
   * won't react to changes in activity or context, unlike {@link AndroidIntentPlugin}.
   */
  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    IntentSender sender = new IntentSender(registrar.activity(), registrar.context());
    MethodCallHandlerImpl impl = new MethodCallHandlerImpl(sender);
    impl.startListening(registrar.messenger());
  }


  private String convertAction(String action) {
    switch (action) {
      case "action_view":
        return Intent.ACTION_VIEW;
      case "action_voice":
        return Intent.ACTION_VOICE_COMMAND;
      case "settings":
        return Settings.ACTION_SETTINGS;
      case "action_location_source_settings":
        return Settings.ACTION_LOCATION_SOURCE_SETTINGS;
      case "action_add_account":
        return Settings.ACTION_ADD_ACCOUNT;
      case "action_apn_settings":
        return Settings.ACTION_APN_SETTINGS;
      case "action_accessibility_settings":
        return Settings.ACTION_ACCESSIBILITY_SETTINGS;
      case "action_airplane_mode_settings":
        return Settings.ACTION_AIRPLANE_MODE_SETTINGS;
      case "action_application_development_settings":
        return Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS;
      case "action_application_settings":
        return Settings.ACTION_APPLICATION_SETTINGS;
      case "action_app_notification_settings":
        return Settings.ACTION_APP_NOTIFICATION_SETTINGS;
      case "action_data_usage_settings":
        return Settings.ACTION_DATA_USAGE_SETTINGS;
      case "action_battery_saver_settings":
        return Settings.ACTION_BATTERY_SAVER_SETTINGS;
      case "action_bluetooth_settings":
        return Settings.ACTION_BLUETOOTH_SETTINGS;
      case "action_captioning_settings":
        return Settings.ACTION_CAPTIONING_SETTINGS;
      case "action_cast_settings":
        return Settings.ACTION_CAST_SETTINGS;
      case "action_channel_notification_settings":
        return Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS;
      case "action_data_roaming_settings":
        return Settings.ACTION_DATA_ROAMING_SETTINGS;
      case "action_date_settings":
        return Settings.ACTION_DATE_SETTINGS;
      case "action_device_info_settings":
        return Settings.ACTION_DEVICE_INFO_SETTINGS;
      case "action_display_settings":
        return Settings.ACTION_DISPLAY_SETTINGS;
      case "action_dream_settings":
        return Settings.ACTION_DREAM_SETTINGS;
      case "action_fingerprint_enroll":
        return Settings.ACTION_FINGERPRINT_ENROLL;
      case "action_hard_keyboard_settings":
        return Settings.ACTION_HARD_KEYBOARD_SETTINGS;
      case "action_home_settings":
        return Settings.ACTION_HOME_SETTINGS;
      case "action_ignore_background_data_restrictions_settings":
        return Settings.ACTION_IGNORE_BACKGROUND_DATA_RESTRICTIONS_SETTINGS;
      case "action_ignore_battery_optimization_settings":
        return Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS;
      case "action_input_method_settings":
        return Settings.ACTION_INPUT_METHOD_SETTINGS;
      case "action_input_method_subtype_settings":
        return Settings.ACTION_INPUT_METHOD_SUBTYPE_SETTINGS;
      case "action_internal_storage_settings":
        return Settings.ACTION_INTERNAL_STORAGE_SETTINGS;
      case "action_locale_settings":
        return Settings.ACTION_LOCALE_SETTINGS;
      case "action_manage_all_applications_settings":
        return Settings.ACTION_MANAGE_ALL_APPLICATIONS_SETTINGS;
      case "action_manage_applications_settings":
        return Settings.ACTION_MANAGE_APPLICATIONS_SETTINGS;
      case "action_manage_default_apps_settings":
        return Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS;
      case "action_manage_unknown_app_sources":
        return Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES;
      case "action_manage_write_settings":
        return Settings.ACTION_MANAGE_WRITE_SETTINGS;
      case "action_memory_card_settings":
        return Settings.ACTION_MEMORY_CARD_SETTINGS;
      case "action_network_operator_settings":
        return Settings.ACTION_NETWORK_OPERATOR_SETTINGS;
      case "action_nfcsharing_settings":
        return Settings.ACTION_NFCSHARING_SETTINGS;
      case "action_nfc_payment_settings":
        return Settings.ACTION_NFC_PAYMENT_SETTINGS;
      case "action_nfc_settings":
        return Settings.ACTION_NFC_SETTINGS;
      case "action_night_display_settings":
        return Settings.ACTION_NIGHT_DISPLAY_SETTINGS;
      case "action_notification_listener_settings":
        return Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS;
      case "action_notification_policy_access_settings":
        return Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS;
      case "action_print_settings":
        return Settings.ACTION_PRINT_SETTINGS;
      case "action_privacy_settings":
        return Settings.ACTION_PRIVACY_SETTINGS;
      case "action_quick_launch_settings":
        return Settings.ACTION_QUICK_LAUNCH_SETTINGS;
      case "action_request_ignore_battery_optimizations":
        return Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS;
      case "action_request_set_autofill_service":
        return Settings.ACTION_REQUEST_SET_AUTOFILL_SERVICE;
      case "action_search_settings":
        return Settings.ACTION_SEARCH_SETTINGS;
      case "action_security_settings":
        return Settings.ACTION_SECURITY_SETTINGS;
      case "action_settings":
        return Settings.ACTION_SETTINGS;
      case "action_show_regulatory_info":
        return Settings.ACTION_SHOW_REGULATORY_INFO;
      case "action_sound_settings":
        return Settings.ACTION_SOUND_SETTINGS;
      case "action_storage_volume_access_settings":
        return Settings.ACTION_STORAGE_VOLUME_ACCESS_SETTINGS;
      case "action_application_details_settings":
        return Settings.ACTION_APPLICATION_DETAILS_SETTINGS;
      case "action_sync_settings":
        return Settings.ACTION_SYNC_SETTINGS;
      case "action_usage_access_settings":
        return Settings.ACTION_USAGE_ACCESS_SETTINGS;
      case "action_user_dictionary_settings":
        return Settings.ACTION_USER_DICTIONARY_SETTINGS;
      case "action_voice_control_airplane_mode":
        return Settings.ACTION_VOICE_CONTROL_AIRPLANE_MODE;
      case "action_voice_control_battery_saver_mode":
        return Settings.ACTION_VOICE_CONTROL_BATTERY_SAVER_MODE;
      case "action_voice_control_do_not_disturb_mode":
        return Settings.ACTION_VOICE_CONTROL_DO_NOT_DISTURB_MODE;
      case "action_voice_input_settings":
        return Settings.ACTION_VOICE_INPUT_SETTINGS;
      case "action_vpn_settings":
        return Settings.ACTION_VPN_SETTINGS;
      case "action_vr_listener_settings":
        return Settings.ACTION_VR_LISTENER_SETTINGS;
      case "action_webview_settings":
        return Settings.ACTION_WEBVIEW_SETTINGS;
      case "action_wifi_ip_settings":
        return Settings.ACTION_WIFI_IP_SETTINGS;
      case "action_wifi_settings":
        return Settings.ACTION_WIFI_SETTINGS;
      case "action_wireless_settings":
        return Settings.ACTION_WIRELESS_SETTINGS;
      case "action_zen_mode_priority_settings":
        return Settings.ACTION_ZEN_MODE_PRIORITY_SETTINGS;
      case "action_edit":
        return Intent.ACTION_EDIT;
      case "action_call":
        return Intent.ACTION_CALL;
      default:
        return action;
    }
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    sender.setApplicationContext(binding.getApplicationContext());
    sender.setActivity(null);
    impl.startListening(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    sender.setApplicationContext(null);
    sender.setActivity(null);
    impl.stopListening();
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    sender.setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    sender.setActivity(null);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }
}
