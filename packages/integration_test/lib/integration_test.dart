// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:test_core/src/direct_run.dart';
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart' as vm_io;

import 'common.dart';
import '_extension_io.dart' if (dart.library.html) '_extension_web.dart';
import '_callback_io.dart' if (dart.library.html) '_callback_web.dart'
    as driver_actions;
import 'src/constants.dart';
import 'src/reporter.dart';

bool _isUsingLegacyReporting = true;

/// Executes a block that contains tests.
///
/// Example Usage:
/// ```
/// import 'package:flutter_test/flutter_test.dart';
/// import 'package:integration_test/integration_test.dart';
///
/// void main() => run(_testMain);
///
/// void _testMain() {
///   test('A test', () {
///     expect(true, true);
///   });
/// }
/// ```
///
/// The returned future will complete with the test results of the running
/// [testMain]. These results will also be sent to native over the platform
/// channel, unless [reportResultsToNative] is set to false.
// TODO(jiahaog): Have stronger types for the returned success / failure result.
Future<Map<String, Object>> run(FutureOr<void> Function() testMain,
    {bool reportResultsToNative = true}) async {
  assert(WidgetsBinding.instance == null);

  _isUsingLegacyReporting = false;
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Pipe detailed exceptions within [testWidgets] to `package:test`.
  reportTestException = (FlutterErrorDetails details, String testDescription) {
    registerException('Test $testDescription failed: $details');
  };

  final Completer<Map<String, Object>> resultsCompleter =
      Completer<Map<String, Object>>();

  await directRunTests(
    testMain,
    reporterFactory: (engine) => ResultReporter(engine, resultsCompleter),
  );

  final Map<String, Object> results = await resultsCompleter.future;

  if (reportResultsToNative) {
    await _reportResultsToNative(binding, results);
  }
  return results;
}

String _formatFailureForPlatform(Failure failure) =>
    '${failure.error} ${failure.details}';

Future<void> _reportResultsToNative(
    IntegrationTestWidgetsFlutterBinding binding,
    Map<String, Object> results) async {
  binding.results = results;
  print('Test execution completed: ${binding.results}');

  binding._allTestsPassed
      .complete(!binding.results.values.any((val) => val is Failure));

  try {
    binding.callbackManager.cleanup();
    await IntegrationTestWidgetsFlutterBinding._channel.invokeMethod<void>(
      'allTestsFinished',
      <String, dynamic>{
        'results': {
          for (final result in binding.results.entries)
            result.key: result.value is Failure
                ? _formatFailureForPlatform(result.value)
                : result.value
        }
      },
    );
  } on MissingPluginException {
    print('Warning: integration_test test plugin was not detected.');
  }
}

/// A subclass of [LiveTestWidgetsFlutterBinding] that reports tests results
/// on a channel to adapt them to native instrumentation test format.
class IntegrationTestWidgetsFlutterBinding extends LiveTestWidgetsFlutterBinding
    implements IntegrationTestResults {
  /// If [run] is not used, sets up a listener to report that the tests are
  /// finished when everything is torn down.
  ///
  /// This functionality is deprecated – clients are expected to use [run] to
  /// execute their tests instead.
  IntegrationTestWidgetsFlutterBinding() {
    if (!_isUsingLegacyReporting) return;

    tearDownAll(() => _reportResultsToNative(this, results));

    final TestExceptionReporter oldTestExceptionReporter = reportTestException;
    reportTestException =
        (FlutterErrorDetails details, String testDescription) {
      results[testDescription] = Failure(testDescription, details.toString(),
          error: details.exception);
      oldTestExceptionReporter(details, testDescription);
    };
  }

  // TODO(dnfield): Remove the ignore once we bump the minimum Flutter version
  // ignore: override_on_non_overriding_member
  @override
  bool get overrideHttpClient => false;

  // TODO(dnfield): Remove the ignore once we bump the minimum Flutter version
  // ignore: override_on_non_overriding_member
  @override
  bool get registerTestTextInput => false;

  Size _surfaceSize;

  // This flag is used to print warning messages when tracking performance
  // under debug mode.
  static bool _firstRun = false;

  /// Artificially changes the surface size to `size` on the Widget binding,
  /// then flushes microtasks.
  ///
  /// Set to null to use the default surface size.
  @override
  Future<void> setSurfaceSize(Size size) {
    return TestAsyncUtils.guard<void>(() async {
      assert(inTest);
      if (_surfaceSize == size) {
        return;
      }
      _surfaceSize = size;
      handleMetricsChanged();
    });
  }

  @override
  ViewConfiguration createViewConfiguration() {
    final double devicePixelRatio = window.devicePixelRatio;
    final Size size = _surfaceSize ?? window.physicalSize / devicePixelRatio;
    return TestViewConfiguration(
      size: size,
      window: window,
    );
  }

  @override
  Completer<bool> get allTestsPassed => _allTestsPassed;
  final Completer<bool> _allTestsPassed = Completer<bool>();

  @override
  List<Failure> get failureMethodsDetails => _failures;

  /// Similar to [WidgetsFlutterBinding.ensureInitialized].
  ///
  /// Returns an instance of the [IntegrationTestWidgetsFlutterBinding], creating and
  /// initializing it if necessary.
  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) {
      IntegrationTestWidgetsFlutterBinding();
    }
    assert(WidgetsBinding.instance is IntegrationTestWidgetsFlutterBinding);
    return WidgetsBinding.instance;
  }

  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/integration_test');

  /// Test results that will be populated after the tests have completed.
  ///
  /// Keys are the test descriptions, and values are either [_success] or
  /// a [Failure].
  @visibleForTesting
  Map<String, Object> results = <String, Object>{};

  List<Failure> get _failures => results.values.whereType<Failure>().toList();

  /// The extra data for the reported result.
  ///
  /// The values in `reportData` must be json-serializable objects or `null`.
  /// If it's `null`, no extra data is attached to the result.
  ///
  /// The default value is `null`.
  @override
  Map<String, dynamic> get reportData => _reportData;
  Map<String, dynamic> _reportData;
  set reportData(Map<String, dynamic> data) => this._reportData = data;

  /// Manages callbacks received from driver side and commands send to driver
  /// side.
  final CallbackManager callbackManager = driver_actions.callbackManager;

  /// Taking a screenshot.
  ///
  /// Called by test methods. Implementation differs for each platform.
  Future<void> takeScreenshot(String screenshotName) async {
    await callbackManager.takeScreenshot(screenshotName);
  }

  /// The callback function to response the driver side input.
  @visibleForTesting
  Future<Map<String, dynamic>> callback(Map<String, String> params) async {
    return await callbackManager.callback(
        params, this /* as IntegrationTestResults */);
  }

  // Emulates the Flutter driver extension, returning 'pass' or 'fail'.
  @override
  void initServiceExtensions() {
    super.initServiceExtensions();

    if (kIsWeb) {
      registerWebServiceExtension(callback);
    }

    registerServiceExtension(name: 'driver', callback: callback);
  }

  @override
  Future<void> runTest(
    Future<void> testBody(),
    VoidCallback invariantTester, {
    String description = '',
    Duration timeout,
  }) async {
    await super.runTest(
      testBody,
      invariantTester,
      description: description,
      timeout: timeout,
    );
    results[description] ??= success;
  }

  vm.VmService _vmService;

  /// Initialize the [vm.VmService] settings for the timeline.
  @visibleForTesting
  Future<void> enableTimeline({
    List<String> streams = const <String>['all'],
    @visibleForTesting vm.VmService vmService,
  }) async {
    assert(streams != null);
    assert(streams.isNotEmpty);
    if (vmService != null) {
      _vmService = vmService;
    }
    if (_vmService == null) {
      final developer.ServiceProtocolInfo info =
          await developer.Service.getInfo();
      assert(info.serverUri != null);
      _vmService = await vm_io.vmServiceConnectUri(
        'ws://localhost:${info.serverUri.port}${info.serverUri.path}ws',
      );
    }
    await _vmService.setVMTimelineFlags(streams);
  }

  /// Runs [action] and returns a [vm.Timeline] trace for it.
  ///
  /// Waits for the `Future` returned by [action] to complete prior to stopping
  /// the trace.
  ///
  /// The `streams` parameter limits the recorded timeline event streams to only
  /// the ones listed. By default, all streams are recorded.
  /// See `timeline_streams` in
  /// [Dart-SDK/runtime/vm/timeline.cc](https://github.com/dart-lang/sdk/blob/master/runtime/vm/timeline.cc)
  ///
  /// If [retainPriorEvents] is true, retains events recorded prior to calling
  /// [action]. Otherwise, prior events are cleared before calling [action]. By
  /// default, prior events are cleared.
  Future<vm.Timeline> traceTimeline(
    Future<dynamic> action(), {
    List<String> streams = const <String>['all'],
    bool retainPriorEvents = false,
  }) async {
    await enableTimeline(streams: streams);
    if (retainPriorEvents) {
      await action();
      return await _vmService.getVMTimeline();
    }

    await _vmService.clearVMTimeline();
    final vm.Timestamp startTime = await _vmService.getVMTimelineMicros();
    await action();
    final vm.Timestamp endTime = await _vmService.getVMTimelineMicros();
    return await _vmService.getVMTimeline(
      timeOriginMicros: startTime.timestamp,
      timeExtentMicros: endTime.timestamp,
    );
  }

  /// This is a convenience wrap of [traceTimeline] and send the result back to
  /// the host for the [flutter_driver] style tests.
  ///
  /// This records the timeline during `action` and adds the result to
  /// [reportData] with `reportKey`. [reportData] contains the extra information
  /// of the test other than test success/fail. It will be passed back to the
  /// host and be processed by the [ResponseDataCallback] defined in
  /// [integrationDriver]. By default it will be written to
  /// `build/integration_response_data.json` with the key `timeline`.
  ///
  /// For tests with multiple calls of this method, `reportKey` needs to be a
  /// unique key, otherwise the later result will override earlier one.
  ///
  /// The `streams` and `retainPriorEvents` parameters are passed as-is to
  /// [traceTimeline].
  Future<void> traceAction(
    Future<dynamic> action(), {
    List<String> streams = const <String>['all'],
    bool retainPriorEvents = false,
    String reportKey = 'timeline',
  }) async {
    vm.Timeline timeline = await traceTimeline(
      action,
      streams: streams,
      retainPriorEvents: retainPriorEvents,
    );
    reportData ??= <String, dynamic>{};
    reportData[reportKey] = timeline.toJson();
  }

  /// Watches the [FrameTiming] during `action` and report it to the binding
  /// with key `reportKey`.
  ///
  /// This can be used to implement performance tests previously using
  /// [traceAction] and [TimelineSummary] from [flutter_driver]
  Future<void> watchPerformance(
    Future<void> action(), {
    String reportKey = 'performance',
  }) async {
    assert(() {
      if (_firstRun) {
        debugPrint(kDebugWarning);
        _firstRun = false;
      }
      return true;
    }());

    // The engine could batch FrameTimings and send them only once per second.
    // Delay for a sufficient time so either old FrameTimings are flushed and not
    // interfering our measurements here, or new FrameTimings are all reported.
    // TODO(CareF): remove this when flush FrameTiming is readly in engine.
    //              See https://github.com/flutter/flutter/issues/64808
    //              and https://github.com/flutter/flutter/issues/67593
    Future<void> delayForFrameTimings() =>
        Future<void>.delayed(const Duration(seconds: 2));

    await delayForFrameTimings(); // flush old FrameTimings
    final List<FrameTiming> frameTimings = <FrameTiming>[];
    final TimingsCallback watcher = frameTimings.addAll;
    addTimingsCallback(watcher);
    await action();
    await delayForFrameTimings(); // make sure all FrameTimings are reported
    removeTimingsCallback(watcher);
    final FrameTimingSummarizer frameTimes =
        FrameTimingSummarizer(frameTimings);
    reportData ??= <String, dynamic>{};
    reportData[reportKey] = frameTimes.summary;
  }
}
