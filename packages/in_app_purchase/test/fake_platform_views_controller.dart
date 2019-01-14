import 'dart:async';
import 'package:flutter/services.dart';

class FakePlatformViewsController {
  Map<String, dynamic> _expectedCalls = <String, dynamic>{};
  void addCall({String name, dynamic value}) => _expectedCalls[name] = value;

  List<MethodCall> _previousCalls = <MethodCall>[];
  List<MethodCall> get previousCalls => _previousCalls;
  MethodCall previousCallMatching(String name) => _previousCalls
      .firstWhere((MethodCall call) => call.method == name, orElse: () => null);
  int countPreviousCalls(String name) =>
      _previousCalls.where((MethodCall call) => call.method == name).length;

  void reset() {
    _expectedCalls.clear();
    _previousCalls.clear();
  }

  Future<dynamic> fakePlatformViewsMethodHandler(MethodCall call) {
    _previousCalls.add(call);
    if (_expectedCalls.containsKey(call.method)) {
      return Future<dynamic>.sync(() => _expectedCalls[call.method]);
    } else {
      return Future<void>.sync(() => null);
    }
  }
}
