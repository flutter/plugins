import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_example/main.dart' as app;

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (String _) => completer.future);
  app.main();

  group('$SharedPreferences', () {
    SharedPreferences preferences;

    setUp(() async {
      preferences = await SharedPreferences.getInstance();
    });

    tearDown(() {
      preferences.clear();
    });

    tearDownAll(() {
      completer.complete('pass');
    });

    test('golden basic', () async {
      await Future<void>.delayed(const Duration(seconds: 2));

      final Finder found = find.byKey(const Key('Test_Key'));
      final String base64Image = await _captureBase64Image(found);

      // TODO(kaushikiska) actual golden image testing here!
      print(base64Image);
    });
  });
}

Future<String> _captureBase64Image(dynamic item) async {
  Future<ui.Image> imageFuture;
  if (item is Future<ui.Image>) {
    imageFuture = item;
  } else if (item is ui.Image) {
    imageFuture = Future<ui.Image>.value(item);
  } else {
    final Finder finder = item;
    final Iterable<Element> elements = finder.evaluate();
    if (elements.isEmpty) {
      return 'could not be rendered because no widget was found';
    } else if (elements.length > 1) {
      return 'matched too many widgets';
    }
    imageFuture = _captureImage(elements.single);
  }

  final ui.Image image = await imageFuture;
  final ByteData bytes = await image
      .toByteData(format: ui.ImageByteFormat.png)
      .timeout(const Duration(seconds: 10));

  if (bytes == null)
    return 'Failed to generate screenshot from engine within the 10,000ms timeout.';

  return base64.encode(bytes.buffer.asUint8List());
}

Future<ui.Image> _captureImage(Element element) {
  RenderObject renderObject = element.renderObject;
  while (!renderObject.isRepaintBoundary) {
    renderObject = renderObject.parent;
    assert(renderObject != null);
  }
  assert(!renderObject.debugNeedsPaint);
  final OffsetLayer layer = renderObject.layer;
  return layer.toImage(renderObject.paintBounds);
}
