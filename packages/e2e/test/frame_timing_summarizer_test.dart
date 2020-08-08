import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:e2e/e2e_perf.dart';

void main() {
  test('Test FrameTimingSummarizer', () {
    List<int> buildTimes = <int>[
      for (int i = 1; i <= 100; i += 1) 1000 * i,
    ];
    buildTimes = buildTimes.reversed.toList();
    List<int> rasterTimes = <int>[
      for (int i = 1; i <= 100; i += 1) 1000 * i + 1000,
    ];
    rasterTimes = rasterTimes.reversed.toList();
    List<FrameTiming> inputData = <FrameTiming>[
      for (int i = 0; i < 100; i += 1)
        FrameTiming(<int>[0, buildTimes[i], 500, rasterTimes[i]]),
    ];
    FrameTimingSummarizer summary = FrameTimingSummarizer(inputData);
    expect(summary.averageFrameBuildTime.inMicroseconds, 50500);
    expect(summary.p90FrameBuildTime.inMicroseconds, 90000);
    expect(summary.p99FrameBuildTime.inMicroseconds, 99000);
    expect(summary.worstFrameBuildTime.inMicroseconds, 100000);
    expect(summary.missedFrameBuildBudget, 84);

    expect(summary.averageFrameRasterizerTime.inMicroseconds, 51000);
    expect(summary.p90FrameRasterizerTime.inMicroseconds, 90500);
    expect(summary.p99FrameRasterizerTime.inMicroseconds, 99500);
    expect(summary.worstFrameRasterizerTime.inMicroseconds, 100500);
    expect(summary.missedFrameRasterizerBudget, 85);
    expect(summary.frameBuildTime.length, 100);
  });
}
