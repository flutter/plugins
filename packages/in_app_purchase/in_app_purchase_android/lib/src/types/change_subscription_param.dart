import '../../billing_client_wrappers.dart';
import 'types.dart';

/// This parameter object for upgrading or downgrading an existing subscription.
class ChangeSubscriptionParam {
  /// Creates a new change subscription param object with given data
  ChangeSubscriptionParam({
    required this.oldPurchaseDetails,
    this.prorationMode,
  });

  /// The purchase object of the existing subscription that the user needs to
  /// upgrade/downgrade from.
  final GooglePlayPurchaseDetails oldPurchaseDetails;

  /// The proration mode.
  ///
  /// This is an optional parameter that indicates how to handle the existing
  /// subscription when the new subscription comes into effect.
  final ProrationMode? prorationMode;
}
