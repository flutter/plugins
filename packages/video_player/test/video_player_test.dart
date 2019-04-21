import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeController extends ValueNotifier<VideoPlayerValue>
    implements VideoPlayerController {
  FakeController() : super(VideoPlayerValue(duration: null));

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  int textureId;

  @override
  String get dataSource => '';
  @override
  DataSourceType get dataSourceType => DataSourceType.file;
  @override
  String get package => null;
  @override
  Future<Duration> get position async => value.position;

  @override
  Future<void> seekTo(Duration moment) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> initialize() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> setLooping(bool looping) async {}
}

void main() {
  testWidgets('update texture', (WidgetTester tester) async {
    final FakeController controller = FakeController();
    await tester.pumpWidget(VideoPlayer(controller));
    expect(find.byType(Texture), findsNothing);

    controller.textureId = 123;
    controller.value = controller.value.copyWith(
      duration: const Duration(milliseconds: 100),
    );

    await tester.pump();
    expect(find.byType(Texture), findsOneWidget);
  });

  testWidgets('update controller', (WidgetTester tester) async {
    final FakeController controller1 = FakeController();
    controller1.textureId = 101;
    await tester.pumpWidget(VideoPlayer(controller1));
    expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Texture && widget.textureId == 101,
        ),
        findsOneWidget);

    final FakeController controller2 = FakeController();
    controller2.textureId = 102;
    await tester.pumpWidget(VideoPlayer(controller2));
    expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Texture && widget.textureId == 102,
        ),
        findsOneWidget);
  });
}
