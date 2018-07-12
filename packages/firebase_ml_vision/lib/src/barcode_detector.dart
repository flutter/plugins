// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

/// Detector for performing barcode scanning on an input image.
///
/// A barcode detector is created via barcodeDetector() in [FirebaseVision]:
///
/// ```dart
/// BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
/// ```
class BarcodeDetector extends FirebaseVisionDetector {
  BarcodeDetector._();

  /// Closes the barcode detector and releases its model resources.
  @override
  Future<void> close() async {
    return FirebaseVision.channel.invokeMethod('BarcodeDetector#close');
  }

  /// Detects barcode in the input image.
  ///
  /// The barcode scanning is performed asynchronously.
  @override
  Future<List<Barcode>> detectInImage(FirebaseVisionImage visionImage) async {
    final List<dynamic> reply = await FirebaseVision.channel.invokeMethod(
      'BarcodeDetector#detectInImage',
      visionImage.imageFile.path,
    );

    final List<Barcode> barcodes = <Barcode>[];
    reply.forEach((dynamic barcode) {
      barcodes.add(new Barcode._(barcode));
    });

    return barcodes;
  }
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
        rawValue = _data['raw_value'],
        displayValue = _data['display_value'],
        format = BarcodeFormat._(_data['format']),
        _cornerPoints = _data['points'] == null
            ? null
            : _data['points']
                .map<Point<int>>((dynamic item) => Point<int>(
                      item[0],
                      item[1],
                    ))
                .toList(),
        valueType = BarcodeValueType.values.elementAt(_data['value_type']),
        email = _data['email'] == null ? null : BarcodeEmail._(_data['email']),
        phone = _data['phone'] == null ? null : BarcodePhone._(_data['phone']),
        sms = _data['sms'] == null ? null : BarcodeSMS._(_data['sms']),
        url = _data['url'] == null ? null : BarcodeURLBookmark._(_data['url']),
        wifi = _data['wifi'] == null ? null : BarcodeWiFi._(_data['wifi']),
        geoPoint = _data['geo_point'] == null
            ? null
            : BarcodeGeoPoint._(_data['geo_point']),
        contactInfo = _data['contact_info'] == null
            ? null
            : BarcodeContactInfo._(_data['contact_info']),
        calendarEvent = _data['calendar_event'] == null
            ? null
            : BarcodeCalendarEvent._(_data['calendar_event']),
        driverLicense = _data['driver_license'] == null
            ? null
            : BarcodeDriverLicense._(_data['driver_license']);

  final List<Point<int>> _cornerPoints;

  /// The bounding rectangle of the detected barcode.
  ///
  /// Could be null if the bounding rectangle can not be determined.
  final Rectangle<int> boundingBox;

  /// Barcode value as it was encoded in the barcode.
  ///
  /// Structured values are not parsed, for example: 'MEBKM:TITLE:Google;URL://www.google.com;;'.
  ///
  /// Could be null if nothing found.
  final String rawValue;

  /// Barcode value in a user-friendly format.
  ///
  /// May omit some of the information encoded in the barcode.
  /// For example, if rawValue is 'MEBKM:TITLE:Google;URL://www.google.com;;',
  /// the display_value might be '//www.google.com'.
  /// If valueFormat==TEXT, this field will be equal to rawValue.
  ///
  /// This value may be multiline, for example, when line breaks are encoded into the original TEXT barcode value.
  /// May include the supplement value.
  ///
  /// Could be null if nothing found.
  final String displayValue;

  /// The barcode format, for example [BarcodeFormat.EAN13].
  final BarcodeFormat format;

  /// The four corner points in clockwise direction starting with top-left.
  ///
  /// Due to the possible perspective distortions, this is not necessarily a rectangle.
  List<Point<int>> get cornerPoints => List<Point<int>>.from(_cornerPoints);

  /// The format type of the barcode value.
  ///
  /// For example, [BarcodeValueType.Text], [BarcodeValueType.Product], [BarcodeValueType.URL], etc.
  ///
  /// If the value structure cannot be parsed, TYPE_TEXT will be returned.
  /// If the recognized structure type is not defined in your current version of SDK, TYPE_UNKNOWN will be returned.
  ///
  /// Note that the built-in parsers only recognize a few popular value structures.
  /// For your specific use case, you might want to directly consume rawValue
  /// and implement your own parsing logic.
  final BarcodeValueType valueType;

  /// Parsed email details. (set iff [valueType] is [BarcodeValueType.Email])
  final BarcodeEmail email;

  /// Parsed phone details. (set iff [valueType] is [BarcodeValueType.Phone])
  final BarcodePhone phone;

  /// Parsed SMS details. (set iff [valueType] is [BarcodeValueType.SMS])
  final BarcodeSMS sms;

  /// Parsed URL bookmark details. (set iff [valueType] is [BarcodeValueType.URL])
  final BarcodeURLBookmark url;

  /// Parsed WiFi AP details. (set iff [valueType] is [BarcodeValueType.WiFi])
  final BarcodeWiFi wifi;

  /// Parsed geo coordinates. (set iff [valueType] is [BarcodeValueType.GeographicCoordinates])
  final BarcodeGeoPoint geoPoint;

  /// Parsed contact details. (set iff [valueType] is [BarcodeValueType.ContactInfo])
  final BarcodeContactInfo contactInfo;

  /// Parsed calendar event details. (set iff [valueType] is [BarcodeValueType.CalendarEvent])
  final BarcodeCalendarEvent calendarEvent;

  /// Parsed driver's license details. (set iff [valueType] is [BarcodeValueType.DriversLicense])
  final BarcodeDriverLicense driverLicense;
}

/// Barcode format constants - enumeration of supported barcode formats.
class BarcodeFormat {
  const BarcodeFormat._(this.value);

  /// Raw BarcodeFormat value.
  final int value;

  /// Barcode format constant representing the union of all supported formats.
  static const BarcodeFormat All = const BarcodeFormat._(0xFFFF);

  /// Barcode format unknown to the current SDK, but understood by Google Play services.
  static const BarcodeFormat UnKnown = const BarcodeFormat._(0);

  /// Barcode format constant for Code 128.
  static const BarcodeFormat Code128 = const BarcodeFormat._(0x0001);

  /// Barcode format constant for Code 39.
  static const BarcodeFormat Code39 = const BarcodeFormat._(0x0002);

  /// Barcode format constant for Code 93.
  static const BarcodeFormat Code93 = const BarcodeFormat._(0x0004);

  /// Barcode format constant for Codabar.
  static const BarcodeFormat CodaBar = const BarcodeFormat._(0x0008);

  /// Barcode format constant for Data Matrix.
  static const BarcodeFormat DataMatrix = const BarcodeFormat._(0x0010);

  /// Barcode format constant for EAN-13.
  static const BarcodeFormat EAN13 = const BarcodeFormat._(0x0020);

  /// Barcode format constant for EAN-8.
  static const BarcodeFormat EAN8 = const BarcodeFormat._(0x0040);

  /// Barcode format constant for ITF (Interleaved Two-of-Five).
  static const BarcodeFormat ITF = const BarcodeFormat._(0x0080);

  /// Barcode format constant for QR Code.
  static const BarcodeFormat QRCode = const BarcodeFormat._(0x0100);

  /// Barcode format constant for UPC-A.
  static const BarcodeFormat UPCA = const BarcodeFormat._(0x0200);

  /// Barcode format constant for UPC-E.
  static const BarcodeFormat UPCE = const BarcodeFormat._(0x0400);

  /// Barcode format constant for PDF-417.
  static const BarcodeFormat PDF417 = const BarcodeFormat._(0x0800);

  /// Barcode format constant for AZTEC.
  static const BarcodeFormat Aztec = const BarcodeFormat._(0x1000);
}

/// Barcode value type constants - enumeration of supported barcode content value types
enum BarcodeValueType {
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

/// An email message from a 'MAILTO:' or similar QRCode type.
class BarcodeEmail {
  BarcodeEmail._(Map<dynamic, dynamic> data)
      : type = BarcodeEmailType.values.elementAt(data['type']),
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

/// The type of email for [BarcodeEmail]
enum BarcodeEmailType {
  /// Unknown email type.
  Unknown,

  /// Barcode work email type.
  Work,

  /// Barcode home email type.
  Home,
}

/// Phone number info.
class BarcodePhone {
  BarcodePhone._(Map<dynamic, dynamic> data)
      : number = data['number'],
        type = BarcodePhoneType.values.elementAt(data['type']);

  /// Phone number
  final String number;

  /// Type of the phone number
  ///
  /// See also [BarcodePhoneType]
  final BarcodePhoneType type;
}

enum BarcodePhoneType {
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

/// An sms message from an 'SMS:' or similar QRCode type.
class BarcodeSMS {
  BarcodeSMS._(Map<dynamic, dynamic> data)
      : message = data['message'],
        phoneNumber = data['phone_number'];

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
        encryptionType =
            BarcodeWiFiEncryptionType.values.elementAt(data['encryption_type']);

  /// A Wi-Fi access point SSID.
  final String ssid;

  /// A Wi-Fi access point password.
  final String password;

  /// The encryption type of the WIFI
  ///
  /// See all [BarcodeWiFiEncryptionType]
  final BarcodeWiFiEncryptionType encryptionType;
}

/// Wifi encryption type constants.
enum BarcodeWiFiEncryptionType {
  /// Barcode unknown Wi-Fi encryption type.
  Unknown,

  /// Barcode open Wi-Fi encryption type.
  Open,

  /// Barcode WPA Wi-Fi encryption type.
  WPA,

  /// Barcode WEP Wi-Fi encryption type.
  WEP,
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
            : data['addresses']
                .map<BarcodeAddress>((dynamic item) => BarcodeAddress._(item))
                .toList(),
        emails = data['emails'] == null
            ? null
            : data['emails']
                .map<BarcodeEmail>((dynamic item) => BarcodeEmail._(item))
                .toList(),
        name = data['name'] == null ? null : BarcodePersonName._(data['name']),
        phones = data['phones'] == null
            ? null
            : data['phones']
                .map<BarcodePhone>((dynamic item) => BarcodePhone._(item))
                .toList(),
        urls = data['urls'] == null
            ? null
            : data['urls'].map<String>((dynamic item) {
                final String s = item;
                return s;
              }).toList(),
        jobTitle = data['job_title'],
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
  final List<String> urls;

  /// Contact person's title.
  final String jobTitle;

  /// Contact person's organization.
  final String organization;
}

/// An address.
class BarcodeAddress {
  BarcodeAddress._(Map<dynamic, dynamic> data)
      : addressLines = data['address_lines'].map<String>((dynamic item) {
          final String s = item;
          return s;
        }).toList(),
        type = BarcodeAddressType.values.elementAt(data['type']);

  /// Formatted address, multiple lines when appropriate.
  ///
  /// This field always contains at least one line.
  final List<String> addressLines;

  /// Type of the address.
  ///
  /// See also [BarcodeAddressType]
  final BarcodeAddressType type;
}

/// Address type constants.
enum BarcodeAddressType {
  /// Barcode unknown address type.
  Unknown,

  /// Barcode work address type.
  Work,

  /// Barcode home address type.
  Home,
}

/// A person's name, both formatted version and individual name components.
class BarcodePersonName {
  BarcodePersonName._(Map<dynamic, dynamic> data)
      : formattedName = data['formatted_name'],
        first = data['first'],
        last = data['last'],
        middle = data['middle'],
        prefix = data['prefix'],
        pronounciation = data['pronounciation'],
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
  final String pronounciation;

  /// Suffix of the person's name
  final String suffix;
}

/// DateTime data type used in calendar events
class BarcodeCalendarEvent {
  BarcodeCalendarEvent._(Map<dynamic, dynamic> data)
      : eventDescription = data['event_description'],
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
      : firstName = data['first_name'],
        middleName = data['middle_name'],
        lastName = data['last_name'],
        gender = data['gender'],
        addressCity = data['address_city'],
        addressState = data['address_state'],
        addressStreet = data['address_street'],
        addressZip = data['address_zip'],
        birthDate = data['birth_date'],
        documentType = data['document_type'],
        licenseNumber = data['license_number'],
        expiryDate = data['expiry_date'],
        issuingDate = data['issuing_date'],
        issuingCountry = data['issuing_country'];

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
