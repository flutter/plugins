// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_client_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

const _$BillingResponseEnumMap = {
  BillingResponse.serviceTimeout: -3,
  BillingResponse.featureNotSupported: -2,
  BillingResponse.serviceDisconnected: -1,
  BillingResponse.ok: 0,
  BillingResponse.userCanceled: 1,
  BillingResponse.serviceUnavailable: 2,
  BillingResponse.billingUnavailable: 3,
  BillingResponse.itemUnavailable: 4,
  BillingResponse.developerError: 5,
  BillingResponse.error: 6,
  BillingResponse.itemAlreadyOwned: 7,
  BillingResponse.itemNotOwned: 8,
};

const _$SkuTypeEnumMap = {
  SkuType.inapp: 'inapp',
  SkuType.subs: 'subs',
};

const _$ProrationModeEnumMap = {
  ProrationMode.unknownSubscriptionUpgradeDowngradePolicy: 0,
  ProrationMode.immediateWithTimeProration: 1,
  ProrationMode.immediateAndChargeProratedPrice: 2,
  ProrationMode.immediateWithoutProration: 3,
  ProrationMode.deferred: 4,
  ProrationMode.immediateAndChargeFullPrice: 5,
};

const _$BillingClientFeatureEnumMap = {
  BillingClientFeature.inAppItemsOnVR: 'inAppItemsOnVr',
  BillingClientFeature.priceChangeConfirmation: 'priceChangeConfirmation',
  BillingClientFeature.subscriptions: 'subscriptions',
  BillingClientFeature.subscriptionsOnVR: 'subscriptionsOnVr',
  BillingClientFeature.subscriptionsUpdate: 'subscriptionsUpdate',
};
