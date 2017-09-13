///
//  Generated code. Do not modify.
///
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: library_prefixes
library fble;

// ignore: UNUSED_SHOWN_NAME
import 'dart:core' show int, bool, double, String, List, override;

import 'package:protobuf/protobuf.dart';

import 'fble.pbenum.dart';

export 'fble.pbenum.dart';

class GetLocalAdaptersResponse extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('GetLocalAdaptersResponse')
    ..e<GetLocalAdaptersResponse_Platform>(1, 'platform', PbFieldType.OE, GetLocalAdaptersResponse_Platform.ANDROID, GetLocalAdaptersResponse_Platform.valueOf)
    ..pp<LocalAdapter>(2, 'adapters', PbFieldType.PM, LocalAdapter.$checkItem, LocalAdapter.create)
    ..hasRequiredFields = false
  ;

  GetLocalAdaptersResponse() : super();
  GetLocalAdaptersResponse.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  GetLocalAdaptersResponse.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  GetLocalAdaptersResponse clone() => new GetLocalAdaptersResponse()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;
  static GetLocalAdaptersResponse create() => new GetLocalAdaptersResponse();
  static PbList<GetLocalAdaptersResponse> createRepeated() => new PbList<GetLocalAdaptersResponse>();
  static GetLocalAdaptersResponse getDefault() {
    if (_defaultInstance == null) _defaultInstance = new _ReadonlyGetLocalAdaptersResponse();
    return _defaultInstance;
  }
  static GetLocalAdaptersResponse _defaultInstance;
  static void $checkItem(GetLocalAdaptersResponse v) {
    if (v is! GetLocalAdaptersResponse) checkItemFailed(v, 'GetLocalAdaptersResponse');
  }

  GetLocalAdaptersResponse_Platform get platform => $_get(0, 1, null);
  set platform(GetLocalAdaptersResponse_Platform v) { setField(1, v); }
  bool hasPlatform() => $_has(0, 1);
  void clearPlatform() => clearField(1);

  List<LocalAdapter> get adapters => $_get(1, 2, null);
}

class _ReadonlyGetLocalAdaptersResponse extends GetLocalAdaptersResponse with ReadonlyMessageMixin {}

class LocalAdapter extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('LocalAdapter')
    ..a<String>(1, 'opaqueId', PbFieldType.OS)
    ..hasRequiredFields = false
  ;

  LocalAdapter() : super();
  LocalAdapter.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  LocalAdapter.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  LocalAdapter clone() => new LocalAdapter()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;
  static LocalAdapter create() => new LocalAdapter();
  static PbList<LocalAdapter> createRepeated() => new PbList<LocalAdapter>();
  static LocalAdapter getDefault() {
    if (_defaultInstance == null) _defaultInstance = new _ReadonlyLocalAdapter();
    return _defaultInstance;
  }
  static LocalAdapter _defaultInstance;
  static void $checkItem(LocalAdapter v) {
    if (v is! LocalAdapter) checkItemFailed(v, 'LocalAdapter');
  }

  String get opaqueId => $_get(0, 1, '');
  set opaqueId(String v) { $_setString(0, 1, v); }
  bool hasOpaqueId() => $_has(0, 1);
  void clearOpaqueId() => clearField(1);
}

class _ReadonlyLocalAdapter extends LocalAdapter with ReadonlyMessageMixin {}

class AdvertisementData_ServiceDataEntry extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('AdvertisementData_ServiceDataEntry')
    ..a<String>(1, 'key', PbFieldType.OS)
    ..a<List<int>>(2, 'value', PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  AdvertisementData_ServiceDataEntry() : super();
  AdvertisementData_ServiceDataEntry.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  AdvertisementData_ServiceDataEntry.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  AdvertisementData_ServiceDataEntry clone() => new AdvertisementData_ServiceDataEntry()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;
  static AdvertisementData_ServiceDataEntry create() => new AdvertisementData_ServiceDataEntry();
  static PbList<AdvertisementData_ServiceDataEntry> createRepeated() => new PbList<AdvertisementData_ServiceDataEntry>();
  static AdvertisementData_ServiceDataEntry getDefault() {
    if (_defaultInstance == null) _defaultInstance = new _ReadonlyAdvertisementData_ServiceDataEntry();
    return _defaultInstance;
  }
  static AdvertisementData_ServiceDataEntry _defaultInstance;
  static void $checkItem(AdvertisementData_ServiceDataEntry v) {
    if (v is! AdvertisementData_ServiceDataEntry) checkItemFailed(v, 'AdvertisementData_ServiceDataEntry');
  }

  String get key => $_get(0, 1, '');
  set key(String v) { $_setString(0, 1, v); }
  bool hasKey() => $_has(0, 1);
  void clearKey() => clearField(1);

  List<int> get value => $_get(1, 2, null);
  set value(List<int> v) { $_setBytes(1, 2, v); }
  bool hasValue() => $_has(1, 2);
  void clearValue() => clearField(2);
}

class _ReadonlyAdvertisementData_ServiceDataEntry extends AdvertisementData_ServiceDataEntry with ReadonlyMessageMixin {}

class AdvertisementData extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('AdvertisementData')
    ..a<String>(1, 'localName', PbFieldType.OS)
    ..a<List<int>>(2, 'manufacturerData', PbFieldType.OY)
    ..pp<AdvertisementData_ServiceDataEntry>(3, 'serviceData', PbFieldType.PM, AdvertisementData_ServiceDataEntry.$checkItem, AdvertisementData_ServiceDataEntry.create)
    ..a<int>(4, 'txPowerLevel', PbFieldType.O3)
    ..a<bool>(5, 'connectable', PbFieldType.OB)
    ..hasRequiredFields = false
  ;

  AdvertisementData() : super();
  AdvertisementData.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  AdvertisementData.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  AdvertisementData clone() => new AdvertisementData()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;
  static AdvertisementData create() => new AdvertisementData();
  static PbList<AdvertisementData> createRepeated() => new PbList<AdvertisementData>();
  static AdvertisementData getDefault() {
    if (_defaultInstance == null) _defaultInstance = new _ReadonlyAdvertisementData();
    return _defaultInstance;
  }
  static AdvertisementData _defaultInstance;
  static void $checkItem(AdvertisementData v) {
    if (v is! AdvertisementData) checkItemFailed(v, 'AdvertisementData');
  }

  String get localName => $_get(0, 1, '');
  set localName(String v) { $_setString(0, 1, v); }
  bool hasLocalName() => $_has(0, 1);
  void clearLocalName() => clearField(1);

  List<int> get manufacturerData => $_get(1, 2, null);
  set manufacturerData(List<int> v) { $_setBytes(1, 2, v); }
  bool hasManufacturerData() => $_has(1, 2);
  void clearManufacturerData() => clearField(2);

  List<AdvertisementData_ServiceDataEntry> get serviceData => $_get(2, 3, null);

  int get txPowerLevel => $_get(3, 4, 0);
  set txPowerLevel(int v) { $_setUnsignedInt32(3, 4, v); }
  bool hasTxPowerLevel() => $_has(3, 4);
  void clearTxPowerLevel() => clearField(4);

  bool get connectable => $_get(4, 5, false);
  set connectable(bool v) { $_setBool(4, 5, v); }
  bool hasConnectable() => $_has(4, 5);
  void clearConnectable() => clearField(5);
}

class _ReadonlyAdvertisementData extends AdvertisementData with ReadonlyMessageMixin {}

class StartScanRequest extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('StartScanRequest')
    ..a<String>(1, 'adapterId', PbFieldType.OS)
    ..a<int>(2, 'androidScanMode', PbFieldType.O3)
    ..p<String>(3, 'serviceUuids', PbFieldType.PS)
    ..hasRequiredFields = false
  ;

  StartScanRequest() : super();
  StartScanRequest.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  StartScanRequest.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  StartScanRequest clone() => new StartScanRequest()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;
  static StartScanRequest create() => new StartScanRequest();
  static PbList<StartScanRequest> createRepeated() => new PbList<StartScanRequest>();
  static StartScanRequest getDefault() {
    if (_defaultInstance == null) _defaultInstance = new _ReadonlyStartScanRequest();
    return _defaultInstance;
  }
  static StartScanRequest _defaultInstance;
  static void $checkItem(StartScanRequest v) {
    if (v is! StartScanRequest) checkItemFailed(v, 'StartScanRequest');
  }

  String get adapterId => $_get(0, 1, '');
  set adapterId(String v) { $_setString(0, 1, v); }
  bool hasAdapterId() => $_has(0, 1);
  void clearAdapterId() => clearField(1);

  int get androidScanMode => $_get(1, 2, 0);
  set androidScanMode(int v) { $_setUnsignedInt32(1, 2, v); }
  bool hasAndroidScanMode() => $_has(1, 2);
  void clearAndroidScanMode() => clearField(2);

  List<String> get serviceUuids => $_get(2, 3, null);
}

class _ReadonlyStartScanRequest extends StartScanRequest with ReadonlyMessageMixin {}

class ScanResult extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('ScanResult')
    ..a<String>(1, 'remoteId', PbFieldType.OS)
    ..a<String>(2, 'name', PbFieldType.OS)
    ..a<int>(3, 'rssi', PbFieldType.O3)
    ..a<AdvertisementData>(4, 'advertisementData', PbFieldType.OM, AdvertisementData.getDefault, AdvertisementData.create)
    ..hasRequiredFields = false
  ;

  ScanResult() : super();
  ScanResult.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  ScanResult.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  ScanResult clone() => new ScanResult()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;
  static ScanResult create() => new ScanResult();
  static PbList<ScanResult> createRepeated() => new PbList<ScanResult>();
  static ScanResult getDefault() {
    if (_defaultInstance == null) _defaultInstance = new _ReadonlyScanResult();
    return _defaultInstance;
  }
  static ScanResult _defaultInstance;
  static void $checkItem(ScanResult v) {
    if (v is! ScanResult) checkItemFailed(v, 'ScanResult');
  }

  String get remoteId => $_get(0, 1, '');
  set remoteId(String v) { $_setString(0, 1, v); }
  bool hasRemoteId() => $_has(0, 1);
  void clearRemoteId() => clearField(1);

  String get name => $_get(1, 2, '');
  set name(String v) { $_setString(1, 2, v); }
  bool hasName() => $_has(1, 2);
  void clearName() => clearField(2);

  int get rssi => $_get(2, 3, 0);
  set rssi(int v) { $_setUnsignedInt32(2, 3, v); }
  bool hasRssi() => $_has(2, 3);
  void clearRssi() => clearField(3);

  AdvertisementData get advertisementData => $_get(3, 4, null);
  set advertisementData(AdvertisementData v) { setField(4, v); }
  bool hasAdvertisementData() => $_has(3, 4);
  void clearAdvertisementData() => clearField(4);
}

class _ReadonlyScanResult extends ScanResult with ReadonlyMessageMixin {}

