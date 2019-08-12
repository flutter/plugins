import 'method_call_invoker.dart';
import 'dart:async';
import 'package:flutter/services.dart';

abstract class _HttpMetric {
  _HttpMetric.internal(
      MethodCallInvokerNode creatorNode, String handle, Map source)
      : _invokerNode = creatorNode,
        handle = handle;

  MethodCallInvokerNode _invokerNode;

  final String handle;

  MethodCallInvokerNode get invokerNode => _invokerNode;
  Future<String> getAttribute(String attribute) {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('HttpMetric#getAttribute',
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
        MethodCall(
            'HttpMetric#getAttributes', <String, dynamic>{'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _updateInvokerNode(newNode);
    return newNode.invokeMap<String, String>();
  }

  Future<void> putAttribute(String attribute, String value) {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('HttpMetric#putAttribute', <String, dynamic>{
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

  Future<void> removeAttribute(String attribute) {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('HttpMetric#removeAttribute',
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
        MethodCall('HttpMetric#start', <String, dynamic>{'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.allocator);
    _updateInvokerNode(newNode);
    return newNode.invoke<void>();
  }

  Future<void> stop() {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('HttpMetric#stop', <String, dynamic>{'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.disposer);
    _updateInvokerNode(newNode);
    return newNode.invoke<void>();
  }

  Future<void> setHttpResponseCode(int responseCode) {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('HttpMetric#setHttpResponseCode',
            <String, dynamic>{'responseCode': responseCode, 'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _updateInvokerNode(newNode);
    if (invokerNode.type != NodeType.allocator) return Future<void>.value();
    return newNode.invoke<void>();
  }

  Future<void> setRequestPayloadSize(int bytes) {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('HttpMetric#setRequestPayloadSize',
            <String, dynamic>{'bytes': bytes, 'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _updateInvokerNode(newNode);
    if (invokerNode.type != NodeType.allocator) return Future<void>.value();
    return newNode.invoke<void>();
  }

  Future<void> setResponseContentType(String contentType) {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('HttpMetric#setResponseContentType',
            <String, dynamic>{'contentType': contentType, 'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _updateInvokerNode(newNode);
    if (invokerNode.type != NodeType.allocator) return Future<void>.value();
    return newNode.invoke<void>();
  }

  Future<void> setResponsePayloadSize(int bytes) {
    assert(invokerNode.type != NodeType.disposer,
        'This object has been disposed.');
    final MethodCallInvokerNode newNode = MethodCallInvokerNode(
        MethodCall('HttpMetric#setResponsePayloadSize',
            <String, dynamic>{'bytes': bytes, 'handle': handle}),
        <MethodCallInvokerNode>[invokerNode],
        NodeType.regular);
    _updateInvokerNode(newNode);
    if (invokerNode.type != NodeType.allocator) return Future<void>.value();
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

abstract class HttpMetric extends _HttpMetric {
  HttpMetric.internal(
      MethodCallInvokerNode creatorNode, String handle, Map source)
      : super.internal(creatorNode, handle, source);

  final Map<String, String> _attributes = <String, String>{};

  bool _stopped = false;

  @override
  Future<void> stop() {
    _stopped = true;
    return super.stop();
  }

  @override
  Future<void> putAttribute(String attribute, String value) {
    _attributes[attribute] = value;
    return super.putAttribute(attribute, value);
  }

  @override
  Future<Map<String, String>> getAttributes() {
    if (_stopped) return Future<Map<String, String>>.value(_attributes);
    return super.getAttributes();
  }
}
