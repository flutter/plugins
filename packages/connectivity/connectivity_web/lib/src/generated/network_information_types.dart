@JS()
library network_information_types;

import "package:js/js.dart";
import "dart:html" show Navigator, EventTarget;

/// W3C Spec Draft http://wicg.github.io/netinfo/
/// Edition: Draft Community Group Report 20 February 2019

/// http://wicg.github.io/netinfo/#navigatornetworkinformation-interface

/* Skipping class Navigator*/
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
  external set connection(NetworkInformation v);
  external factory NavigatorNetworkInformation({NetworkInformation connection});
}

/// http://wicg.github.io/netinfo/#connection-types
/*type ConnectionType = 'bluetooth' |
    'cellular' |
    'ethernet' |
    'mixed' |
    'none' |
    'other' |
    'unknown' |
    'wifi' |
    'wimax';*/

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
  external set type(
      String /*'bluetooth'|'cellular'|'ethernet'|'mixed'|'none'|'other'|'unknown'|'wifi'|'wimax'*/ v);

  /// http://wicg.github.io/netinfo/#effectivetype-attribute
  external String /*'2g'|'3g'|'4g'|'slow-2g'*/ get effectiveType;
  external set effectiveType(String /*'2g'|'3g'|'4g'|'slow-2g'*/ v);

  /// http://wicg.github.io/netinfo/#downlinkmax-attribute
  external num get downlinkMax;
  external set downlinkMax(num v);

  /// http://wicg.github.io/netinfo/#downlink-attribute
  external num get downlink;
  external set downlink(num v);

  /// http://wicg.github.io/netinfo/#rtt-attribute
  external num get rtt;
  external set rtt(num v);

  /// http://wicg.github.io/netinfo/#savedata-attribute
  external bool get saveData;
  external set saveData(bool v);

  /// http://wicg.github.io/netinfo/#handling-changes-to-the-underlying-connection
  external EventListener get onchange;
  external set onchange(EventListener v);
}
