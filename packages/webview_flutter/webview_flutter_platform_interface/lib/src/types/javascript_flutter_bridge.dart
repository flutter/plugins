// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import '../platform_interface/platform_interface.dart';
import 'javascript_message.dart';

/// defalut bridgeName
const String defaultBridgeName = 'flutter_bridge';

/// A communication bridge between Javascript and Flutter.
class JavascriptFlutterBridge {
  /// Constructs a JavascriptFlutterBridge object.
  ///
  /// The `name` parameter must not be null.
  JavascriptFlutterBridge(this.name) : assert(name != null);

  /// bridge name
  final String name;

  /// channel names for add syntactic sugar in JavaScript code
  final List<String> _channelNames = <String>[];

  /// setup channel names
  set channelNames(List<String> names) => _channelNames.addAll(names);

  /// custom event name for `postNotification`
  String get _eventName => '${name}_event';

  /// JavaScript code executor
  WebViewPlatformController? _platformController;

  /// build bridge
  void build(WebViewPlatformController platformController) {
    final String jsBridge = _jsBridge(channelNames: _channelNames);
    platformController.runJavascript(jsBridge);
    _platformController = platformController;
  }

  /// reply message
  void reply(dynamic info, {required int messageID}) {
    final String data = jsonEncode(info);
    _platformController
        ?.runJavascript("$name.onClientResponse($messageID, '$data')");
  }

  /// dispatch CustomEvent to the JavaScript code.
  Future<void>? postNotification(String name, {Map<String, dynamic>? info}) {
    String infoString = '';
    try {
      infoString = jsonEncode(info);
    } catch (_) {}
    final String javaScriptString =
        "(function() { const event = new CustomEvent('$_eventName', { detail: {'name':'$name', 'info': $infoString} }); document.dispatchEvent(event)}());";
    return _platformController?.runJavascript(javaScriptString);
  }

  /// unpack message if needed
  JavascriptMessage unpackMessageIfNeeded(String message) {
    Map? info;
    int? messageID;
    dynamic originData;
    String? originMessage;
    Function(dynamic info)? replyFunc;
    try {
      info = jsonDecode(message) as Map;
      messageID = info['id'] as int;
      originData = info['info_$messageID'];
      originMessage = jsonEncode(originData);
    } catch (_) {}

    if (messageID != null) {
      replyFunc = (dynamic info) => reply(info, messageID: messageID!);
    }
    return JavascriptMessage(originMessage ?? message, reply: replyFunc);
  }

  /// JavaScript Bridge code
  String _jsBridge({List<String>? channelNames}) {
    final String? sugar = channelNames
        ?.map((String e) =>
            "'$e': (info, callback) => window.$name.invoke('$e', info, callback)")
        .join(',');
    return '''
    (function() {
    if (window.$name != undefined) {
        return;
    }
    $name = function() {
        const callbacks = [];
        const registerHandlers = [];
        var callbackID = 0;
        document.addEventListener('$_eventName', function(e) {
            if (e.detail) {
                const detail = e.detail;
                const name = detail.name;
                if (name !== undefined && registerHandlers[name]) {
                    const namedListeners = registerHandlers[name];
                    if (namedListeners instanceof Array) {
                        const info = detail.info;
                        namedListeners.forEach(function(handler) {
                            handler(info);
                        })
                    }
                }
            }
        }, false);
        return {
            'invoke': function(action, info, callback) {
                const msgID = ++callbackID;
                callbacks[msgID] = callback;
                
                const msg = {'id': msgID};
                msg['info_' + msgID] = info;
                const sender = window[action];
                if (sender != undefined) {
                    sender.postMessage(JSON.stringify(msg));
                } else {
                    console.log('undefined action');
                }
            },
            'onClientResponse': function(cid, json) {
                callbacks[cid] && callbacks[cid](json);
                delete callbacks[cid];
            },
            'addEventListener': function(name, callback) {
                var namedListeners = registerHandlers[name];
                if (!namedListeners) {
                    registerHandlers[name] = namedListeners = [];
                }
                namedListeners.push(callback);
                return function() {
                    namedListeners[indexOf(namedListeners, callback)] = null;
                }
            },
            'removeEventListener': function(name) {
                return delete registerHandlers[name];
            },
            $sugar
        }
    } ()
    } ());
      ''';
  }
}
