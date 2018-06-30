// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

/// Detector for performing optical character recognition(OCR) on an input image.
///
/// A barcode detector is created via getVisionBarcodeDetector() in [FirebaseVision]:
///
/// ```dart
/// BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
/// ```
class BarcodeDetector extends FirebaseVisionDetector {
  BarcodeDetector._();

  /// Closes the barcode detector and release its model resources.
  @override
  Future<void> close() async {
    return FirebaseVision.channel.invokeMethod('BarcodeDetector#close');
  }

  /// Detects barcode in the input image.
  ///
  /// The OCR is performed asynchronously.
  @override
  Future<void> detectInImage(FirebaseVisionImage visionImage) async {
    final List<dynamic> reply = await FirebaseVision.channel.invokeMethod(
      'BarcodeDetector#detectInImage',
      visionImage.imageFile.path,
    );

    final List<TextBlock> blocks = <TextBlock>[];
    reply.forEach((dynamic block) {
      blocks.add(new TextBlock._(block));
    });

    return blocks;
  }
}

class VisionBarcode {
  final Rectangle<int> rect;
  final String rawValue;
  final String displayValue;
  final VisionBarcodeFormat format;
  final List<Point<num>> cornerPoints;
  final VisionBarcodeValueType valueType;
  final VisionBarcodeEmail email;
  final VisionBarcodePhone phone;
  final VisionBarcodeSMS sms;
  final VisionBarcodeURLBookmark url;
  final VisionBarcodeWiFi wifi;
  final VisionBarcodeGeoPoint geoPoint;
  final VisionBarcodeContactInfo contactInfo;
  final VisionBarcodeCalendarEvent calendarEvent;
  final VisionBarcodeDriverLicense driverLicense;

  VisionBarcode._(Map<dynamic, dynamic> _data)
      : rect = Rectangle<int>(
          _data['left'],
          _data['top'],
          _data['width'],
          _data['height'],
        ),
        rawValue = _data['raw_value'] != null ? _data['raw_value'] : null,
        displayValue = _data['display_value'] ? _data['display_value'] : null,
        format = VisionBarcodeFormat._(_data['format']),
        cornerPoints = _data['points'] == null
            ? null
            : _data['points']
                .map<Point<num>>(
                    (dynamic item) => Point<num>(item['x'], item['y']))
                .toList(),
        valueType =
            VisionBarcodeValueType.values.elementAt(_data['value_type']),
        email = _data['email'] == null
            ? null
            : VisionBarcodeEmail._(_data['email']),
        phone = _data['phone'] == null
            ? null
            : VisionBarcodePhone._(_data['phone']),
        sms = _data['sms'] == null ? null : VisionBarcodeSMS._(_data['sms']),
        url = _data['url'] == null
            ? null
            : VisionBarcodeURLBookmark._(_data['url']),
        wifi =
            _data['wifi'] == null ? null : VisionBarcodeWiFi._(_data['wifi']),
        geoPoint = _data['geo_point'] == null
            ? null
            : VisionBarcodeGeoPoint._(_data['geo_point']),
        contactInfo = _data['contact_info'] == null
            ? null
            : VisionBarcodeContactInfo._(_data['contact_info']),
        calendarEvent = _data['calendar_event'] == null
            ? null
            : VisionBarcodeCalendarEvent._(_data['calendar_event']),
        driverLicense = _data['driver_license'] == null
            ? null
            : VisionBarcodeDriverLicense._(_data['driver_license']);
}

// ios:
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Enums/FIRVisionBarcodeFormat
// android:
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.BarcodeFormat
class VisionBarcodeFormat {
  final int value;
  const VisionBarcodeFormat._(this.value);

  static const VisionBarcodeFormat All = const VisionBarcodeFormat._(0xFFFF);
  static const VisionBarcodeFormat UnKnown = const VisionBarcodeFormat._(0);
  static const VisionBarcodeFormat Code128 =
      const VisionBarcodeFormat._(0x0001);
  static const VisionBarcodeFormat Code39 = const VisionBarcodeFormat._(0x0002);
  static const VisionBarcodeFormat Code93 = const VisionBarcodeFormat._(0x0004);
  static const VisionBarcodeFormat CodaBar =
      const VisionBarcodeFormat._(0x0008);
  static const VisionBarcodeFormat DataMatrix =
      const VisionBarcodeFormat._(0x0010);
  static const VisionBarcodeFormat EAN13 = const VisionBarcodeFormat._(0x0020);
  static const VisionBarcodeFormat EAN8 = const VisionBarcodeFormat._(0x0040);
  static const VisionBarcodeFormat ITF = const VisionBarcodeFormat._(0x0080);
  static const VisionBarcodeFormat QRCode = const VisionBarcodeFormat._(0x0100);
  static const VisionBarcodeFormat UPCA = const VisionBarcodeFormat._(0x0200);
  static const VisionBarcodeFormat UPCE = const VisionBarcodeFormat._(0x0400);
  static const VisionBarcodeFormat PDF417 = const VisionBarcodeFormat._(0x0800);
  static const VisionBarcodeFormat Aztec = const VisionBarcodeFormat._(0x1000);
}

enum VisionBarcodeValueType {
  /// Unknown Barcode value types.
  Unknown,

  /// Barcode value type for contact info.
  ContactInfo,

  /// Barcode value type for email addresses.
  Email,

  /// Barcode value type for ISBNs.
  ISBN,

  /// Barcode value type for phone numbers.
  Phone,

  /// Barcode value type for product codes.
  Product,

  /// Barcode value type for SMS details.
  SMS,

  /// Barcode value type for plain text.
  Text,

  /// Barcode value type for URLs/bookmarks.
  URL,

  /// Barcode value type for Wi-Fi access point details.
  WiFi,

  /// Barcode value type for geographic coordinates.
  GeographicCoordinates,

  /// Barcode value type for calendar events.
  CalendarEvent,

  /// Barcode value type for driver's license data.
  DriversLicense,
}

// ios
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Classes/FIRVisionBarcodeEmail
// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.Email
class VisionBarcodeEmail {
  VisionBarcodeEmail._(Map<dynamic, dynamic> data)
      : type = VisionBarcodeEmailType.values.elementAt(data['type']),
        address = data['address'] != null ? data['address'] : null,
        body = data['body'] != null ? data['body'] : null,
        subject = data['subject'] != null ? data['subject'] : null;

  final String address;
  final String body;
  final String subject;
  final VisionBarcodeEmailType type;
}

enum VisionBarcodeEmailType {
  /// Unknown email type.
  Unknown,

  /// Barcode work email type.
  Work,

  /// Barcode home email type.
  Home,
}

class VisionBarcodePhone {
  final String number;
  final VisionBarcodePhoneType type;
  VisionBarcodePhone._(Map<dynamic, dynamic> data)
      : number = data['number'] != null ? data['number'] : null,
        type = VisionBarcodePhoneType.values.elementAt(data['type']);
}

enum VisionBarcodePhoneType {
  /// Unknown phone type.
  Unknown,

  /// Barcode work phone type.
  Work,

  /// Barcode home phone type.
  Home,

  /// Barcode fax phone type.
  Fax,

  /// Barcode mobile phone type.
  Mobile,
}

// ios
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Classes/FIRVisionBarcodeURLBookmark
// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.Sms
class VisionBarcodeSMS {
  VisionBarcodeSMS._(Map<dynamic, dynamic> data)
      : message = data['message'] != null ? data['message'] : null,
        phoneNumber =
            data['phone_number'] != null ? data['phone_number'] : null;
  final String message;
  final String phoneNumber;
}

// ios
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Classes/FIRVisionBarcodeURLBookmark
// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.UrlBookmark
class VisionBarcodeURLBookmark {
  VisionBarcodeURLBookmark._(Map<dynamic, dynamic> data)
      : title = data['title'] != null ? data['title'] : null,
        url = data['url'] != null ? data['url'] : null;
  final String title;
  final String url;
}

// ios
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Classes/FIRVisionBarcodeWiFi
// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.WiFi
class VisionBarcodeWiFi {
  VisionBarcodeWiFi._(Map<dynamic, dynamic> data)
      : ssid = data['ssid'],
        password = data['password'],
        encryptionType = VisionBarcodeWiFiEncryptionType.values
            .elementAt(data['encryption_type']);

  final String ssid;
  final String password;
  final VisionBarcodeWiFiEncryptionType encryptionType;
}

// ios
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Enums/FIRVisionBarcodeWiFiEncryptionType
// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.WiFi.EncryptionType
enum VisionBarcodeWiFiEncryptionType {
  /// Barcode unknown Wi-Fi encryption type.
  Unknown,

  /// Barcode open Wi-Fi encryption type.
  Open,

  /// Barcode WPA Wi-Fi encryption type.
  WPA,

  /// Barcode WEP Wi-Fi encryption type.
  WEP,
}

// ios
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Classes/FIRVisionBarcodeGeoPoint
// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.GeoPoint
class VisionBarcodeGeoPoint {
  VisionBarcodeGeoPoint._(Map<dynamic, dynamic> data)
      : latitude = data['latitude'],
        longitude = data['longitude'];
  final double latitude;
  final double longitude;
}

// ios
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Classes/FIRVisionBarcodeContactInfo
// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.ContactInfo
class VisionBarcodeContactInfo {
  VisionBarcodeContactInfo._(Map<dynamic, dynamic> data)
      : addresses = data['addresses'] == null
            ? null
            : data['addresses']
                .map<VisionBarcodeAddress>(
                    (dynamic item) => VisionBarcodeAddress._(item))
                .toList(),
        emails = data['emails'] == null
            ? null
            : data['emails']
                .map<VisionBarcodeEmail>(
                    (dynamic item) => VisionBarcodeEmail._(item))
                .toList(),
        name = data['name'] == null
            ? null
            : VisionBarcodePersonName._(data['name']),
        phones = data['phones'] == null
            ? null
            : data['phones']
                .map<VisionBarcodePhone>(
                    (dynamic item) => VisionBarcodePhone._(item))
                .toList(),
        urls = data['urls'] == null
            ? null
            : data['urls'].map<String>((dynamic item) => item).toList(),
        jobTitle = data['job_title'] != null ? data['job_title'] : null,
        organization =
            data['organization'] != null ? data['organization'] : null;
  final List<VisionBarcodeAddress> addresses;
  final List<VisionBarcodeEmail> emails;
  final VisionBarcodePersonName name;
  final List<VisionBarcodePhone> phones;
  final List<String> urls;
  final String jobTitle;
  final String organization;
}

// ios
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Classes/FIRVisionBarcodeAddress
// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.Address
class VisionBarcodeAddress {
  VisionBarcodeAddress._(Map<dynamic, dynamic> data)
      : addressLines =
            data['address_lines'].map<String>((dynamic item) => item).toList(),
        type = VisionBarcodeAddressType.values.elementAt(data['type']);
  final List<String> addressLines;
  final VisionBarcodeAddressType type;
}

// ios
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Enums/FIRVisionBarcodeAddressType
// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.Address.AddressType
enum VisionBarcodeAddressType {
  /// Barcode unknown address type.
  Unknown,

  /// Barcode work address type.
  Work,

  /// Barcode home address type.
  Home,
}

// ios
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Classes/FIRVisionBarcodePersonName
// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.PersonName
class VisionBarcodePersonName {
  VisionBarcodePersonName._(Map<dynamic, dynamic> data)
      : formattedName =
            data['formatted_name'] != null ? data['formatted_name'] : null,
        first = data['first'] != null ? data['first'] : null,
        last = data['last'] != null ? data['last'] : null,
        middle = data['middle'] != null ? data['middle'] : null,
        prefix = data['prefix'] != null ? data['prefix'] : null,
        pronounciation =
            data['pronounciation'] != null ? data['pronounciation'] : null,
        suffix = data['suffix'] != null ? data['suffix'] : null;
  final String formattedName;
  final String first;
  final String last;
  final String middle;
  final String prefix;
  final String pronounciation;
  final String suffix;
}

// ios
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Classes/FIRVisionBarcodeCalendarEvent
// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.CalendarEvent
class VisionBarcodeCalendarEvent {
  VisionBarcodeCalendarEvent._(Map<dynamic, dynamic> data)
      : eventDescription = data['event_description'] != null
            ? data['event_description']
            : null,
        location = data['location'] != null ? data['location'] : null,
        organizer = data['organizer'] != null ? data['organizer'] : null,
        status = data['status'] != null ? data['status'] : null,
        summary = data['summary'] != null ? data['summary'] : null,
        start = data['start'] != null ? data['start'] : null,
        end = data['end'] != null ? data['end'] : null;
  final String eventDescription;
  final String location;
  final String organizer;
  final String status;
  final String summary;
  final DateTime start;
  final DateTime end;
}

// ios
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Classes/FIRVisionBarcodeDriverLicense
// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.DriverLicense
class VisionBarcodeDriverLicense {
  VisionBarcodeDriverLicense._(Map<dynamic, dynamic> data)
      : firstName = data['first_name'] != null ? data['first_name'] : null,
        middleName = data['middle_name'] != null ? data['middle_name'] : null,
        lastName = data['last_name'] != null ? data['last_name'] : null,
        gender = data['gender'] != null ? data['gender'] : null,
        addressCity =
            data['address_city'] != null ? data['address_city'] : null,
        addressState =
            data['address_state'] != null ? data['address_state'] : null,
        addressZip = data['address_zip'] != null ? data['address_zip'] : null,
        birthDate = data['birth_date'] != null ? data['birth_date'] : null,
        documentType =
            data['document_type'] != null ? data['document_type'] : null,
        licenseNumber =
            data['license_number'] != null ? data['license_number'] : null,
        expiryDate = data['expiry_date'] != null ? data['expiry_date'] : null,
        issuingDate =
            data['issuing_date'] != null ? data['issuing_date'] : null,
        issuingCountry =
            data['issuing_country'] != null ? data['issuing_country'] : null;
  final String firstName;
  final String middleName;
  final String lastName;
  final String gender;
  final String addressCity;
  final String addressState;
  final String addressZip;
  final String birthDate;
  final String documentType;
  final String licenseNumber;
  final String expiryDate;
  final String issuingDate;
  final String issuingCountry;
}
