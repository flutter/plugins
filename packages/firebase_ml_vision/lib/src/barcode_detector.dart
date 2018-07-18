// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

/// Barcode value type constants - enumeration of supported barcode content value types.
enum BarcodeValueType {
  /// Unknown Barcode value types.
  unknown,

  /// Barcode value type for contact info.
  contactInfo,

  /// Barcode value type for email addresses.
  email,

  /// Barcode value type for ISBNs.
  isbn,

  /// Barcode value type for phone numbers.
  phone,

  /// Barcode value type for product codes.
  product,

  /// Barcode value type for SMS details.
  sms,

  /// Barcode value type for plain text.
  text,

  /// Barcode value type for URLs/bookmarks.
  url,

  /// Barcode value type for Wi-Fi access point details.
  wifi,

  /// Barcode value type for geographic coordinates.
  geographicCoordinates,

  /// Barcode value type for calendar events.
  calendarEvent,

  /// Barcode value type for driver's license data.
  driverLicense,
}

/// The type of email for [BarcodeEmail].
enum BarcodeEmailType {
  /// Unknown email type.
  unknown,

  /// Barcode work email type.
  work,

  /// Barcode home email type.
  home,
}

/// The type of phone number for [BarcodePhone].
enum BarcodePhoneType {
  /// Unknown phone type.
  unknown,

  /// Barcode work phone type.
  work,

  /// Barcode home phone type.
  home,

  /// Barcode fax phone type.
  fax,

  /// Barcode mobile phone type.
  mobile,
}

/// Wifi encryption type constants.
enum BarcodeWiFiEncryptionType {
  /// Barcode unknown Wi-Fi encryption type.
  unknown,

  /// Barcode open Wi-Fi encryption type.
  open,

  /// Barcode WPA Wi-Fi encryption type.
  wpa,

  /// Barcode WEP Wi-Fi encryption type.
  wep,
}

/// Address type constants.
enum BarcodeAddressType {
  /// Barcode unknown address type.
  unknown,

  /// Barcode work address type.
  work,

  /// Barcode home address type.
  home,
}

/// Enumeration of supported barcode formats.
enum BarcodeFormat {
  /// Barcode format representing the union of all supported formats.
  all,

  /// Barcode format unknown to the current SDK, but understood by Google Play services.
  unknown,

  /// Barcode format Code 128.
  code128,

  /// Barcode format Code 39.
  code39,

  /// Barcode format Code 93.
  code93,

  /// Barcode format Codabar.
  codaBar,

  /// Barcode format Data Matrix.
  dataMatrix,

  /// Barcode format EAN-13.
  ean13,

  /// Barcode format EAN-8.
  ean8,

  /// Barcode format ITF (Interleaved Two-of-Five).
  itf,

  /// Barcode format QR Code.
  qrCode,

  /// Barcode format UPC-A.
  upca,

  /// Barcode format UPC-E.
  upce,

  /// Barcode format PDF-417.
  pdf417,

  /// Barcode format AZTEC.
  aztec,
}

/// Detector for performing barcode scanning on an input image.
///
/// A barcode detector is created via barcodeDetector() in [FirebaseVision]:
///
/// ```dart
/// BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
/// ```
class BarcodeDetector extends FirebaseVisionDetector {
  BarcodeDetector._(this.options) : assert(options != null);

  /// The options for configuring this detector.
  final BarcodeDetectorOptions options;

  /// Detects barcodes in the input image.
  ///
  /// The barcode scanning is performed asynchronously.
  @override
  Future<List<Barcode>> detectInImage(FirebaseVisionImage visionImage) async {
    final List<dynamic> reply = await FirebaseVision.channel.invokeMethod(
      'BarcodeDetector#detectInImage',
      <String, dynamic>{
        'path': visionImage.imageFile.path,
        'options': <String, dynamic>{
          'barcodeFormats': options._barcodeFormats
              .map((BarcodeFormat format) => _enumToString(format))
              .toList(),
        },
      },
    );

    final List<Barcode> barcodes = <Barcode>[];
    reply.forEach((dynamic barcode) {
      barcodes.add(new Barcode._(barcode));
    });

    return barcodes;
  }
}

/// Immutable options to configure [BarcodeDetector].
///
/// Sets which barcode formats the detector will detect. Defaults to
/// [BarcodeFormat.all].
///
/// Throws [AssertionError] if [barcodeFormats] is empty.
class BarcodeDetectorOptions {
  BarcodeDetectorOptions({List<BarcodeFormat> barcodeFormats})
      : _barcodeFormats = barcodeFormats != null
            ? Set<BarcodeFormat>.from(barcodeFormats)
            : Set<BarcodeFormat>.from(<BarcodeFormat>[BarcodeFormat.all]),
        assert(barcodeFormats?.isNotEmpty ?? true);

  final Set<BarcodeFormat> _barcodeFormats;

  /// List of barcode formats for the [BarcodeDetector] to detect.
  List<BarcodeFormat> get barcodeFormats =>
      List<BarcodeFormat>.unmodifiable(_barcodeFormats);
}

/// Represents a single recognized barcode and its value.
class Barcode {
  Barcode._(Map<dynamic, dynamic> _data)
      : boundingBox = _data['left'] != null
            ? Rectangle<int>(
                _data['left'],
                _data['top'],
                _data['width'],
                _data['height'],
              )
            : null,
        rawValue = _data['rawValue'],
        displayValue = _data['displayValue'],
        format = BarcodeFormat.values.firstWhere(
          (BarcodeFormat format) => _enumToString(format) == _data['format'],
          orElse: () => BarcodeFormat.unknown,
        ),
        _cornerPoints = _data['points'] == null
            ? null
            : _data['points']
                .map<Point<int>>((dynamic item) => Point<int>(
                      item[0],
                      item[1],
                    ))
                .toList(),
        valueType = BarcodeValueType.values.firstWhere(
          (BarcodeValueType format) =>
              _enumToString(format) == _data['valueType'],
          orElse: () => BarcodeValueType.unknown,
        ),
        email = _data['email'] == null ? null : BarcodeEmail._(_data['email']),
        phone = _data['phone'] == null ? null : BarcodePhone._(_data['phone']),
        sms = _data['sms'] == null ? null : BarcodeSMS._(_data['sms']),
        url = _data['url'] == null ? null : BarcodeURLBookmark._(_data['url']),
        wifi = _data['wifi'] == null ? null : BarcodeWiFi._(_data['wifi']),
        geoPoint = _data['geoPoint'] == null
            ? null
            : BarcodeGeoPoint._(_data['geoPoint']),
        contactInfo = _data['contactInfo'] == null
            ? null
            : BarcodeContactInfo._(_data['contactInfo']),
        calendarEvent = _data['calendarEvent'] == null
            ? null
            : BarcodeCalendarEvent._(_data['calendarEvent']),
        driverLicense = _data['driverLicense'] == null
            ? null
            : BarcodeDriverLicense._(_data['driverLicense']);

  final List<Point<int>> _cornerPoints;

  /// The bounding rectangle of the detected barcode.
  ///
  /// Could be null if the bounding rectangle can not be determined.
  final Rectangle<int> boundingBox;

  /// Barcode value as it was encoded in the barcode.
  ///
  /// Structured values are not parsed, for example: 'MEBKM:TITLE:Google;URL://www.google.com;;'.
  ///
  /// Null if nothing found.
  final String rawValue;

  /// Barcode value in a user-friendly format.
  ///
  /// May omit some of the information encoded in the barcode.
  /// For example, if rawValue is 'MEBKM:TITLE:Google;URL://www.google.com;;',
  /// the displayValue might be '//www.google.com'.
  /// If valueType = [BarcodeValueType.text], this field will be equal to rawValue.
  ///
  /// This value may be multiline, for example, when line breaks are encoded into the original TEXT barcode value.
  /// May include the supplement value.
  ///
  /// Null if nothing found.
  final String displayValue;

  /// The barcode format, for example [BarcodeFormat.ean13].
  final BarcodeFormat format;

  /// The four corner points in clockwise direction starting with top-left.
  ///
  /// Due to the possible perspective distortions, this is not necessarily a rectangle.
  List<Point<int>> get cornerPoints => List<Point<int>>.from(_cornerPoints);

  /// The format type of the barcode value.
  ///
  /// For example, [BarcodeValueType.text], [BarcodeValueType.product], [BarcodeValueType.url], etc.
  ///
  /// If the value structure cannot be parsed, [BarcodeValueType.text] will be returned.
  /// If the recognized structure type is not defined in your current version of SDK, [BarcodeValueType.unknown] will be returned.
  ///
  /// Note that the built-in parsers only recognize a few popular value structures.
  /// For your specific use case, you might want to directly consume rawValue
  /// and implement your own parsing logic.
  final BarcodeValueType valueType;

  /// Parsed email details. (set iff [valueType] is [BarcodeValueType.email]).
  final BarcodeEmail email;

  /// Parsed phone details. (set iff [valueType] is [BarcodeValueType.phone]).
  final BarcodePhone phone;

  /// Parsed SMS details. (set iff [valueType] is [BarcodeValueType.sms]).
  final BarcodeSMS sms;

  /// Parsed URL bookmark details. (set iff [valueType] is [BarcodeValueType.url]).
  final BarcodeURLBookmark url;

  /// Parsed WiFi AP details. (set iff [valueType] is [BarcodeValueType.wifi]).
  final BarcodeWiFi wifi;

  /// Parsed geo coordinates. (set iff [valueType] is [BarcodeValueType.geographicCoordinates]).
  final BarcodeGeoPoint geoPoint;

  /// Parsed contact details. (set iff [valueType] is [BarcodeValueType.contactInfo]).
  final BarcodeContactInfo contactInfo;

  /// Parsed calendar event details. (set iff [valueType] is [BarcodeValueType.calendarEvent]).
  final BarcodeCalendarEvent calendarEvent;

  /// Parsed driver's license details. (set iff [valueType] is [BarcodeValueType.driverLicense]).
  final BarcodeDriverLicense driverLicense;
}

/// An email message from a 'MAILTO:' or similar QRCode type.
class BarcodeEmail {
  BarcodeEmail._(Map<dynamic, dynamic> data)
      : type = BarcodeEmailType.values.firstWhere(
          (BarcodeEmailType format) => _enumToString(format) == data['type'],
          orElse: () => BarcodeEmailType.unknown,
        ),
        address = data['address'],
        body = data['body'],
        subject = data['subject'];

  /// The email's address.
  final String address;

  /// The email's body.
  final String body;

  /// The email's subject.
  final String subject;

  /// The type of the email.
  final BarcodeEmailType type;
}

/// Phone number info.
class BarcodePhone {
  BarcodePhone._(Map<dynamic, dynamic> data)
      : number = data['number'],
        type = BarcodePhoneType.values.firstWhere(
          (BarcodePhoneType format) => _enumToString(format) == data['type'],
          orElse: () => BarcodePhoneType.unknown,
        );

  /// Phone number.
  final String number;

  /// Type of the phone number.
  ///
  /// See also [BarcodePhoneType]
  final BarcodePhoneType type;
}

/// An sms message from an 'SMS:' or similar QRCode type.
class BarcodeSMS {
  BarcodeSMS._(Map<dynamic, dynamic> data)
      : message = data['message'],
        phoneNumber = data['phoneNumber'];

  /// An SMS message body.
  final String message;

  /// An SMS message phone number.
  final String phoneNumber;
}

/// A URL and title from a 'MEBKM:' or similar QRCode type.
class BarcodeURLBookmark {
  BarcodeURLBookmark._(Map<dynamic, dynamic> data)
      : title = data['title'],
        url = data['url'];

  /// A URL bookmark title.
  final String title;

  /// A URL bookmark url.
  final String url;
}

/// A wifi network parameters from a 'WIFI:' or similar QRCode type.
class BarcodeWiFi {
  BarcodeWiFi._(Map<dynamic, dynamic> data)
      : ssid = data['ssid'],
        password = data['password'],
        encryptionType = BarcodeWiFiEncryptionType.values.firstWhere(
          (BarcodeWiFiEncryptionType format) =>
              _enumToString(format) == data['encryptionType'],
          orElse: () => BarcodeWiFiEncryptionType.unknown,
        );

  /// A Wi-Fi access point SSID.
  final String ssid;

  /// A Wi-Fi access point password.
  final String password;

  /// The encryption type of the WIFI
  ///
  /// See all [BarcodeWiFiEncryptionType]
  final BarcodeWiFiEncryptionType encryptionType;
}

/// GPS coordinates from a 'GEO:' or similar QRCode type.
class BarcodeGeoPoint {
  BarcodeGeoPoint._(Map<dynamic, dynamic> data)
      : latitude = data['latitude'],
        longitude = data['longitude'];

  /// A location latitude.
  final double latitude;

  /// A location longitude.
  final double longitude;
}

/// A person's or organization's business card.
class BarcodeContactInfo {
  BarcodeContactInfo._(Map<dynamic, dynamic> data)
      : addresses = data['addresses'] == null
            ? null
            : List<BarcodeAddress>.unmodifiable(data['addresses']
                .map<BarcodeAddress>((dynamic item) => BarcodeAddress._(item))),
        emails = data['emails'] == null
            ? null
            : List<BarcodeEmail>.unmodifiable(data['emails']
                .map<BarcodeEmail>((dynamic item) => BarcodeEmail._(item))),
        name = data['name'] == null ? null : BarcodePersonName._(data['name']),
        phones = data['phones'] == null
            ? null
            : List<BarcodePhone>.unmodifiable(data['phones']
                .map<BarcodePhone>((dynamic item) => BarcodePhone._(item))),
        urls = data['urls'] == null
            ? null
            : List<String>.unmodifiable(
                data['urls'].map<String>((dynamic item) {
                final String s = item;
                return s;
              })),
        jobTitle = data['jobTitle'],
        organization = data['organization'];

  /// Contact person's addresses.
  ///
  /// Could be an empty list if nothing found.
  final List<BarcodeAddress> addresses;

  /// Contact person's emails.
  ///
  /// Could be an empty list if nothing found.
  final List<BarcodeEmail> emails;

  /// Contact person's name.
  final BarcodePersonName name;

  /// Contact person's phones.
  ///
  /// Could be an empty list if nothing found.
  final List<BarcodePhone> phones;

  /// Contact urls associated with this person.
  final List<String> urls;

  /// Contact person's title.
  final String jobTitle;

  /// Contact person's organization.
  final String organization;
}

/// An address.
class BarcodeAddress {
  BarcodeAddress._(Map<dynamic, dynamic> data)
      : addressLines = List<String>.unmodifiable(
            data['addressLines'].map<String>((dynamic item) {
          final String s = item;
          return s;
        })),
        type = BarcodeAddressType.values.firstWhere(
          (BarcodeAddressType format) => _enumToString(format) == data['type'],
          orElse: () => BarcodeAddressType.unknown,
        );

  /// Formatted address, multiple lines when appropriate.
  ///
  /// This field always contains at least one line.
  final List<String> addressLines;

  /// Type of the address.
  ///
  /// See also [BarcodeAddressType]
  final BarcodeAddressType type;
}

/// A person's name, both formatted version and individual name components.
class BarcodePersonName {
  BarcodePersonName._(Map<dynamic, dynamic> data)
      : formattedName = data['formattedName'],
        first = data['first'],
        last = data['last'],
        middle = data['middle'],
        prefix = data['prefix'],
        pronunciation = data['pronunciation'],
        suffix = data['suffix'];

  /// The properly formatted name.
  final String formattedName;

  /// Tirst name
  final String first;

  /// Last name
  final String last;

  /// Middle name
  final String middle;

  /// Prefix of the name
  final String prefix;

  /// Designates a text string to be set as the kana name in the phonebook. Used for Japanese contacts.
  final String pronunciation;

  /// Suffix of the person's name
  final String suffix;
}

/// DateTime data type used in calendar events.
class BarcodeCalendarEvent {
  BarcodeCalendarEvent._(Map<dynamic, dynamic> data)
      : eventDescription = data['eventDescription'],
        location = data['location'],
        organizer = data['organizer'],
        status = data['status'],
        summary = data['summary'],
        start = DateTime.parse(data['start']),
        end = DateTime.parse(data['end']);

  /// The description of the calendar event.
  final String eventDescription;

  /// The location of the calendar event.
  final String location;

  /// The organizer of the calendar event.
  final String organizer;

  /// The status of the calendar event.
  final String status;

  /// The summary of the calendar event.
  final String summary;

  /// The start date time of the calendar event.
  final DateTime start;

  /// The end date time of the calendar event.
  final DateTime end;
}

/// A driver license or ID card.
class BarcodeDriverLicense {
  BarcodeDriverLicense._(Map<dynamic, dynamic> data)
      : firstName = data['firstName'],
        middleName = data['middleName'],
        lastName = data['lastName'],
        gender = data['gender'],
        addressCity = data['addressCity'],
        addressState = data['addressState'],
        addressStreet = data['addressStreet'],
        addressZip = data['addressZip'],
        birthDate = data['birthDate'],
        documentType = data['documentType'],
        licenseNumber = data['licenseNumber'],
        expiryDate = data['expiryDate'],
        issuingDate = data['issuingDate'],
        issuingCountry = data['issuingCountry'];

  /// Holder's first name.
  final String firstName;

  /// Holder's middle name.
  final String middleName;

  /// Holder's last name.
  final String lastName;

  /// Holder's gender. 1 - male, 2 - female.
  final String gender;

  /// City of holder's address.
  final String addressCity;

  /// State of holder's address.
  final String addressState;

  /// Holder's street address.
  final String addressStreet;

  /// Zip code of holder's address.
  final String addressZip;

  /// Birth date of the holder.
  final String birthDate;

  /// "DL" for driver licenses, "ID" for ID cards.
  final String documentType;

  /// Driver license ID number.
  final String licenseNumber;

  /// Expiry date of the license.
  final String expiryDate;

  /// Issue date of the license.
  ///
  /// The date format depends on the issuing country. MMDDYYYY for the US, YYYYMMDD for Canada.
  final String issuingDate;

  /// Country in which DL/ID was issued. US = "USA", Canada = "CAN".
  final String issuingCountry;
}
