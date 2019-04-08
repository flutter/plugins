#import "FirebaseDynamicLinksPlugin.h"

#import "Firebase/Firebase.h"

static FlutterError *getFlutterError(NSError *error) {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
                             message:error.domain
                             details:error.localizedDescription];
}

@interface FLTFirebaseDynamicLinksPlugin ()
@property(nonatomic, retain) FIRDynamicLink *dynamicLink;
@property(nonatomic, retain) FlutterError *flutterError;
@end

@implementation FLTFirebaseDynamicLinksPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_dynamic_links"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseDynamicLinksPlugin *instance = [[FLTFirebaseDynamicLinksPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  [registrar addApplicationDelegate:instance];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp appNamed:@"__FIRAPP_DEFAULT"]) {
      NSLog(@"Configuring the default Firebase app...");
      [FIRApp configure];
      NSLog(@"Configured the default Firebase app %@.", [FIRApp defaultApp].name);
    }
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"DynamicLinkParameters#buildUrl" isEqualToString:call.method]) {
    FIRDynamicLinkComponents *components = [self setupParameters:call.arguments];
    result([components.url absoluteString]);
  } else if ([@"DynamicLinkParameters#buildShortLink" isEqualToString:call.method]) {
    FIRDynamicLinkComponents *components = [self setupParameters:call.arguments];
    [components shortenWithCompletion:[self createShortLinkCompletion:result]];
  } else if ([@"DynamicLinkParameters#shortenUrl" isEqualToString:call.method]) {
    FIRDynamicLinkComponentsOptions *options = [self setupOptions:call.arguments];
    NSURL *url = [NSURL URLWithString:call.arguments[@"url"]];
    [FIRDynamicLinkComponents shortenURL:url
                                 options:options
                              completion:[self createShortLinkCompletion:result]];
  } else if ([@"FirebaseDynamicLinks#retrieveDynamicLink" isEqualToString:call.method]) {
    NSMutableDictionary *dict = [self retrieveDynamicLink];
    if (dict == nil && self.flutterError) {
      result(self.flutterError);
      self.flutterError = nil;
    } else {
      result(dict);
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSMutableDictionary *)retrieveDynamicLink {
  if (_dynamicLink != nil) {
    NSMutableDictionary *dynamicLink = [[NSMutableDictionary alloc] init];
    dynamicLink[@"link"] = _dynamicLink.url.absoluteString;

    NSMutableDictionary *iosData = [[NSMutableDictionary alloc] init];
    if (_dynamicLink.minimumAppVersion) {
      iosData[@"minimumVersion"] = _dynamicLink.minimumAppVersion;
    }
    _dynamicLink = nil;
    dynamicLink[@"ios"] = iosData;
    return dynamicLink;
  } else {
    return nil;
  }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
  return [self checkForDynamicLink:url];
}

- (BOOL)application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {
  return [self checkForDynamicLink:url];
}

- (BOOL)checkForDynamicLink:(NSURL *)url {
  FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
  if (dynamicLink) {
    if (dynamicLink.url) _dynamicLink = dynamicLink;
    return YES;
  }
  return NO;
}

- (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray *))restorationHandler {
  usleep(50000);
  BOOL handled = [[FIRDynamicLinks dynamicLinks]
      handleUniversalLink:userActivity.webpageURL
               completion:^(FIRDynamicLink *_Nullable dynamicLink, NSError *_Nullable error) {
                 if (error) {
                   self.flutterError = getFlutterError(error);
                 }
                 self.dynamicLink = dynamicLink;
               }];
  return handled;
}

- (FIRDynamicLinkShortenerCompletion)createShortLinkCompletion:(FlutterResult)result {
  return ^(NSURL *_Nullable shortURL, NSArray *_Nullable warnings, NSError *_Nullable error) {
    if (error) {
      result(getFlutterError(error));
    } else {
      if (warnings == nil) {
        warnings = [NSMutableArray array];
      }
      result(@{@"url" : [shortURL absoluteString], @"warnings" : warnings});
    }
  };
}

- (FIRDynamicLinkComponentsOptions *)setupOptions:(NSDictionary *)arguments {
  FIRDynamicLinkComponentsOptions *options;
  if (![arguments[@"dynamicLinkParametersOptions"] isEqual:[NSNull null]]) {
    NSDictionary *params = arguments[@"dynamicLinkParametersOptions"];

    options = [FIRDynamicLinkComponentsOptions options];

    NSNumber *shortDynamicLinkPathLength = params[@"shortDynamicLinkPathLength"];
    if (![shortDynamicLinkPathLength isEqual:[NSNull null]]) {
      switch (shortDynamicLinkPathLength.intValue) {
        case 0:
          options.pathLength = FIRShortDynamicLinkPathLengthUnguessable;
          break;
        case 1:
          options.pathLength = FIRShortDynamicLinkPathLengthShort;
          break;
        default:
          break;
      }
    }
  }

  return options;
}

- (FIRDynamicLinkComponents *)setupParameters:(NSDictionary *)arguments {
  NSURL *link = [NSURL URLWithString:arguments[@"link"]];
  NSString *domain = arguments[@"domain"];

  FIRDynamicLinkComponents *components = [FIRDynamicLinkComponents componentsWithLink:link
                                                                               domain:domain];

  if (![arguments[@"androidParameters"] isEqual:[NSNull null]]) {
    NSDictionary *params = arguments[@"androidParameters"];

    FIRDynamicLinkAndroidParameters *androidParams =
        [FIRDynamicLinkAndroidParameters parametersWithPackageName:params[@"packageName"]];

    NSString *fallbackUrl = params[@"fallbackUrl"];
    NSNumber *minimumVersion = params[@"minimumVersion"];

    if (![fallbackUrl isEqual:[NSNull null]])
      androidParams.fallbackURL = [NSURL URLWithString:fallbackUrl];
    if (![minimumVersion isEqual:[NSNull null]])
      androidParams.minimumVersion = ((NSNumber *)minimumVersion).integerValue;

    components.androidParameters = androidParams;
  }

  if (![arguments[@"dynamicLinkComponentsOptions"] isEqual:[NSNull null]]) {
    components.options = [self setupOptions:arguments];
  }

  if (![arguments[@"googleAnalyticsParameters"] isEqual:[NSNull null]]) {
    NSDictionary *params = arguments[@"googleAnalyticsParameters"];

    FIRDynamicLinkGoogleAnalyticsParameters *googleAnalyticsParameters =
        [FIRDynamicLinkGoogleAnalyticsParameters parameters];

    NSString *campaign = params[@"campaign"];
    NSString *content = params[@"content"];
    NSString *medium = params[@"medium"];
    NSString *source = params[@"source"];
    NSString *term = params[@"term"];

    if (![campaign isEqual:[NSNull null]]) googleAnalyticsParameters.campaign = campaign;
    if (![content isEqual:[NSNull null]]) googleAnalyticsParameters.content = content;
    if (![medium isEqual:[NSNull null]]) googleAnalyticsParameters.medium = medium;
    if (![source isEqual:[NSNull null]]) googleAnalyticsParameters.source = source;
    if (![term isEqual:[NSNull null]]) googleAnalyticsParameters.term = term;

    components.analyticsParameters = googleAnalyticsParameters;
  }

  if (![arguments[@"iosParameters"] isEqual:[NSNull null]]) {
    NSDictionary *params = arguments[@"iosParameters"];

    FIRDynamicLinkIOSParameters *iosParameters =
        [FIRDynamicLinkIOSParameters parametersWithBundleID:params[@"bundleId"]];

    NSString *appStoreID = params[@"appStoreId"];
    NSString *customScheme = params[@"customScheme"];
    NSString *fallbackURL = params[@"fallbackUrl"];
    NSString *iPadBundleID = params[@"ipadBundleId"];
    NSString *iPadFallbackURL = params[@"ipadFallbackUrl"];
    NSString *minimumAppVersion = params[@"minimumVersion"];

    if (![appStoreID isEqual:[NSNull null]]) iosParameters.appStoreID = appStoreID;
    if (![customScheme isEqual:[NSNull null]]) iosParameters.customScheme = customScheme;
    if (![fallbackURL isEqual:[NSNull null]])
      iosParameters.fallbackURL = [NSURL URLWithString:fallbackURL];
    if (![iPadBundleID isEqual:[NSNull null]]) iosParameters.iPadBundleID = iPadBundleID;
    if (![iPadFallbackURL isEqual:[NSNull null]])
      iosParameters.iPadFallbackURL = [NSURL URLWithString:iPadFallbackURL];
    if (![minimumAppVersion isEqual:[NSNull null]])
      iosParameters.minimumAppVersion = minimumAppVersion;

    components.iOSParameters = iosParameters;
  }

  if (![arguments[@"itunesConnectAnalyticsParameters"] isEqual:[NSNull null]]) {
    NSDictionary *params = arguments[@"itunesConnectAnalyticsParameters"];

    FIRDynamicLinkItunesConnectAnalyticsParameters *itunesConnectAnalyticsParameters =
        [FIRDynamicLinkItunesConnectAnalyticsParameters parameters];

    NSString *affiliateToken = params[@"affiliateToken"];
    NSString *campaignToken = params[@"campaignToken"];
    NSString *providerToken = params[@"providerToken"];

    if (![affiliateToken isEqual:[NSNull null]])
      itunesConnectAnalyticsParameters.affiliateToken = affiliateToken;
    if (![campaignToken isEqual:[NSNull null]])
      itunesConnectAnalyticsParameters.campaignToken = campaignToken;
    if (![providerToken isEqual:[NSNull null]])
      itunesConnectAnalyticsParameters.providerToken = providerToken;

    components.iTunesConnectParameters = itunesConnectAnalyticsParameters;
  }

  if (![arguments[@"navigationInfoParameters"] isEqual:[NSNull null]]) {
    NSDictionary *params = arguments[@"navigationInfoParameters"];

    FIRDynamicLinkNavigationInfoParameters *navigationInfoParameters =
        [FIRDynamicLinkNavigationInfoParameters parameters];

    NSNumber *forcedRedirectEnabled = params[@"forcedRedirectEnabled"];
    if (![forcedRedirectEnabled isEqual:[NSNull null]])
      navigationInfoParameters.forcedRedirectEnabled = [forcedRedirectEnabled boolValue];

    components.navigationInfoParameters = navigationInfoParameters;
  }

  if (![arguments[@"socialMetaTagParameters"] isEqual:[NSNull null]]) {
    NSDictionary *params = arguments[@"socialMetaTagParameters"];

    FIRDynamicLinkSocialMetaTagParameters *socialMetaTagParameters =
        [FIRDynamicLinkSocialMetaTagParameters parameters];

    NSString *descriptionText = params[@"description"];
    NSString *imageURL = params[@"imageUrl"];
    NSString *title = params[@"title"];

    if (![descriptionText isEqual:[NSNull null]])
      socialMetaTagParameters.descriptionText = descriptionText;
    if (![imageURL isEqual:[NSNull null]])
      socialMetaTagParameters.imageURL = [NSURL URLWithString:imageURL];
    if (![title isEqual:[NSNull null]]) socialMetaTagParameters.title = title;

    components.socialMetaTagParameters = socialMetaTagParameters;
  }

  return components;
}

@end
