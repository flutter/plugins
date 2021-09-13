// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLEFileSelectorPlugin.h"

#import <AppKit/AppKit.h>

// See channel_controller.dart for documentation.
static NSString *const kChannelName = @"plugins.flutter.io/file_selector";

static NSString *const kOpenFileMethod = @"openFile";
static NSString *const kGetSavePathMethod = @"getSavePath";
static NSString *const kGetDirectoryPathMethod = @"getDirectoryPath";

static NSString *const kInitialDirectoryKey = @"initialDirectory";
static NSString *const kSuggestedNameKey = @"suggestedName";
static NSString *const kAcceptedTypeGroupsKey = @"acceptedTypeGroups";
static NSString *const kConfirmButtonTextKey = @"confirmButtonText";
static NSString *const kMultipleKey = @"multiple";

// From x_type_group.dart
static NSString *const kTypeGroupExtensionsKey = @"extensions";
static NSString *const kTypeGroupMimeTypesKey = @"mimeTypes";
static NSString *const kTypeGroupUTIsKey = @"macUTIs";

// Returns the value for |key| in |dict|, returning nil for NSNull.
id GetNonNullValueForKey( NSDictionary<NSString *, id>* dict, NSString* key) {
  id value = dict[key];
  return value == [NSNull null] ? nil : value;
}

@implementation FLEFileSelectorPlugin {
  // The plugin registrar, for obtaining the view.
  NSObject<FlutterPluginRegistrar> *_registrar;
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self != nil) {
    _registrar = registrar;
  }
  return self;
}

/**
 * Configures an NSSavePanel instance on behalf of a flutter client.
 *
 * @param panel - The panel to configure.
 * @param arguments - A dictionary of method arguments used to configure a panel instance.
 */
- (void)configureSavePanel:(nonnull NSSavePanel *)panel
             withArguments:(nonnull NSDictionary<NSString *, id> *)arguments {
  NSString* initialDirectory = GetNonNullValueForKey(arguments, kInitialDirectoryKey);
  if (initialDirectory) {
    panel.directoryURL = [NSURL URLWithString:initialDirectory];
  }
  NSArray<NSDictionary<NSString*, id>*>* acceptedTypeGroups = GetNonNullValueForKey(arguments, kAcceptedTypeGroupsKey);
  if (acceptedTypeGroups.count > 0) {
    // macOS doesn't support filter groups, so combine all allowed types into a flat list.
    NSMutableArray<NSString *> *allowedTypes = [NSMutableArray array];
    for (NSDictionary *filter in acceptedTypeGroups) {
      NSArray<NSString *> *extensions = GetNonNullValueForKey(filter, kTypeGroupExtensionsKey);
      NSArray<NSString *> *mimeTypes = GetNonNullValueForKey(filter, kTypeGroupMimeTypesKey);
      NSArray<NSString *> *macUTIs = GetNonNullValueForKey(filter, kTypeGroupUTIsKey);
      // If any group allows everything, don't do any filtering.
      if (extensions.count == 0 && mimeTypes.count == 0 && macUTIs.count == 0) {
        allowedTypes = nil;
        break;
      }
      [allowedTypes addObjectsFromArray:extensions];
      [allowedTypes addObjectsFromArray:macUTIs];
      // TODO: Add support for mimeTypes in macOS 11+.
    }
    panel.allowedFileTypes = allowedTypes;
  }
  NSString* suggestedName = GetNonNullValueForKey(arguments, kSuggestedNameKey);
  if (suggestedName) {
    panel.nameFieldStringValue = suggestedName;
  }
  NSString* confirmButtonText = GetNonNullValueForKey(arguments, kConfirmButtonTextKey);
  if (confirmButtonText) {
    panel.prompt = confirmButtonText;
  }
}

/**
 * Configures an NSOpenPanel instance on behalf of a flutter client.
 *
 * @param panel - The open panel to configure.
 * @param arguments - A dictionary of method arguments used to configure a panel instance.
 * @param choosingDirectory - Whether to choose directories rather than files.
 */
- (void)configureOpenPanel:(nonnull NSOpenPanel *)panel
             withArguments:(nonnull NSDictionary<NSString *, id> *)arguments
         choosingDirectory:(BOOL)choosingDirectory {
  NSSet *argKeys = [NSSet setWithArray:arguments.allKeys];
  if ([argKeys containsObject:kMultipleKey]) {
    panel.allowsMultipleSelection = [arguments[kMultipleKey] boolValue];
  }
  panel.canChooseDirectories = choosingDirectory;
  panel.canChooseFiles = !choosingDirectory;
}

#pragma FlutterPlugin implementation

+ (void)registerWithRegistrar:(id<FlutterPluginRegistrar>)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:kChannelName
                                                              binaryMessenger:registrar.messenger];
  FLEFileSelectorPlugin *instance = [[FLEFileSelectorPlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSDictionary *arguments = call.arguments;

  if ([call.method isEqualToString:kGetSavePathMethod]) {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.canCreateDirectories = YES;
    [self configureSavePanel:savePanel withArguments:arguments];
    [savePanel beginSheetModalForWindow:_registrar.view.window
                      completionHandler:^(NSModalResponse panelResult) {
                        NSURL *URL =
                            (panelResult == NSModalResponseOK) ? savePanel.URL : nil;
                        result(URL.path);
                      }];

  } else if ([call.method isEqualToString:kOpenFileMethod] ||
             [call.method isEqualToString:kGetDirectoryPathMethod]) {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    BOOL choosingDirectory = [call.method isEqualToString:kGetDirectoryPathMethod];
    [self configureSavePanel:openPanel withArguments:arguments];
    [self configureOpenPanel:openPanel
               withArguments:arguments
           choosingDirectory:choosingDirectory];
    [openPanel beginSheetModalForWindow:_registrar.view.window
                      completionHandler:^(NSModalResponse panelResult) {
                        NSArray<NSURL *> *URLs =
                            (panelResult == NSModalResponseOK) ? openPanel.URLs : nil;
      if (choosingDirectory) {
        result(URLs.firstObject.path);
      } else {
                        result([URLs valueForKey:@"path"]);
      }
                      }];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
