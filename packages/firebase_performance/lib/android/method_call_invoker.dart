import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';

import 'channel.dart';

class MethodCallInvokerNode {
  MethodCallInvokerNode(
    this.methodCall, [
    List<MethodCallInvokerNode> parents,
    this.type = NodeType.regular,
  ]) : parents = List.unmodifiable(parents);

  final MethodCall methodCall;
  final NodeType type;
  final List<MethodCallInvokerNode> parents;
  final int timestamp = DateTime.now().microsecondsSinceEpoch;

  Future<T> invoke<T>() {
    final List<MethodCallInvokerNode> allNodes = <MethodCallInvokerNode>[];
    for (MethodCallInvokerNode parentNode in parents) {
      allNodes.addAll(_getMethodCalls(parentNode));
    }

    final List<MethodCallInvokerNode> uniqueNodes =
        LinkedHashSet<MethodCallInvokerNode>.from(allNodes).toList();

    uniqueNodes.sort((MethodCallInvokerNode a, MethodCallInvokerNode b) =>
        a.timestamp.compareTo(b.timestamp));

    final List<MethodCall> methodCalls = <MethodCall>[
      ...uniqueNodes
          .map<MethodCall>((MethodCallInvokerNode node) => node.methodCall),
      methodCall,
    ];

    return Channel.channel.invokeMethod<T>(
      'Invoke',
      _serializeMethodCalls(methodCalls).toList(),
    );
  }

  Future<List<T>> invokeList<T>() {
    final Completer<List<T>> completer = Completer<List<T>>();
    invoke<List<dynamic>>().then((_) => completer.complete(_?.cast<T>()));
    return completer.future;
  }

  Future<Map<T, S>> invokeMap<T, S>() {
    final Completer<Map<T, S>> completer = Completer<Map<T, S>>();
    invoke<Map<dynamic, dynamic>>().then(
      (_) => completer.complete(_?.cast<T, S>()),
    );
    return completer.future;
  }

  List<MethodCallInvokerNode> _getMethodCalls(
    MethodCallInvokerNode currentNode,
  ) {
    if (currentNode == null || currentNode.type == NodeType.allocator) {
      return <MethodCallInvokerNode>[];
    }

    final List<MethodCallInvokerNode> nodes = <MethodCallInvokerNode>[];
    nodes.add(currentNode);

    for (MethodCallInvokerNode node in currentNode.parents) {
      nodes.addAll(_getMethodCalls(node));
    }

    return nodes;
  }

  Iterable<Map<String, dynamic>> _serializeMethodCalls(
    Iterable<MethodCall> methodCalls,
  ) {
    return methodCalls.map<Map<String, dynamic>>(
      (MethodCall methodCall) => <String, dynamic>{
        'method': methodCall.method,
        'arguments': methodCall.arguments,
      },
    );
  }
}

enum NodeType { regular, allocator, disposer }
