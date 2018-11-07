import 'package:test/test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('math functions', () {
    test('basic clipper test', () {
      final double res = clip(1.0, 2.0, 3.0);
      expect(res, 2.0);
    });
    test('clipper negative numbers', () {
      final double res = clip(-10.0, -3.0, -2.0);
      expect(res, -3.0);
    });
    test('basic wrap test', () {
      final double res = wrap(42.0, -180.0, 180.0);
      expect(res, 42.0);
    });
    test('wrap negative number', () {
      final double res = wrap(-236.457, -180.0, 180.0);
      expect(res, 123.543);
    });
  });

  group('LatLngBounds', () {
    group('LatLngBounds.isEmpty()', () {
      test('empty.', () {
        final LatLngBounds bounds = LatLngBounds();
        final bool res = bounds.isEmpty();
        expect(res, true);
      });
      test('not empty.', () {
        final LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(10.0, 20.0),
          northeast: LatLng(30.0, 40.0),
        );
        final bool res = bounds.isEmpty();
        expect(res, false);
      });
    });

    group('LatLngBounds.center', () {
      test('all positive', () {
        final LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(10.0, 20.0),
          northeast: LatLng(30.0, 40.0),
        );
        final LatLng res = bounds.center;
        expect(res, LatLng(20.0, 30.0));
      });
      test('east < west', () {
        final LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(-40.0, 150.0),
          northeast: LatLng(20.0, -170.0),
        );
        final LatLng res = bounds.center;
        expect(res, LatLng(-10.0, 170.0));
      });
    });

    group('LatLngBounds.contains()', () {
      test('all positive', () {
        final LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(10.0, 20.0),
          northeast: LatLng(30.0, 40.0),
        );
        final bool res = bounds.contains(LatLng(20.0, 30.0));
        expect(res, true);
      });
      test('all positive outside()'
          '8', () {
        final LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(10.0, 20.0),
          northeast: LatLng(30.0, 40.0),
        );
        final bool res = bounds.contains(LatLng(1.0, 1.0));
        expect(res, false);
      });
      test('east < west', () {
        final LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(-40.0, 150.0),
          northeast: LatLng(20.0, -170.0),
        );
        final bool res = bounds.contains(LatLng(-10.0, 170.0));
        expect(res, true);
      });
      test('east < west outside', () {
        final LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(-40.0, 150.0),
          northeast: LatLng(20.0, -170.0),
        );
        final bool res = bounds.contains(LatLng(-10.0, 130.0));
        expect(res, false);
      });

      group('LatLngBounds.intersects()', () {
        test('all positive', () {
          final LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(10.0, 20.0),
            northeast: LatLng(30.0, 40.0),
          );
          final LatLngBounds bounds2 = LatLngBounds(
            southwest: LatLng(10.0, 30.0),
            northeast: LatLng(30.0, 50.0),
          );
          final bool res = bounds.intersects(bounds2);
          expect(res, true);
        });
        test('all positive outside', () {
          final LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(10.0, 20.0),
            northeast: LatLng(30.0, 40.0),
          );
          final LatLngBounds bounds2 = LatLngBounds(
            southwest: LatLng(10.0, 50.0),
            northeast: LatLng(30.0, 70.0),
          );
          final bool res = bounds.intersects(bounds2);
          expect(res, false);
        });
        test('east < west', () {
          final LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(-40.0, 150.0),
            northeast: LatLng(20.0, -170.0),
          );
          final LatLngBounds bounds2 = LatLngBounds(
            southwest: LatLng(-40.0, -175.0),
            northeast: LatLng(20.0, -130.0),
          );
          final bool res = bounds.intersects(bounds2);
          expect(res, true);
        });
        test('east < west outside', () {
          final LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(-40.0, 150.0),
            northeast: LatLng(20.0, -170.0),
          );
          final LatLngBounds bounds2 = LatLngBounds(
            southwest: LatLng(-40.0, 20.0),
            northeast: LatLng(20.0, 40.0),
          );
          final bool res = bounds.intersects(bounds2);
          expect(res, false);
        });
      });

      group('LatLngBounds.union()', () {
        test('all positive', () {
          final LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(10.0, 20.0),
            northeast: LatLng(30.0, 40.0),
          );
          final LatLngBounds bounds2 = LatLngBounds(
            southwest: LatLng(10.0, 30.0),
            northeast: LatLng(30.0, 50.0),
          );
          final LatLngBounds res = bounds.union(bounds2);
          expect(res.southwest, LatLng(10.0, 20.0));
          expect(res.northeast, LatLng(30.0, 50.0));
        });
        test('all positive outside', () {
          final LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(10.0, 20.0),
            northeast: LatLng(30.0, 40.0),
          );
          final LatLngBounds bounds2 = LatLngBounds(
            southwest: LatLng(10.0, 50.0),
            northeast: LatLng(30.0, 70.0),
          );
          final LatLngBounds res = bounds.union(bounds2);
          expect(res.southwest, LatLng(10.0, 20.0));
          expect(res.northeast, LatLng(30.0, 70.0));
        });
        test('east < west', () {
          final LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(-40.0, 150.0),
            northeast: LatLng(20.0, -170.0),
          );
          final LatLngBounds bounds2 = LatLngBounds(
            southwest: LatLng(-40.0, -175.0),
            northeast: LatLng(20.0, -130.0),
          );
          final LatLngBounds res = bounds.union(bounds2);
          expect(res.southwest, LatLng(-40.0, 150.0));
          expect(res.northeast, LatLng(20.0, -130.0));
        });
        test('east < west outside', () {
          final LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(-40.0, 150.0),
            northeast: LatLng(20.0, -170.0),
          );
          final LatLngBounds bounds2 = LatLngBounds(
            southwest: LatLng(-40.0, 20.0),
            northeast: LatLng(20.0, 40.0),
          );
          final LatLngBounds res = bounds.union(bounds2);
          expect(res.southwest, LatLng(-40.0, 20.0));
          expect(res.northeast, LatLng(20.0, -170.0));
        });
        test('full circle2', () {
          final LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(-40.0, 80.0),
            northeast: LatLng(20.0, -80.0),
          );
          final LatLngBounds bounds2 = LatLngBounds(
            southwest: LatLng(-40.0, -100.0),
            northeast: LatLng(20.0, 100.0),
          );
          final LatLngBounds res = bounds.union(bounds2);
          expect(res.southwest, LatLng(-40.0, -180.0));
          expect(res.northeast, LatLng(20.0, 180.0));
        });
      });

      group('LatLngBounds.extend()', () {
        test('all positive within', () {
          final LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(10.0, 20.0),
            northeast: LatLng(30.0, 40.0),
          );
          final LatLngBounds res = bounds.extend(LatLng(20.0, 30.0));
          expect(bounds.southwest, LatLng(10.0, 20.0));
          expect(bounds.northeast, LatLng(30.0, 40.0));
        });
        test('all positive outside', () {
          final LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(10.0, 20.0),
            northeast: LatLng(30.0, 40.0),
          );
          final LatLngBounds res = bounds.extend(LatLng(1.0, 1.0));
          expect(bounds.southwest, LatLng(1.0, 1.0));
          expect(bounds.northeast, LatLng(30.0, 40.0));
        });
        test('east < west', () {
          final LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(-40.0, 150.0),
            northeast: LatLng(20.0, -170.0),
          );
          final LatLngBounds res = bounds.extend(LatLng(-10.0, 170.0));
          expect(bounds.southwest, LatLng(-40.0, 150.0));
          expect(bounds.northeast, LatLng(20.0, -170.0));
        });
        test('east < west outside', () {
          final LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(-40.0, 150.0),
            northeast: LatLng(20.0, -170.0),
          );
          final LatLngBounds res = bounds.extend(LatLng(-10.0, 130.0));
          expect(bounds.southwest, LatLng(-40.0, 130.0));
          expect(bounds.northeast, LatLng(20.0, -170.0));
        });
      });
    });
  });
}
