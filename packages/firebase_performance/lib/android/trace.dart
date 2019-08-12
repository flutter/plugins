import 'method_call_invoker.dart';
import 'dart:async';
import 'package:flutter/services.dart';

abstract class Trace {
  Trace.internal(MethodCallInvokerNode creatorNode, String handle, Map source)
      : _invokerNode = creatorNode,
        handle = handle;

  MethodCallInvokerNode _invokerNode;

  final String handle;

  MethodCallInvokerNode get invokerNode => _invokerNode;
  Future<int> describeContents() {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall(
            'Trace#describeContents', <String, dynamic>{'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _updateInvokerNode(newNode);
    return newNode.invoke<int>();
  }

  Future<String> getAttribute(String attribute) {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('Trace#getAttribute',
            <String, dynamic>{'attribute': attribute, 'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _updateInvokerNode(newNode);
    return newNode.invoke<String>();
  }

  Future<Map<String, String>> getAttributes() {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('Trace#getAttributes', <String, dynamic>{'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _updateInvokerNode(newNode);
    return newNode.invokeMap<String, String>();
  }

  Future<int> getLongMetric(String metricName) {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('Trace#getLongMetric',
            <String, dynamic>{'metricName': metricName, 'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _updateInvokerNode(newNode);
    return newNode.invoke<int>();
  }

  Future<void> incrementMetric(String metricName, int incrementBy) {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('Trace#incrementMetric', <String, dynamic>{
          'metricName': metricName,
          'incrementBy': incrementBy,
          'handle': handle
        }),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _updateInvokerNode(newNode);
    if (invokerNode.type != NodeType.allocator) return Future<void>.value();
    return newNode.invoke<void>();
  }

  Future<void> putAttribute(String attribute, String value) {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('Trace#putAttribute', <String, dynamic>{
          'attribute': attribute,
          'value': value,
          'handle': handle
        }),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _updateInvokerNode(newNode);
    if (invokerNode.type != NodeType.allocator) return Future<void>.value();
    return newNode.invoke<void>();
  }

  Future<void> putMetric(String metricName, int value) {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('Trace#putMetric', <String, dynamic>{
          'metricName': metricName,
          'value': value,
          'handle': handle
        }),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _updateInvokerNode(newNode);
    if (invokerNode.type != NodeType.allocator) return Future<void>.value();
    return newNode.invoke<void>();
  }

  Future<void> removeAttribute(String attribute) {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('Trace#removeAttribute',
            <String, dynamic>{'attribute': attribute, 'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _updateInvokerNode(newNode);
    if (invokerNode.type != NodeType.allocator) return Future<void>.value();
    return newNode.invoke<void>();
  }

  Future<void> start() {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('Trace#start', <String, dynamic>{'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.allocator);
    _updateInvokerNode(newNode);
    return newNode.invoke<void>();
  }

  Future<void> stop() {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('Trace#stop', <String, dynamic>{'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.disposer);
    _updateInvokerNode(newNode);
    return newNode.invoke<void>();
  }

  void _updateInvokerNode(MethodCallInvokerNode newNode) {
    if (newNode.type != NodeType.disposer &&
        _invokerNode.type == NodeType.allocator) {
      return;
    }
    _invokerNode = newNode;
  }
}
