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

    final List<VisionBarcode> barcodes = <VisionBarcode>[];
    reply.forEach((dynamic barcode) {
      barcodes.add(new VisionBarcode._(barcode));
    });

    return barcodes;
  }
}

class VisionBarcode {
  VisionBarcode._(Map<dynamic, dynamic> _data)
      : boundingBox = Rectangle<int>(
          _data['left'],
          _data['top'],
          _data['width'],
          _data['height'],
        ),
        rawValue = _data['raw_value'],
        displayValue = _data['display_value'],
        format = VisionBarcodeFormat._(_data['format']),
        cornerPoints = _data['points'] == null
            ? null
            : _data['points']
                .map<Point<int>>((dynamic item) => Point<int>(
                      item[0],
                      item[1],
                    ))
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

  final Rectangle<int> boundingBox;
  final String rawValue;
  final String displayValue;
  final VisionBarcodeFormat format;
  final List<Point<int>> cornerPoints;
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
        address = data['address'],
        body = data['body'],
        subject = data['subject'];

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
      : number = data['number'],
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
      : message = data['message'],
        phoneNumber = data['phone_number'];
  final String message;
  final String phoneNumber;
}

// ios
//   https://firebase.google.com/docs/reference/ios/firebasemlvision/api/reference/Classes/FIRVisionBarcodeURLBookmark
// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/barcode/FirebaseVisionBarcode.UrlBookmark
class VisionBarcodeURLBookmark {
  VisionBarcodeURLBookmark._(Map<dynamic, dynamic> data)
      : title = data['title'],
        url = data['url'];
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
        jobTitle = data['job_title'],
        organization = data['organization'];
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
      : formattedName = data['formatted_name'],
        first = data['first'],
        last = data['last'],
        middle = data['middle'],
        prefix = data['prefix'],
        pronounciation = data['pronounciation'],
        suffix = data['suffix'];
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
      : eventDescription = data['event_description'],
        location = data['location'],
        organizer = data['organizer'],
        status = data['status'],
        summary = data['summary'],
        start = data['start'],
        end = data['end'];
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
      : firstName = data['first_name'],
        middleName = data['middle_name'],
        lastName = data['last_name'],
        gender = data['gender'],
        addressCity = data['address_city'],
        addressState = data['address_state'],
        addressZip = data['address_zip'],
        birthDate = data['birth_date'],
        documentType = data['document_type'],
        licenseNumber = data['license_number'],
        expiryDate = data['expiry_date'],
        issuingDate = data['issuing_date'],
        issuingCountry = data['issuing_country'];
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
