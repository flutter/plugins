// Copyright 2017, the Flutter project authors. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
//     * Neither the name of Google Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fble/fble.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<BluetoothAdapter> _adapters = <BluetoothAdapter>[];
  BluetoothAdapter _selectedAdapter;
  StreamSubscription<ScanResult> _scanResultSubscription;
  final Set<DeviceIdentifier> _scanningAdapters = new Set<DeviceIdentifier>();

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    List<BluetoothAdapter> adapters;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      adapters = await Fble.localAdapters;
    } on PlatformException {
      // Ignored.
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _adapters = adapters;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> adapterButtons = _adapters
        .map((a) => new Container(
            margin: const EdgeInsets.all(8.0),
            child: new RaisedButton(
              onPressed: _selectAdapter(a),
              child: new Text(a.identifier.toString()),
              color: _scanningAdapters.contains(a.identifier)
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).primaryColor,
            )))
        .toList();
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter BLE example app'),
        ),
        body: new Center(
          child: new Column(children: adapterButtons),
        ),
      ),
      title: 'Flutter BLE example app',
    );
  }

  VoidCallback _selectAdapter(BluetoothAdapter adapter) {
    return () {
      if (_selectedAdapter != null) {
        _scanResultSubscription.cancel();
        _selectedAdapter.stopScan();
        _scanningAdapters.remove(adapter.identifier);
        print('Stop scanning on ${_selectedAdapter.identifier}');
        if (adapter.identifier == _selectedAdapter.identifier) {
          setState(() {
            _selectedAdapter = null;
            _scanResultSubscription = null;
          });
          return;
        }
      }
      setState(() {
        _selectedAdapter = adapter;
        _scanningAdapters.add(adapter.identifier);
        _scanResultSubscription =
            _selectedAdapter.startScan().listen(_onScanResult);
        print('Start scanning on ${_selectedAdapter.identifier}');
      });
    };
  }

  void _onScanResult(ScanResult result) {
    print('${result.identifier} ${result.name} ${result.rssi} '
        '${result.advertisementData}');
  }
}
