package io.flutter.plugins.firebasedynamiclinks;

import android.net.Uri;
import android.support.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.dynamiclinks.DynamicLink;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.ShortDynamicLink;

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
    if (call.method.equals("DynamicLinkComponents#url")) {
      DynamicLink.Builder builder = setupParameters((Map<String, Object>) call.arguments());
      result.success(builder.buildDynamicLink().getUri().toString());
    } else if (call.method.equals("DynamicLinkComponents#shortUrl")) {
      Map<String, Object> arguments = (Map<String, Object>) call.arguments();
      DynamicLink.Builder builder = setupParameters(arguments);
      buildShortDynamicLink(builder, (Map<String, Object>) call.arguments(), result);
    } else if (call.method.equals("DynamicLinkComponents#shortenUrl")) {
      Map<String, Object> arguments = (Map<String, Object>) call.arguments();
      DynamicLink.Builder builder = FirebaseDynamicLinks.getInstance().createDynamicLink();
      Uri url = Uri.parse((String) arguments.get("url"));
      builder.setLongLink(url);
      buildShortDynamicLink(builder, arguments, result);
    } else {
      result.notImplemented();
    }
  }

  private void buildShortDynamicLink(DynamicLink.Builder builder, Map<String, Object> arguments, final Result result) {
    Integer suffix = null;

    @SuppressWarnings("unchecked")
    Map<String, Object> dynamicLinkComponentsOptions =
        (Map<String, Object>) arguments.get("dynamicLinkComponentsOptions");
    if (dynamicLinkComponentsOptions != null) {
      Object shortDynamicLinkPathLength = dynamicLinkComponentsOptions.get("shortDynamicLinkPathLength");

      if (shortDynamicLinkPathLength != null) {
        switch((int) shortDynamicLinkPathLength) {
          case 0:
            suffix = ShortDynamicLink.Suffix.UNGUESSABLE;
            break;
          case 1:
            suffix = ShortDynamicLink.Suffix.SHORT;
            break;
          default:
            break;
        }
      }
    }

    OnCompleteListener<ShortDynamicLink> onCompleteListener = new OnCompleteListener<ShortDynamicLink>() {
      @Override
      public void onComplete(@NonNull Task<ShortDynamicLink> task) {
        result.success(task.getResult().getShortLink().toString());
      }
    };

    if (suffix != null) {
      builder.buildShortDynamicLink(suffix).addOnCompleteListener(onCompleteListener);
    } else {
      builder.buildShortDynamicLink().addOnCompleteListener(onCompleteListener);
    }
  }

  private DynamicLink.Builder setupParameters(Map<String, Object> arguments) {
    DynamicLink.Builder dynamicLinkBuilder = FirebaseDynamicLinks.getInstance().createDynamicLink();

    // These two don't require null check because app should crash if these are null.
    dynamicLinkBuilder.setDynamicLinkDomain((String) arguments.get("domain"));
    dynamicLinkBuilder.setLink(Uri.parse((String) arguments.get("link")));

    @SuppressWarnings("unchecked")
    Map<String, Object> androidParameters =
        (Map<String, Object>) arguments.get("androidParameters");
    if (androidParameters != null) {
      DynamicLink.AndroidParameters.Builder builder =
          new DynamicLink.AndroidParameters.Builder((String) androidParameters.get("packageName"));

      Object fallbackUrl = androidParameters.get("fallbackUrl");
      Object minimumVersion = androidParameters.get("minimumVersion");

      if (fallbackUrl != null) builder.setFallbackUrl(Uri.parse((String) fallbackUrl));
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
      Object fallbackUrl = iosParameters.get("fallbackUrl");
      Object ipadBundleId = iosParameters.get("ipadBundleId");
      Object ipadFallbackUrl = iosParameters.get("ipadFallbackUrl");
      Object minimumVersion = iosParameters.get("minimumVersion");

      DynamicLink.IosParameters.Builder builder =
          new DynamicLink.IosParameters.Builder((String) iosParameters.get("bundleId"));

      if (appStoreId != null) builder.setAppStoreId((String) appStoreId);
      if (customScheme != null) builder.setCustomScheme((String) customScheme);
      if (fallbackUrl != null) builder.setFallbackUrl(Uri.parse((String) fallbackUrl));
      if (ipadBundleId != null) builder.setIpadBundleId((String) ipadBundleId);
      if (ipadFallbackUrl != null) builder.setIpadFallbackUrl(Uri.parse((String) ipadFallbackUrl));
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
      Object imageUrl = socialMetaTagParameters.get("imageUrl");
      Object title = socialMetaTagParameters.get("title");

      DynamicLink.SocialMetaTagParameters.Builder builder =
          new DynamicLink.SocialMetaTagParameters.Builder();

      if (description != null) builder.setDescription((String) description);
      if (imageUrl != null) builder.setImageUrl(Uri.parse((String) imageUrl));
      if (title != null) builder.setTitle((String) title);

      dynamicLinkBuilder.setSocialMetaTagParameters(builder.build());
    }

    return dynamicLinkBuilder;
  }
}
