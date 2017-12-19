part of cloud_firestore;

/// [MessageCodec] using the Flutter standard binary encoding.
///
/// Supported messages are acyclic values of these forms:
///
///  * null
///  * [bool]s
///  * [num]s
///  * [String]s
///  * [Uint8List]s, [Int32List]s, [Int64List]s, [Float64List]s
///  * [List]s of supported values
///  * [Map]s from supported values to supported values
///  * [DateTime]s
///  * [FieldValue]s
///  * [GeoPoint]s
///  * [DocumentReference]s
///
/// On Android, messages are represented as follows:
///
///  * null: null
///  * [bool]\: `java.lang.Boolean`
///  * [int]\: `java.lang.Integer` for values that are representable using 32-bit
///    two's complement; otherwise, `java.lang.Long` for values that are
///    representable using 64-bit two's complement; otherwise,
///    `java.math.BigInteger`.
///  * [double]\: `java.lang.Double`
///  * [String]\: `java.lang.String`
///  * [Uint8List]\: `byte[]`
///  * [Int32List]\: `int[]`
///  * [Int64List]\: `long[]`
///  * [Float64List]\: `double[]`
///  * [List]\: `java.util.ArrayList`
///  * [Map]\: `java.util.HashMap`
///  * [DateTime]\: `java.util.Date`
///  * [FieldValue]\: `firestore.FieldValue: 0 -> delete, 1 -> serverTimestamp`
///  * [GeoPoint]\: `firestore.GeoPoint`
///  * [DocumentReference]\: `firestore.DocumentReference`
///
/// On iOS, messages are represented as follows:
///
///  * null: nil
///  * [bool]\: `NSNumber numberWithBool:`
///  * [int]\: `NSNumber numberWithInt:` for values that are representable using
///    32-bit two's complement; otherwise, `NSNumber numberWithLong:` for values
///    that are representable using 64-bit two's complement; otherwise,
///    `FlutterStandardBigInteger`.
///  * [double]\: `NSNumber numberWithDouble:`
///  * [String]\: `NSString`
///  * [Uint8List], [Int32List], [Int64List], [Float64List]\:
///    `FlutterStandardTypedData`
///  * [List]\: `NSArray`
///  * [Map]\: `NSDictionary`
///  * [Date]\: `NSDate`
///  * [FieldValue]\: `FIRFieldValue`
///  * [GeoPoint]\: `FIRGeoPoint`
///  * [DocumentReference]\: `FIRDocumentReference`
class FirestoreMessageCodec implements MessageCodec<dynamic> {
  // The codec serializes messages as outlined below. This format must
  // match the Android and iOS counterparts.
  //
  // * A single byte with one of the constant values below determines the
  //   type of the value.
  // * The serialization of the value itself follows the type byte.
  // * Numbers are represented using the host endianness throughout.
  // * Lengths and sizes of serialized parts are encoded using an expanding
  //   format optimized for the common case of small non-negative integers:
  //   * values 0..253 inclusive using one byte with that value;
  //   * values 254..2^16 inclusive using three bytes, the first of which is
  //     254, the next two the usual unsigned representation of the value;
  //   * values 2^16+1..2^32 inclusive using five bytes, the first of which is
  //     255, the next four the usual unsigned representation of the value.
  // * null, true, and false have empty serialization; they are encoded directly
  //   in the type byte (using _kNull, _kTrue, _kFalse)
  // * Integers representable in 32 bits are encoded using 4 bytes two's
  //   complement representation.
  // * Larger integers representable in 64 bits are encoded using 8 bytes two's
  //   complement representation.
  // * Still larger integers are encoded using their hexadecimal string
  //   representation. First the length of that is encoded in the expanding
  //   format, then follows the UTF-8 representation of the hex string.
  // * doubles are encoded using the IEEE 754 64-bit double-precision binary
  //   format.
  // * Strings are encoded using their UTF-8 representation. First the length
  //   of that in bytes is encoded using the expanding format, then follows the
  //   UTF-8 encoding itself.
  // * Uint8Lists, Int32Lists, Int64Lists, and Float64Lists are encoded by first
  //   encoding the list's element count in the expanding format, then the
  //   smallest number of zero bytes needed to align the position in the full
  //   message with a multiple of the number of bytes per element, then the
  //   encoding of the list elements themselves, end-to-end with no additional
  //   type information, using two's complement or IEEE 754 as applicable.
  // * Lists are encoded by first encoding their length in the expanding format,
  //   then follows the recursive encoding of each element value, including the
  //   type byte (Lists are assumed to be heterogeneous).
  // * Maps are encoded by first encoding their length in the expanding format,
  //   then follows the recursive encoding of each key/value pair, including the
  //   type byte for both (Maps are assumed to be heterogeneous).
  // * DateTimes are encoded using an Int64 representation of 
  //   microsecondsSinceEpoch.
  // * FieldValues are encoded as an int 0 or 1, for delete() and serverTimestamp,
  //   respectively.
  // * GeoPoints are encoded as two double separate values.
  // * DocumentReferences are encoded as a UTF8 string, using path.
  static const int _kNull = 0;
  static const int _kTrue = 1;
  static const int _kFalse = 2;
  static const int _kInt32 = 3;
  static const int _kInt64 = 4;
  static const int _kLargeInt = 5;
  static const int _kFloat64 = 6;
  static const int _kString = 7;
  static const int _kUint8List = 8;
  static const int _kInt32List = 9;
  static const int _kInt64List = 10;
  static const int _kFloat64List = 11;
  static const int _kList = 12;
  static const int _kMap = 13;
  static const int _kDateTime = 14;
  static const int _kFieldValue = 15;
  static const int _kGeoPoint = 16;
  static const int _kDocumentReference = 17;

  /// Creates a [MessageCodec] using the Flutter standard binary encoding.
  const FirestoreMessageCodec();

  @override
  ByteData encodeMessage(dynamic message) {
    if (message == null) return null;
    final WriteBuffer buffer = new WriteBuffer();
    _writeValue(buffer, message);
    return buffer.done();
  }

  @override
  dynamic decodeMessage(ByteData message) {
    if (message == null) return null;
    final ReadBuffer buffer = new ReadBuffer(message);
    final dynamic result = _readValue(buffer);
    if (buffer.hasRemaining) throw const FormatException('Message corrupted');
    return result;
  }

  static void _writeSize(WriteBuffer buffer, int value) {
    assert(0 <= value && value <= 0xffffffff);
    if (value < 254) {
      buffer.putUint8(value);
    } else if (value <= 0xffff) {
      buffer.putUint8(254);
      buffer.putUint16(value);
    } else {
      buffer.putUint8(255);
      buffer.putUint32(value);
    }
  }

  static void _writeValue(WriteBuffer buffer, dynamic value) {
    if (value == null) {
      buffer.putUint8(_kNull);
    } else if (value is bool) {
      buffer.putUint8(value ? _kTrue : _kFalse);
    } else if (value is int) {
      if (-0x7fffffff - 1 <= value && value <= 0x7fffffff) {
        buffer.putUint8(_kInt32);
        buffer.putInt32(value);
      } else if (-0x7fffffffffffffff - 1 <= value &&
          value <= 0x7fffffffffffffff) {
        buffer.putUint8(_kInt64);
        buffer.putInt64(value);
      } else {
        buffer.putUint8(_kLargeInt);
        final List<int> hex = UTF8.encoder.convert(value.toRadixString(16));
        _writeSize(buffer, hex.length);
        buffer.putUint8List(hex);
      }
    } else if (value is double) {
      buffer.putUint8(_kFloat64);
      buffer.putFloat64(value);
    } else if (value is String) {
      buffer.putUint8(_kString);
      final List<int> bytes = UTF8.encoder.convert(value);
      _writeSize(buffer, bytes.length);
      buffer.putUint8List(bytes);
    } else if (value is Uint8List) {
      buffer.putUint8(_kUint8List);
      _writeSize(buffer, value.length);
      buffer.putUint8List(value);
    } else if (value is Int32List) {
      buffer.putUint8(_kInt32List);
      _writeSize(buffer, value.length);
      buffer.putInt32List(value);
    } else if (value is Int64List) {
      buffer.putUint8(_kInt64List);
      _writeSize(buffer, value.length);
      buffer.putInt64List(value);
    } else if (value is Float64List) {
      buffer.putUint8(_kFloat64List);
      _writeSize(buffer, value.length);
      buffer.putFloat64List(value);
    } else if (value is List) {
      buffer.putUint8(_kList);
      _writeSize(buffer, value.length);
      for (final dynamic item in value) {
        _writeValue(buffer, item);
      }
    } else if (value is Map) {
      buffer.putUint8(_kMap);
      _writeSize(buffer, value.length);
      value.forEach((dynamic key, dynamic value) {
        _writeValue(buffer, key);
        _writeValue(buffer, value);
      });
    } else if (value is DateTime) {
      buffer.putUint8(_kDateTime);
      buffer.putInt64(value.microsecondsSinceEpoch);
    } else if (value is FieldValue) {
      buffer.putUint8(_kFieldValue);
      buffer.putInt32(value.type);
    } else if (value is GeoPoint) {
      buffer.putUint8(_kGeoPoint);
      buffer.putFloat64(value.latitude);
      buffer.putFloat64(value.longitude);
    } else if (value is DocumentReference) {
      buffer.putUint8(_kDocumentReference);
      final List<int> bytes = UTF8.encoder.convert(value.path);
      _writeSize(buffer, bytes.length);
      buffer.putUint8List(bytes);
    } else {
      throw new ArgumentError.value(value);
    }
  }

  static int _readSize(ReadBuffer buffer) {
    final int value = buffer.getUint8();
    if (value < 254)
      return value;
    else if (value == 254)
      return buffer.getUint16();
    else
      return buffer.getUint32();
  }

  static dynamic _readValue(ReadBuffer buffer) {
    if (!buffer.hasRemaining) throw const FormatException('Message corrupted');
    dynamic result;
    switch (buffer.getUint8()) {
      case _kNull:
        result = null;
        break;
      case _kTrue:
        result = true;
        break;
      case _kFalse:
        result = false;
        break;
      case _kInt32:
        result = buffer.getInt32();
        break;
      case _kInt64:
        result = buffer.getInt64();
        break;
      case _kLargeInt:
        final int length = _readSize(buffer);
        final String hex = UTF8.decoder.convert(buffer.getUint8List(length));
        result = int.parse(hex, radix: 16);
        break;
      case _kFloat64:
        result = buffer.getFloat64();
        break;
      case _kString:
        final int length = _readSize(buffer);
        result = UTF8.decoder.convert(buffer.getUint8List(length));
        break;
      case _kUint8List:
        final int length = _readSize(buffer);
        result = buffer.getUint8List(length);
        break;
      case _kInt32List:
        final int length = _readSize(buffer);
        result = buffer.getInt32List(length);
        break;
      case _kInt64List:
        final int length = _readSize(buffer);
        result = buffer.getInt64List(length);
        break;
      case _kFloat64List:
        final int length = _readSize(buffer);
        result = buffer.getFloat64List(length);
        break;
      case _kList:
        final int length = _readSize(buffer);
        result = new List<dynamic>(length);
        for (int i = 0; i < length; i++) {
          result[i] = _readValue(buffer);
        }
        break;
      case _kMap:
        final int length = _readSize(buffer);
        result = <dynamic, dynamic>{};
        for (int i = 0; i < length; i++) {
          result[_readValue(buffer)] = _readValue(buffer);
        }
        break;
      case _kDateTime:
        final int microseconds = buffer.getInt64();
        result = new DateTime.fromMicrosecondsSinceEpoch(microseconds);
        break;
      case _kFieldValue:
        switch (buffer.getInt32()) {
          case 0:
            result = FieldValue.delete;
            break;
          case 1:
            result = FieldValue.serverTimestamp;
            break;
          default:
            throw const FormatException('Message corrupted/invalid FieldValue');
        }
        break;
      case _kGeoPoint:
        final double latitude = buffer.getFloat64();
        final double longitude = buffer.getFloat64();
        result = new GeoPoint(latitude, longitude);
        break;
      case _kDocumentReference:
        final int length = _readSize(buffer);
        final String path = UTF8.decoder.convert(buffer.getUint8List(length));
        result = Firestore.instance.document(path);
        break;
      default:
        throw const FormatException('Message corrupted');
    }
    return result;
  }
}

/// [MethodCodec] using the Flutter standard binary encoding.
///
/// The standard codec is guaranteed to be compatible with the corresponding
/// standard codec for FlutterMethodChannels on the host platform. These parts
/// of the Flutter SDK are evolved synchronously.
///
/// Values supported as method arguments and result payloads are those supported
/// by [FirestoreMessageCodec].
class FirestoreMethodCodec implements MethodCodec {
  // The codec method calls, and result envelopes as outlined below. This format
  // must match the Android and iOS counterparts.
  //
  // * Individual values are encoded using [FirestoreMessageCodec].
  // * Method calls are encoded using the concatenation of the encoding
  //   of the method name String and the arguments value.
  // * Reply envelopes are encoded using first a single byte to distinguish the
  //   success case (0) from the error case (1). Then follows:
  //   * In the success case, the encoding of the result value.
  //   * In the error case, the concatenation of the encoding of the error code
  //     string, the error message string, and the error details value.

  /// Creates a [MethodCodec] using the Flutter standard binary encoding.
  const FirestoreMethodCodec();

  @override
  ByteData encodeMethodCall(MethodCall call) {
    final WriteBuffer buffer = new WriteBuffer();
    FirestoreMessageCodec._writeValue(buffer, call.method);
    FirestoreMessageCodec._writeValue(buffer, call.arguments);
    return buffer.done();
  }

  @override
  MethodCall decodeMethodCall(ByteData methodCall) {
    final ReadBuffer buffer = new ReadBuffer(methodCall);
    final dynamic method = FirestoreMessageCodec._readValue(buffer);
    final dynamic arguments = FirestoreMessageCodec._readValue(buffer);
    if (method is String && !buffer.hasRemaining)
      return new MethodCall(method, arguments);
    else
      throw const FormatException('Invalid method call');
  }

  @override
  ByteData encodeSuccessEnvelope(dynamic result) {
    final WriteBuffer buffer = new WriteBuffer();
    buffer.putUint8(0);
    FirestoreMessageCodec._writeValue(buffer, result);
    return buffer.done();
  }

  @override
  ByteData encodeErrorEnvelope(
      {@required String code, String message, dynamic details}) {
    final WriteBuffer buffer = new WriteBuffer();
    buffer.putUint8(1);
    FirestoreMessageCodec._writeValue(buffer, code);
    FirestoreMessageCodec._writeValue(buffer, message);
    FirestoreMessageCodec._writeValue(buffer, details);
    return buffer.done();
  }

  @override
  dynamic decodeEnvelope(ByteData envelope) {
    // First byte is zero in success case, and non-zero otherwise.
    if (envelope.lengthInBytes == 0)
      throw const FormatException('Expected envelope, got nothing');
    final ReadBuffer buffer = new ReadBuffer(envelope);
    if (buffer.getUint8() == 0) return FirestoreMessageCodec._readValue(buffer);
    final dynamic errorCode = FirestoreMessageCodec._readValue(buffer);
    final dynamic errorMessage = FirestoreMessageCodec._readValue(buffer);
    final dynamic errorDetails = FirestoreMessageCodec._readValue(buffer);
    if (errorCode is String &&
        (errorMessage == null || errorMessage is String) &&
        !buffer.hasRemaining)
      throw new PlatformException(
          code: errorCode, message: errorMessage, details: errorDetails);
    else
      throw const FormatException('Invalid envelope');
  }
}
