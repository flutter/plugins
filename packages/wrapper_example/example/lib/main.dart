import 'package:flutter/material.dart';
import 'package:wrapper_example/wrapper_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              final MyClass myClass = MyClass('apple', MyOtherClass());
              myClass.myMethod('banana', MyOtherClass());
            },
            child: const Text('Click'),
          ),
        ),
      ),
    );
  }
}
