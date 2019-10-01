import 'dart:async';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('VideoPlayer test driver', () {
    test('VideoPlayer dispose without crash', () {
      final VideoPlayerController controller =
          VideoPlayerController.asset('assets/Butterfly-209.mp4');
      controller.play();
      controller.initialize();
    });
  });
}
