///
//  Generated code. Do not modify.
///
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: library_prefixes
library fble_pbjson;

const GetLocalAdaptersResponse$json = const {
  '1': 'GetLocalAdaptersResponse',
  '2': const [
    const {'1': 'platform', '3': 1, '4': 1, '5': 14, '6': '.GetLocalAdaptersResponse.Platform', '10': 'platform'},
    const {'1': 'adapters', '3': 2, '4': 3, '5': 11, '6': '.LocalAdapter', '10': 'adapters'},
  ],
  '4': const [GetLocalAdaptersResponse_Platform$json],
};

const GetLocalAdaptersResponse_Platform$json = const {
  '1': 'Platform',
  '2': const [
    const {'1': 'ANDROID', '2': 0},
    const {'1': 'IOS', '2': 1},
  ],
};

const LocalAdapter$json = const {
  '1': 'LocalAdapter',
  '2': const [
    const {'1': 'opaque_id', '3': 1, '4': 1, '5': 9, '10': 'opaqueId'},
  ],
};

const AdvertisementData$json = const {
  '1': 'AdvertisementData',
  '2': const [
    const {'1': 'local_name', '3': 1, '4': 1, '5': 9, '10': 'localName'},
    const {'1': 'manufacturer_data', '3': 2, '4': 1, '5': 12, '10': 'manufacturerData'},
    const {'1': 'service_data', '3': 3, '4': 3, '5': 11, '6': '.AdvertisementData.ServiceDataEntry', '10': 'serviceData'},
    const {'1': 'tx_power_level', '3': 4, '4': 1, '5': 5, '10': 'txPowerLevel'},
    const {'1': 'connectable', '3': 5, '4': 1, '5': 8, '10': 'connectable'},
  ],
  '3': const [AdvertisementData_ServiceDataEntry$json],
};

const AdvertisementData_ServiceDataEntry$json = const {
  '1': 'ServiceDataEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 12, '10': 'value'},
  ],
  '7': const {'7': true},
};

const StartScanRequest$json = const {
  '1': 'StartScanRequest',
  '2': const [
    const {'1': 'adapter_id', '3': 1, '4': 1, '5': 9, '10': 'adapterId'},
    const {'1': 'android_scan_mode', '3': 2, '4': 1, '5': 5, '10': 'androidScanMode'},
    const {'1': 'service_uuids', '3': 3, '4': 3, '5': 9, '10': 'serviceUuids'},
  ],
};

const ScanResult$json = const {
  '1': 'ScanResult',
  '2': const [
    const {'1': 'remote_id', '3': 1, '4': 1, '5': 9, '10': 'remoteId'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'rssi', '3': 3, '4': 1, '5': 5, '10': 'rssi'},
    const {'1': 'advertisement_data', '3': 4, '4': 1, '5': 11, '6': '.AdvertisementData', '10': 'advertisementData'},
  ],
};

