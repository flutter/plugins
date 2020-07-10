@JS()
library network_information_types;

import "package:js/js.dart";
import "dart:html" show EventListener, EventTarget;

/// W3C Spec Draft http://wicg.github.io/netinfo/
/// Edition: Draft Community Group Report 20 February 2019

/// http://wicg.github.io/netinfo/#navigatornetworkinformation-interface
@anonymous
@JS()
abstract class Navigator implements NavigatorNetworkInformation {}

@anonymous
@JS()
abstract class WorkerNavigator implements NavigatorNetworkInformation {
  external factory WorkerNavigator({NetworkInformation connection});
}

/// http://wicg.github.io/netinfo/#navigatornetworkinformation-interface
@anonymous
@JS()
abstract class NavigatorNetworkInformation {
  external NetworkInformation get connection;
  external factory NavigatorNetworkInformation({NetworkInformation connection});
}

/// http://wicg.github.io/netinfo/#connection-types
/*type ConnectionType =
  | 'bluetooth'
  | 'cellular'
  | 'ethernet'
  | 'mixed'
  | 'none'
  | 'other'
  | 'unknown'
  | 'wifi'
  | 'wimax';
*/

/// http://wicg.github.io/netinfo/#effectiveconnectiontype-enum
/*type EffectiveConnectionType = '2g' | '3g' | '4g' | 'slow-2g';*/

/// http://wicg.github.io/netinfo/#dom-megabit
/*type Megabit = number;*/
/// http://wicg.github.io/netinfo/#dom-millisecond
/*type Millisecond = number;*/

/// http://wicg.github.io/netinfo/#networkinformation-interface
@anonymous
@JS()
abstract class NetworkInformation implements EventTarget {
  /// http://wicg.github.io/netinfo/#type-attribute
  external String /*'bluetooth'|'cellular'|'ethernet'|'mixed'|'none'|'other'|'unknown'|'wifi'|'wimax'*/ get type;

  /// http://wicg.github.io/netinfo/#effectivetype-attribute
  external String /*'2g'|'3g'|'4g'|'slow-2g'*/ get effectiveType;

  /// http://wicg.github.io/netinfo/#downlinkmax-attribute
  external num get downlinkMax;

  /// http://wicg.github.io/netinfo/#downlink-attribute
  external num get downlink;

  /// http://wicg.github.io/netinfo/#rtt-attribute
  external num get rtt;

  /// http://wicg.github.io/netinfo/#savedata-attribute
  external bool get saveData;

  /// http://wicg.github.io/netinfo/#handling-changes-to-the-underlying-connection
  external EventListener get onchange;
  external set onchange(EventListener v);
}

@JS()
external Navigator get navigator;
