// Copyright 2018, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

const int _kThousand = 1000;
const int _kMillion = 1000000;
const int _kBillion = 1000000000;

void _check(bool expr, String name, int value) {
  if (!expr) {
    throw ArgumentError("Timestamp $name out of range: $value");
  }
}

/// A Timestamp represents a point in time independent of any time zone or calendar,
/// represented as seconds and fractions of seconds at nanosecond resolution in UTC
/// Epoch time. It is encoded using the Proleptic Gregorian Calendar which extends
/// the Gregorian calendar backwards to year one. It is encoded assuming all minutes
/// are 60 seconds long, i.e. leap seconds are "smeared" so that no leap second table
/// is needed for interpretation. Range is from 0001-01-01T00:00:00Z to
/// 9999-12-31T23:59:59.999999999Z. By restricting to that range, we ensure that we
/// can convert to and from RFC 3339 date strings.
///
/// For more information, see [the reference timestamp definition](https://github.com/google/protobuf/blob/master/src/google/protobuf/timestamp.proto)
class Timestamp implements Comparable<Timestamp> {
  Timestamp(this._seconds, this._nanoseconds) {
    _validateRange(_seconds, _nanoseconds);
  }

  factory Timestamp.fromMillisecondsSinceEpoch(int milliseconds) {
    final int seconds = (milliseconds / _kThousand).floor();
    final int nanoseconds = (milliseconds - seconds * _kThousand) * _kMillion;
    return Timestamp(seconds, nanoseconds);
  }

  factory Timestamp.fromMicrosecondsSinceEpoch(int microseconds) {
    final int seconds = (microseconds / _kMillion).floor();
    final int nanoseconds = (microseconds - seconds * _kMillion) * _kThousand;
    return Timestamp(seconds, nanoseconds);
  }

  factory Timestamp.fromDate(DateTime date) {
    return Timestamp.fromMicrosecondsSinceEpoch(date.microsecondsSinceEpoch);
  }

  factory Timestamp.now() {
    return Timestamp.fromMicrosecondsSinceEpoch(
        DateTime.now().microsecondsSinceEpoch);
  }

  final int _seconds;
  final int _nanoseconds;

  static const int _kStartOfTime = -62135596800;
  static const int _kEndOfTime = 253402300800;

  int get seconds => _seconds;

  int get nanoseconds => _nanoseconds;

  int get millisecondsSinceEpoch =>
      (seconds * _kThousand + nanoseconds / _kMillion).floor();

  int get microsecondsSinceEpoch =>
      (seconds * _kMillion + nanoseconds / _kThousand).floor();

  DateTime toDate() {
    return DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);
  }

  @override
  int get hashCode => hashValues(seconds, nanoseconds);
  @override
  bool operator ==(dynamic o) =>
      o is Timestamp && o.seconds == seconds && o.nanoseconds == nanoseconds;
  @override
  int compareTo(Timestamp other) {
    if (seconds == other.seconds) {
      return nanoseconds.compareTo(other.nanoseconds);
    }

    return seconds.compareTo(other.seconds);
  }

  @override
  String toString() {
    return "Timestamp(seconds=$seconds, nanoseconds=$nanoseconds)";
  }

  static void _validateRange(int seconds, int nanoseconds) {
    _check(nanoseconds >= 0, 'nanoseconds', nanoseconds);
    _check(nanoseconds < _kBillion, 'nanoseconds', nanoseconds);
    _check(seconds >= _kStartOfTime, 'seconds', seconds);
    _check(seconds < _kEndOfTime, 'seconds', seconds);
  }
}
