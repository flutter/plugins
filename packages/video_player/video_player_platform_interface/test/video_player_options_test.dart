import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  test(
    'VideoPlayerOptions allowBackgroundPlayback defaults to false',
    () {
      final VideoPlayerOptions options = VideoPlayerOptions();
      expect(options.allowBackgroundPlayback, false);
    },
  );
  test(
    'VideoPlayerOptions mixWithOthers defaults to false',
    () {
      final VideoPlayerOptions options = VideoPlayerOptions();
      expect(options.mixWithOthers, false);
    },
  );
}
