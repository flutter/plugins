// Copyright 2017, the Flutter project authors. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
//     * Neither the name of Google Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <CoreBluetooth/CoreBluetooth.h>

#import "Fble.pbobjc.h"
#import "FblePlugin.h"

static NSString *const kGetLocalAdapters = @"getLocalAdapters";
static NSString *const kStartScan = @"startScan";
static NSString *const kStopScan = @"stopScan";
static NSString *const kNamespace = @"io.flutter.plugins.fble";
static NSString *const kMethodNamespace = @"io.flutter.plugins.fble.method";
static NSString *const kEventNamespace = @"io.flutter.plugins.fble.event";
static NSString *const kDefaultAdapterId = @"02000000-0000-0000-0000-000000000000";

typedef void (^ScanResultCallback)(ProtosScanResult*);

@interface BluetoothAdapter : NSObject<CBCentralManagerDelegate> {
  ScanResultCallback _scanResultCallback;
}

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong, getter=getScanResultCallback, setter=setScanResultCallback:) ScanResultCallback scanResultCallback;

- (id)initWithIdentifier:(NSString*)identifier;
- (void)startScan:(NSArray<CBUUID *> *)services;
- (void)stopScan;
@end

@implementation BluetoothAdapter
- (id)initWithIdentifier:(NSString*)identifier {
  if ((self = [super init]) != nil) {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.identifier = identifier;
    self->_scanResultCallback = nil;
    return self;
  } else {
    return nil;
  }
}

- (ScanResultCallback)getScanResultCallback {
  @synchronized (self) {
    return self->_scanResultCallback;
  }
}

- (void)setScanResultCallback:(ScanResultCallback) callback {
  @synchronized (self) {
    self->_scanResultCallback = callback;
  }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
  // TODO: What?
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
  if (!self->_scanResultCallback) {
    return;
  }
  ProtosScanResult *result = [[ProtosScanResult alloc] init];
  [result setName:[peripheral name]];
  [result setRemoteId:[[peripheral identifier] UUIDString]];
  [result setRssi:[RSSI intValue]];
  ProtosAdvertisementData *ads = [[ProtosAdvertisementData alloc] init];
  [ads setLocalName:advertisementData[CBAdvertisementDataLocalNameKey]];
  [ads setManufacturerData:advertisementData[CBAdvertisementDataManufacturerDataKey]];
  NSDictionary *serviceData = advertisementData[CBAdvertisementDataServiceDataKey];
  for (CBUUID *uuid in serviceData) {
    [[ads serviceData] setObject:serviceData[uuid] forKey:uuid.UUIDString];
  }
  [ads setTxPowerLevel:[advertisementData[CBAdvertisementDataTxPowerLevelKey] intValue]];
  [ads setConnectable:[advertisementData[CBAdvertisementDataIsConnectable] boolValue]];
  [result setAdvertisementData:ads];
  @synchronized (self) {
    // Double-checked.
    if (self->_scanResultCallback) {
      self->_scanResultCallback(result);
    }
  }
}

- (void)startScan:(NSArray<CBUUID *> *)services {
  NSDictionary *options = @{
      CBCentralManagerScanOptionAllowDuplicatesKey: @YES
  };
  if (services.count == 0) {
    services = nil;
  }
  [self.centralManager scanForPeripheralsWithServices:services options:options];
}

- (void)stopScan {
  [self.centralManager stopScan];
}
@end

@interface FblePlugin()
@property (nonatomic, strong) BluetoothAdapter *defaultAdapter;
@property (nonatomic, strong) NSObject<FlutterPluginRegistrar> *registrar;
@end

@implementation FblePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:kMethodNamespace
            binaryMessenger:[registrar messenger]];
  FblePlugin *instance = [[FblePlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  if ((self = [super init]) != nil) {
    self.registrar = registrar;
    self.defaultAdapter = [[BluetoothAdapter alloc] initWithIdentifier:kDefaultAdapterId];
    return self;
  } else {
    return nil;
  }
}

- (BluetoothAdapter *)lookupAdapter:(NSString *)identifier {
  return self.defaultAdapter;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([kGetLocalAdapters isEqualToString:call.method]) {
    [self getLocalAdapters:call result:result];
  } else if ([kStartScan isEqualToString:call.method]) {
    [self startScan:call result:result];
  } else if ([kStopScan isEqualToString:call.method]) {
    [self stopScan:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)getLocalAdapters:(FlutterMethodCall*)call result:(FlutterResult)result {
  ProtosGetLocalAdaptersResponse *response = [[ProtosGetLocalAdaptersResponse alloc] init];
  [response setPlatform:ProtosGetLocalAdaptersResponse_Platform_Ios];
  // There is no concept of separate adapters in iOS. So we return a fake one.
  ProtosLocalAdapter *defaultAdapter = [[ProtosLocalAdapter alloc] init];
  [defaultAdapter setOpaqueId:[self.defaultAdapter identifier]];
  [[response adaptersArray] addObject:defaultAdapter];
  result([FlutterStandardTypedData typedDataWithBytes:[response data]]);
}

- (void)startScan:(FlutterMethodCall*)call result:(FlutterResult)result {
  FlutterStandardTypedData *data = [call arguments];
  ProtosStartScanRequest *request = [[ProtosStartScanRequest alloc] initWithData:[data data] error:nil];
  NSString *adapterId = [request adapterId];
  BluetoothAdapter *adapter = [self lookupAdapter:adapterId];
  NSMutableArray<CBUUID *> *services = [NSMutableArray arrayWithCapacity:[request.serviceUuidsArray count]];
  for (NSString *uuidString in request.serviceUuidsArray) {
    CBUUID *uuid = [CBUUID UUIDWithString:uuidString];
    [services addObject:uuid];
  }
  [adapter startScan:services];
  FlutterEventChannel *bleEventChannel =
      [FlutterEventChannel eventChannelWithName:[kEventNamespace stringByAppendingFormat:@".scanResult.%@", adapterId]
                                binaryMessenger:[self.registrar messenger]];
  bleEventChannel.streamHandler = self; // TODO: Clean up the stream handler in onCancelWithArguments?
  result(nil);
}

- (void)stopScan:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *adapterId = [call arguments];
  BluetoothAdapter *adapter = [self lookupAdapter:adapterId];
  [adapter stopScan];
  result(nil);
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  self.defaultAdapter.scanResultCallback = ^(ProtosScanResult *result) {
    FlutterStandardTypedData *data = [FlutterStandardTypedData typedDataWithBytes:[[result data] copy]];
    eventSink(data);
  };
  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  self.defaultAdapter.scanResultCallback = nil;
  return nil;
}
@end
