import 'method_call_invoker.dart';
import 'channel.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'http_metric.dart';
import 'trace.dart';

abstract class FirebasePerformance {
  FirebasePerformance.internal(
      MethodCallInvokerNode creatorNode, String handle, Map source)
      : _invokerNode = creatorNode,
        handle = handle;

  MethodCallInvokerNode _invokerNode;

  final String handle;

  MethodCallInvokerNode get invokerNode => _invokerNode;
  static FirebasePerformance getInstance() {
    final String newHandle = Channel.nextHandle();
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('FirebasePerformance#getInstance',
            <String, dynamic>{'__createdObjectHandle': newHandle}),
        <MethodCallInvokerNode>[],
        NodeType.regular);
    newNode.invoke<void>();
    return _FirebasePerformanceImpl(newNode, newHandle, null);
  }

  Future<bool> isPerformanceCollectionEnabled() {
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('FirebasePerformance#isPerformanceCollectionEnabled',
            <String, dynamic>{'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    return newNode.invoke<bool>();
  }

  HttpMetric newHttpMetric(String url, String httpMethod) {
    final String newHandle = Channel.nextHandle();
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('FirebasePerformance#newHttpMetric', <String, dynamic>{
          'url': url,
          'httpMethod': httpMethod,
          'handle': handle,
          '__createdObjectHandle': newHandle
        }),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    return _HttpMetricImpl(newNode, newHandle, null);
  }

  Trace newTrace(String traceName) {
    final String newHandle = Channel.nextHandle();
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('FirebasePerformance#newTrace', <String, dynamic>{
          'traceName': traceName,
          'handle': handle,
          '__createdObjectHandle': newHandle
        }),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    return _TraceImpl(newNode, newHandle, null);
  }

  Future<void> setPerformanceCollectionEnabled(bool enable) {
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('FirebasePerformance#setPerformanceCollectionEnabled',
            <String, dynamic>{'enable': enable, 'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _invokerNode = newNode;
    return Future<void>.value();
  }

  static Trace startTrace(String traceName) {
    final String newHandle = Channel.nextHandle();
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('FirebasePerformance#startTrace', <String, dynamic>{
          'traceName': traceName,
          '__createdObjectHandle': newHandle
        }),
        <MethodCallInvokerNode>[],
        NodeType.regular);
    newNode.invoke<void>();
    return _TraceImpl(newNode, newHandle, null);
  }
}

class _FirebasePerformanceImpl extends FirebasePerformance {
  _FirebasePerformanceImpl(
      MethodCallInvokerNode creatorNode, String newHandle, Map source)
      : super.internal(creatorNode, newHandle, source);
}

class _HttpMetricImpl extends HttpMetric {
  _HttpMetricImpl(
      MethodCallInvokerNode creatorNode, String newHandle, Map source)
      : super.internal(creatorNode, newHandle, source);
}

class _TraceImpl extends Trace {
  _TraceImpl(MethodCallInvokerNode creatorNode, String newHandle, Map source)
      : super.internal(creatorNode, newHandle, source);
}
