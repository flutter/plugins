package io.flutter.plugins.firebasedynamiclinks;

import android.net.Uri;
import android.support.annotation.NonNull;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.dynamiclinks.DynamicLink;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.ShortDynamicLink;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** FirebaseDynamicLinksPlugin */
public class FirebaseDynamicLinksPlugin implements MethodCallHandler {
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_dynamic_links");
    channel.setMethodCallHandler(new FirebaseDynamicLinksPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "DynamicLinkComponents#url":
        DynamicLink.Builder urlBuilder = setupParameters(call);
        result.success(urlBuilder.buildDynamicLink().getUri().toString());
        break;
      case "DynamicLinkComponents#shortLink":
        DynamicLink.Builder shortLinkBuilder = setupParameters(call);
        buildShortDynamicLink(shortLinkBuilder, call, createShortLinkListener(result));
        break;
      case "DynamicLinkComponents#shortenUrl":
        DynamicLink.Builder builder = FirebaseDynamicLinks.getInstance().createDynamicLink();

        Uri url = Uri.parse((String) call.argument("url"));
        builder.setLongLink(url);
        buildShortDynamicLink(builder, call, createShortLinkListener(result));
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private OnCompleteListener<ShortDynamicLink> createShortLinkListener(final Result result) {
    return new OnCompleteListener<ShortDynamicLink>() {
      @Override
      public void onComplete(@NonNull Task<ShortDynamicLink> task) {
        if (task.isSuccessful()) {
          Map<String, Object> url = new HashMap<>();
          url.put("url", task.getResult().getShortLink().toString());

          List<String> warnings = new ArrayList<>();
          for (ShortDynamicLink.Warning warning : task.getResult().getWarnings()) {
            warnings.add(warning.getMessage());
          }
          url.put("warnings", warnings);

          result.success(url);
        } else {
          Exception exception = task.getException();
          String errMsg = "Unable to create short link";
          if (exception != null && exception.getLocalizedMessage() != null) {
            errMsg = exception.getLocalizedMessage();
          }
          result.error("short_link_error", errMsg, null);
        }
      }
    };
  }

  private void buildShortDynamicLink(
      DynamicLink.Builder builder, MethodCall call, OnCompleteListener<ShortDynamicLink> listener) {
    Integer suffix = null;

    Map<String, Object> dynamicLinkComponentsOptions =
        call.argument("dynamicLinkComponentsOptions");
    if (dynamicLinkComponentsOptions != null) {
      Object shortDynamicLinkPathLength =
          dynamicLinkComponentsOptions.get("shortDynamicLinkPathLength");
      if (shortDynamicLinkPathLength != null) {
        switch ((int) shortDynamicLinkPathLength) {
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

    if (suffix != null) {
      builder.buildShortDynamicLink(suffix).addOnCompleteListener(listener);
    } else {
      builder.buildShortDynamicLink().addOnCompleteListener(listener);
    }
  }

  private DynamicLink.Builder setupParameters(MethodCall call) {
    DynamicLink.Builder dynamicLinkBuilder = FirebaseDynamicLinks.getInstance().createDynamicLink();

    dynamicLinkBuilder.setDynamicLinkDomain((String) call.argument("domain"));
    dynamicLinkBuilder.setLink(Uri.parse((String) call.argument("link")));

    Map<String, Object> androidParameters = call.argument("androidParameters");
    if (androidParameters != null) {
      DynamicLink.AndroidParameters.Builder builder =
          new DynamicLink.AndroidParameters.Builder((String) androidParameters.get("packageName"));

      String fallbackUrl = (String) androidParameters.get("fallbackUrl");
      Integer minimumVersion = (Integer) androidParameters.get("minimumVersion");

      if (fallbackUrl != null) builder.setFallbackUrl(Uri.parse(fallbackUrl));
      if (minimumVersion != null) builder.setMinimumVersion(minimumVersion);

      dynamicLinkBuilder.setAndroidParameters(builder.build());
    }

    Map<String, Object> googleAnalyticsParameters = call.argument("googleAnalyticsParameters");
    if (googleAnalyticsParameters != null) {
      String campaign = (String) googleAnalyticsParameters.get("campaign");
      String content = (String) googleAnalyticsParameters.get("content");
      String medium = (String) googleAnalyticsParameters.get("medium");
      String source = (String) googleAnalyticsParameters.get("source");
      String term = (String) googleAnalyticsParameters.get("term");

      DynamicLink.GoogleAnalyticsParameters.Builder builder =
          new DynamicLink.GoogleAnalyticsParameters.Builder();

      if (campaign != null) builder.setCampaign(campaign);
      if (content != null) builder.setContent(content);
      if (medium != null) builder.setMedium(medium);
      if (source != null) builder.setSource(source);
      if (term != null) builder.setTerm(term);

      dynamicLinkBuilder.setGoogleAnalyticsParameters(builder.build());
    }

    Map<String, Object> iosParameters = call.argument("iosParameters");
    if (iosParameters != null) {
      String appStoreId = (String) iosParameters.get("appStoreId");
      String customScheme = (String) iosParameters.get("customScheme");
      String fallbackUrl = (String) iosParameters.get("fallbackUrl");
      String ipadBundleId = (String) iosParameters.get("ipadBundleId");
      String ipadFallbackUrl = (String) iosParameters.get("ipadFallbackUrl");
      String minimumVersion = (String) iosParameters.get("minimumVersion");

      DynamicLink.IosParameters.Builder builder =
          new DynamicLink.IosParameters.Builder((String) iosParameters.get("bundleId"));

      if (appStoreId != null) builder.setAppStoreId(appStoreId);
      if (customScheme != null) builder.setCustomScheme(customScheme);
      if (fallbackUrl != null) builder.setFallbackUrl(Uri.parse(fallbackUrl));
      if (ipadBundleId != null) builder.setIpadBundleId(ipadBundleId);
      if (ipadFallbackUrl != null) builder.setIpadFallbackUrl(Uri.parse(ipadFallbackUrl));
      if (minimumVersion != null) builder.setMinimumVersion(minimumVersion);

      dynamicLinkBuilder.setIosParameters(builder.build());
    }

    Map<String, Object> itunesConnectAnalyticsParameters =
        call.argument("itunesConnectAnalyticsParameters");
    if (itunesConnectAnalyticsParameters != null) {
      String affiliateToken = (String) itunesConnectAnalyticsParameters.get("affiliateToken");
      String campaignToken = (String) itunesConnectAnalyticsParameters.get("campaignToken");
      String providerToken = (String) itunesConnectAnalyticsParameters.get("providerToken");

      DynamicLink.ItunesConnectAnalyticsParameters.Builder builder =
          new DynamicLink.ItunesConnectAnalyticsParameters.Builder();

      if (affiliateToken != null) builder.setAffiliateToken(affiliateToken);
      if (campaignToken != null) builder.setCampaignToken(campaignToken);
      if (providerToken != null) builder.setProviderToken(providerToken);

      dynamicLinkBuilder.setItunesConnectAnalyticsParameters(builder.build());
    }

    Map<String, Object> navigationInfoParameters = call.argument("navigationInfoParameters");
    if (navigationInfoParameters != null) {
      Boolean forcedRedirectEnabled =
          (Boolean) navigationInfoParameters.get("forcedRedirectEnabled");

      DynamicLink.NavigationInfoParameters.Builder builder =
          new DynamicLink.NavigationInfoParameters.Builder();

      if (forcedRedirectEnabled != null) {
        builder.setForcedRedirectEnabled(forcedRedirectEnabled);
      }

      dynamicLinkBuilder.setNavigationInfoParameters(builder.build());
    }

    Map<String, Object> socialMetaTagParameters = call.argument("socialMetaTagParameters");
    if (socialMetaTagParameters != null) {
      String description = (String) socialMetaTagParameters.get("description");
      String imageUrl = (String) socialMetaTagParameters.get("imageUrl");
      String title = (String) socialMetaTagParameters.get("title");

      DynamicLink.SocialMetaTagParameters.Builder builder =
          new DynamicLink.SocialMetaTagParameters.Builder();

      if (description != null) builder.setDescription(description);
      if (imageUrl != null) builder.setImageUrl(Uri.parse(imageUrl));
      if (title != null) builder.setTitle(title);

      dynamicLinkBuilder.setSocialMetaTagParameters(builder.build());
    }

    return dynamicLinkBuilder;
  }
}
