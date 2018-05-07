package io.flutter.plugins.firebasedynamiclinks;

import android.net.Uri;

import com.google.firebase.dynamiclinks.DynamicLink;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;

import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FirebaseDynamicLinksPlugin
 */
public class FirebaseDynamicLinksPlugin implements MethodCallHandler {
  private Registrar registrar;

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(),
        "plugins.flutter.io/firebase_dynamic_links");
    channel.setMethodCallHandler(new FirebaseDynamicLinksPlugin(registrar));
  }

  FirebaseDynamicLinksPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("DynamicLinkComponents#uri")) {
      Uri uri = createDynamicLink((Map<String, Object>) call.arguments());
      result.success(uri.toString());
    } else {
      result.notImplemented();
    }
  }

  private Uri createDynamicLink(Map<String, Object> arguments) {
    DynamicLink.Builder dynamicLinkBuilder = FirebaseDynamicLinks.getInstance().createDynamicLink();

    // These two don't require null check because app should crash if these are null.
    dynamicLinkBuilder.setDynamicLinkDomain((String) arguments.get("domain"));
    dynamicLinkBuilder.setLink(Uri.parse((String) arguments.get("link")));

    Object longLink = arguments.get("longLink");
    if (longLink != null) dynamicLinkBuilder.setLongLink(Uri.parse((String) longLink));

    @SuppressWarnings("unchecked")
    Map<String, Object> androidParameters =
        (Map<String, Object>) arguments.get("androidParameters");
    if (androidParameters != null) {
      Object fallbackUri = androidParameters.get("fallbackUri");
      Object minimumVersion = androidParameters.get("minimumVersion");

      DynamicLink.AndroidParameters.Builder builder =
          new DynamicLink.AndroidParameters.Builder((String) androidParameters.get("packageName"));

      if (fallbackUri != null) builder.setFallbackUrl(Uri.parse((String) fallbackUri));
      if (minimumVersion != null) builder.setMinimumVersion((int) minimumVersion);

      dynamicLinkBuilder.setAndroidParameters(builder.build());
    }

    @SuppressWarnings("unchecked")
    Map<String, Object> googleAnalyticsParameters =
        (Map<String, Object>) arguments.get("googleAnalyticsParameters");
    if (googleAnalyticsParameters != null) {
      Object campaign = googleAnalyticsParameters.get("campaign");
      Object content = googleAnalyticsParameters.get("content");
      Object medium = googleAnalyticsParameters.get("medium");
      Object source = googleAnalyticsParameters.get("source");
      Object term = googleAnalyticsParameters.get("term");

      DynamicLink.GoogleAnalyticsParameters.Builder builder =
          new DynamicLink.GoogleAnalyticsParameters.Builder();

      if (campaign != null) builder.setCampaign((String) campaign);
      if (content != null) builder.setContent((String) content);
      if (medium != null) builder.setMedium((String) medium);
      if (source != null) builder.setSource((String) source);
      if (term != null) builder.setTerm((String) term);

      dynamicLinkBuilder.setGoogleAnalyticsParameters(builder.build());
    }

    @SuppressWarnings("unchecked")
    Map<String, Object> iosParameters = (Map<String, Object>) arguments.get("iosParameters");
    if(iosParameters != null) {
      Object appStoreId = iosParameters.get("appStoreId");
      Object customScheme = iosParameters.get("customScheme");
      Object fallbackUri = iosParameters.get("fallbackUri");
      Object ipadFallbackUri = iosParameters.get("ipadFallbackUri");
      Object minimumVersion = iosParameters.get("minimumVersion");

      DynamicLink.IosParameters.Builder builder =
          new DynamicLink.IosParameters.Builder((String) iosParameters.get("bundleId"));

      if (appStoreId != null) builder.setAppStoreId((String) appStoreId);
      if (customScheme != null) builder.setCustomScheme((String) customScheme);
      if (fallbackUri != null) builder.setFallbackUrl(Uri.parse((String) fallbackUri));
      if (ipadFallbackUri != null) builder.setIpadBundleId((String) ipadFallbackUri);
      if (minimumVersion != null) builder.setMinimumVersion((String) minimumVersion);

      dynamicLinkBuilder.setIosParameters(builder.build());
    }

    @SuppressWarnings("unchecked")
    Map<String, Object> itunesConnectAnalyticsParameters =
        (Map<String, Object>) arguments.get("itunesConnectAnalyticsParameters");
    if(itunesConnectAnalyticsParameters != null) {
      Object affiliateToken = itunesConnectAnalyticsParameters.get("affiliateToken");
      Object campaignToken = itunesConnectAnalyticsParameters.get("campaignToken");
      Object providerToken = itunesConnectAnalyticsParameters.get("providerToken");

      DynamicLink.ItunesConnectAnalyticsParameters.Builder builder =
          new DynamicLink.ItunesConnectAnalyticsParameters.Builder();

      if (affiliateToken != null) builder.setAffiliateToken((String) affiliateToken);
      if (campaignToken != null) builder.setCampaignToken((String) campaignToken);
      if (providerToken != null) builder.setProviderToken((String) providerToken);

      dynamicLinkBuilder.setItunesConnectAnalyticsParameters(builder.build());
    }

    @SuppressWarnings("unchecked")
    Map<String, Object> navigationInfoParameters =
        (Map<String, Object>) arguments.get("navigationInfoParameters");
    if (navigationInfoParameters != null) {
      Object forcedRedirectEnabled = navigationInfoParameters.get("forcedRedirectEnabled");

      DynamicLink.NavigationInfoParameters.Builder builder =
          new DynamicLink.NavigationInfoParameters.Builder();

      if (forcedRedirectEnabled != null) {
        builder.setForcedRedirectEnabled((boolean) forcedRedirectEnabled);
      }

      dynamicLinkBuilder.setNavigationInfoParameters(builder.build());
    }

    @SuppressWarnings("unchecked")
    Map<String, Object> socialMetaTagParameters =
        (Map<String, Object>) arguments.get("socialMetaTagParameters");
    if (socialMetaTagParameters != null) {
      Object description = socialMetaTagParameters.get("description");
      Object imageUrl = socialMetaTagParameters.get("description");
      Object title = socialMetaTagParameters.get("title");

      DynamicLink.SocialMetaTagParameters.Builder builder =
          new DynamicLink.SocialMetaTagParameters.Builder();

      if (description != null) builder.setDescription((String) description);
      if (imageUrl != null) builder.setImageUrl(Uri.parse((String) imageUrl));
      if (title != null) builder.setTitle((String) title);

      dynamicLinkBuilder.setSocialMetaTagParameters(builder.build());
    }

    return dynamicLinkBuilder.buildDynamicLink().getUri();
  }
}
