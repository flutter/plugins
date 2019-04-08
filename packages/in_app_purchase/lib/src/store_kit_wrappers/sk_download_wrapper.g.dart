// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sk_download_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SKDownloadWrapper _$SKDownloadWrapperFromJson(Map json) {
  return SKDownloadWrapper(
      contentIdentifier: json['contentIdentifier'] as String,
      state: _$enumDecodeNullable(_$SKDownloadStateEnumMap, json['state']),
      contentLength: json['contentLength'] as int,
      contentURL: json['contentURL'] as String,
      contentVersion: json['contentVersion'] as String,
      transactionID: json['transactionID'] as String,
      progress: (json['progress'] as num)?.toDouble(),
      timeRemaining: (json['timeRemaining'] as num)?.toDouble(),
      downloadTimeUnknown: json['downloadTimeUnknown'] as bool,
      error: json['error'] == null
          ? null
          : SKError.fromJson(json['error'] as Map));
}

Map<String, dynamic> _$SKDownloadWrapperToJson(SKDownloadWrapper instance) =>
    <String, dynamic>{
      'contentIdentifier': instance.contentIdentifier,
      'state': _$SKDownloadStateEnumMap[instance.state],
      'contentLength': instance.contentLength,
      'contentURL': instance.contentURL,
      'contentVersion': instance.contentVersion,
      'transactionID': instance.transactionID,
      'progress': instance.progress,
      'timeRemaining': instance.timeRemaining,
      'downloadTimeUnknown': instance.downloadTimeUnknown,
      'error': instance.error
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$SKDownloadStateEnumMap = <SKDownloadState, dynamic>{
  SKDownloadState.waiting: 0,
  SKDownloadState.active: 1,
  SKDownloadState.pause: 2,
  SKDownloadState.finished: 3,
  SKDownloadState.failed: 4,
  SKDownloadState.cancelled: 5
};
