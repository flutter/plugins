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
  Future<List<VisionBarcode>> detectInImage(
      FirebaseVisionImage visionImage) async {
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

/// Represents a single recognized barcode and its value.
class VisionBarcode {
  VisionBarcode._(Map<dynamic, dynamic> _data)
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

  /// Gets the bounding rectangle of the detected barcode.
  ///
  /// Returns null if the bounding rectangle can not be determined.
  final Rectangle<int> boundingBox;

  /// Returns barcode value as it was encoded in the barcode.
  /// Structured values are not parsed, for example: 'MEBKM:TITLE:Google;URL://www.google.com;;'.
  ///
  /// Returns null if nothing found.
  final String rawValue;

  /// Returns barcode value in a user-friendly format.
  /// May omit some of the information encoded in the barcode.
  /// For example, if getRawValue() returns 'MEBKM:TITLE:Google;URL://www.google.com;;',
  /// the display_value might be '//www.google.com'.
  /// If valueFormat==TEXT, this field will be equal to getRawValue().
  ///
  /// This value may be multiline, for example, when line breaks are encoded into the original TEXT barcode value.
  /// May include the supplement value.
  ///
  /// Returns null if nothing found.
  final String displayValue;

  /// Returns barcode format, for example [VisionBarcodeFormat.EAN13].
  final VisionBarcodeFormat format;

  /// Returns four corner points in clockwise direction starting with top-left.
  ///
  /// Due to the possible perspective distortions, this is not necessarily a rectangle.
  final List<Point<int>> cornerPoints;

  /// Returns format type of the barcode value.
  ///
  /// For example, [VisionBarcodeValueType.Text], [VisionBarcodeValueType.Product], [VisionBarcodeValueType.URL], etc.
  ///
  /// If the value structure cannot be parsed, TYPE_TEXT will be returned.
  /// If the recognized structure type is not defined in your current version of SDK, TYPE_UNKNOWN will be returned.
  ///
  /// Note that the built-in parsers only recognize a few popular value structures.
  /// For your specific use case, you might want to directly consume getRawValue()
  /// and implement your own parsing logic.
  final VisionBarcodeValueType valueType;

  /// Gets parsed email details (set iff [valueType] is [VisionBarcodeValueType.Email].
  final VisionBarcodeEmail email;

  /// Gets parsed phone details (set iff [valueType] is [VisionBarcodeValueType.Phone]).
  final VisionBarcodePhone phone;

  /// Gets parsed SMS details (set iff [valueType] is [VisionBarcodeValueType.SMS]).
  final VisionBarcodeSMS sms;

  /// Gets parsed URL bookmark details (set iff [valueType] is [VisionBarcodeValueType.URL]).
  final VisionBarcodeURLBookmark url;

  /// Gets parsed WiFi AP details (set iff [valueType] is [VisionBarcodeValueType.WiFi]).
  final VisionBarcodeWiFi wifi;

  /// Gets parsed geo coordinates (set iff [valueType] is [VisionBarcodeValueType.GeographicCoordinates]).
  final VisionBarcodeGeoPoint geoPoint;

  /// Gets parsed contact details (set iff [valueType] is [VisionBarcodeValueType.ContactInfo]).
  final VisionBarcodeContactInfo contactInfo;

  /// Gets parsed calendar event details (set iff [valueType] is [VisionBarcodeValueType.CalendarEvent]).
  final VisionBarcodeCalendarEvent calendarEvent;

  /// Gets parsed driver's license details (set iff [valueType] is [VisionBarcodeValueType.DriversLicense]).
  final VisionBarcodeDriverLicense driverLicense;
}

/// Barcode format constants - enumeration of supported barcode formats.
class VisionBarcodeFormat {
  final int value;
  const VisionBarcodeFormat._(this.value);

  /// Barcode format constant representing the union of all supported formats.
  static const VisionBarcodeFormat All = const VisionBarcodeFormat._(0xFFFF);

  /// Barcode format unknown to the current SDK, but understood by Google Play services.
  static const VisionBarcodeFormat UnKnown = const VisionBarcodeFormat._(0);

  /// Barcode format constant for Code 128.
  static const VisionBarcodeFormat Code128 =
      const VisionBarcodeFormat._(0x0001);

  /// Barcode format constant for Code 39.
  static const VisionBarcodeFormat Code39 = const VisionBarcodeFormat._(0x0002);

  /// Barcode format constant for Code 93.
  static const VisionBarcodeFormat Code93 = const VisionBarcodeFormat._(0x0004);

  /// Barcode format constant for Codabar.
  static const VisionBarcodeFormat CodaBar =
      const VisionBarcodeFormat._(0x0008);

  /// Barcode format constant for Data Matrix.
  static const VisionBarcodeFormat DataMatrix =
      const VisionBarcodeFormat._(0x0010);

  /// Barcode format constant for EAN-13.
  static const VisionBarcodeFormat EAN13 = const VisionBarcodeFormat._(0x0020);

  /// Barcode format constant for EAN-8.
  static const VisionBarcodeFormat EAN8 = const VisionBarcodeFormat._(0x0040);

  /// Barcode format constant for ITF (Interleaved Two-of-Five).
  static const VisionBarcodeFormat ITF = const VisionBarcodeFormat._(0x0080);

  /// Barcode format constant for QR Code.
  static const VisionBarcodeFormat QRCode = const VisionBarcodeFormat._(0x0100);

  /// Barcode format constant for UPC-A.
  static const VisionBarcodeFormat UPCA = const VisionBarcodeFormat._(0x0200);

  /// Barcode format constant for UPC-E.
  static const VisionBarcodeFormat UPCE = const VisionBarcodeFormat._(0x0400);

  /// Barcode format constant for PDF-417.
  static const VisionBarcodeFormat PDF417 = const VisionBarcodeFormat._(0x0800);

  /// Barcode format constant for AZTEC.
  static const VisionBarcodeFormat Aztec = const VisionBarcodeFormat._(0x1000);
}

/// Barcode value type constants - enumeration of supported barcode content value types
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

/// An email message from a 'MAILTO:' or similar QRCode type.
class VisionBarcodeEmail {
  VisionBarcodeEmail._(Map<dynamic, dynamic> data)
      : type = VisionBarcodeEmailType.values.elementAt(data['type']),
        address = data['address'],
        body = data['body'],
        subject = data['subject'];

  /// Gets email's address.
  final String address;

  /// Gets email's body.
  final String body;

  /// Gets email's subject.
  final String subject;

  /// Gets type of the email.
  final VisionBarcodeEmailType type;
}

/// The type of email for [VisionBarcodeEmail]
enum VisionBarcodeEmailType {
  /// Unknown email type.
  Unknown,

  /// Barcode work email type.
  Work,

  /// Barcode home email type.
  Home,
}

/// Phone number info.
class VisionBarcodePhone {
  VisionBarcodePhone._(Map<dynamic, dynamic> data)
      : number = data['number'],
        type = VisionBarcodePhoneType.values.elementAt(data['type']);

  /// Gets phone number
  final String number;

  /// Gets type of the phone number
  ///
  /// See also [VisionBarcodePhoneType]
  final VisionBarcodePhoneType type;
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

/// An sms message from an 'SMS:' or similar QRCode type.
class VisionBarcodeSMS {
  VisionBarcodeSMS._(Map<dynamic, dynamic> data)
      : message = data['message'],
        phoneNumber = data['phone_number'];

  final String message;
  final String phoneNumber;
}

/// A URL and title from a 'MEBKM:' or similar QRCode type.
class VisionBarcodeURLBookmark {
  VisionBarcodeURLBookmark._(Map<dynamic, dynamic> data)
      : title = data['title'],
        url = data['url'];

  final String title;
  final String url;
}

/// A wifi network parameters from a 'WIFI:' or similar QRCode type.
class VisionBarcodeWiFi {
  VisionBarcodeWiFi._(Map<dynamic, dynamic> data)
      : ssid = data['ssid'],
        password = data['password'],
        encryptionType = VisionBarcodeWiFiEncryptionType.values
            .elementAt(data['encryption_type']);

  final String ssid;
  final String password;

  /// Gets the encryption type of the WIFI
  ///
  /// See all [VisionBarcodeWiFiEncryptionType]
  final VisionBarcodeWiFiEncryptionType encryptionType;
}

/// Wifi encryption type constants.
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

/// GPS coordinates from a 'GEO:' or similar QRCode type.
class VisionBarcodeGeoPoint {
  VisionBarcodeGeoPoint._(Map<dynamic, dynamic> data)
      : latitude = data['latitude'],
        longitude = data['longitude'];
  final double latitude;
  final double longitude;
}

/// A person's or organization's business card.
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
            : data['urls'].map<String>((dynamic item) {
                final String s = item;
                return s;
              }).toList(),
        jobTitle = data['job_title'],
        organization = data['organization'];

  /// Gets contact person's addresses.
  ///
  /// Returns an empty list if nothing found.
  final List<VisionBarcodeAddress> addresses;

  /// Gets contact person's emails.
  ///
  /// Returns an empty list if nothing found.
  final List<VisionBarcodeEmail> emails;

  /// Gets contact person's name.
  final VisionBarcodePersonName name;

  /// Gets contact person's phones.
  ///
  /// Returns an empty list if nothing found.
  final List<VisionBarcodePhone> phones;
  final List<String> urls;

  /// Gets contact person's title.
  final String jobTitle;

  /// Gets contact person's organization.
  final String organization;
}

/// An address.
class VisionBarcodeAddress {
  VisionBarcodeAddress._(Map<dynamic, dynamic> data)
      : addressLines = data['address_lines'].map<String>((dynamic item) {
          final String s = item;
          return s;
        }).toList(),
        type = VisionBarcodeAddressType.values.elementAt(data['type']);

  /// Gets formatted address, multiple lines when appropriate.
  /// This field always contains at least one line.
  final List<String> addressLines;

  /// Gets type of the address.
  ///
  /// See also [VisionBarcodeAddressType]
  final VisionBarcodeAddressType type;
}

/// Address type constants.
enum VisionBarcodeAddressType {
  /// Barcode unknown address type.
  Unknown,

  /// Barcode work address type.
  Work,

  /// Barcode home address type.
  Home,
}

/// A person's name, both formatted version and individual name components.
class VisionBarcodePersonName {
  VisionBarcodePersonName._(Map<dynamic, dynamic> data)
      : formattedName = data['formatted_name'],
        first = data['first'],
        last = data['last'],
        middle = data['middle'],
        prefix = data['prefix'],
        pronounciation = data['pronounciation'],
        suffix = data['suffix'];

  /// Gets the properly formatted name.
  final String formattedName;

  /// Gets first name
  final String first;

  /// Gets last name
  final String last;

  /// Gets middle name
  final String middle;

  /// Gets prefix of the name
  final String prefix;

  /// Designates a text string to be set as the kana name in the phonebook. Used for Japanese contacts.
  final String pronounciation;

  /// Gets suffix of the person's name
  final String suffix;
}

/// DateTime data type used in calendar events
class VisionBarcodeCalendarEvent {
  VisionBarcodeCalendarEvent._(Map<dynamic, dynamic> data)
      : eventDescription = data['event_description'],
        location = data['location'],
        organizer = data['organizer'],
        status = data['status'],
        summary = data['summary'],
        start = DateTime.parse(data['start']),
        end = DateTime.parse(data['end']);

  /// Gets the description of the calendar event.
  final String eventDescription;

  /// Gets the location of the calendar event.
  final String location;

  /// Gets the organizer of the calendar event.
  final String organizer;

  /// Gets the status of the calendar event.
  final String status;

  /// Gets the summary of the calendar event.
  final String summary;

  /// Gets the start date time of the calendar event.
  final DateTime start;

  /// Gets the end date time of the calendar event.
  final DateTime end;
}

/// A driver license or ID card.
class VisionBarcodeDriverLicense {
  VisionBarcodeDriverLicense._(Map<dynamic, dynamic> data)
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

  /// Gets holder's first name.
  final String firstName;

  /// Gets holder's middle name.
  final String middleName;

  /// Gets holder's last name.
  final String lastName;

  /// Gets holder's gender. 1 - male, 2 - female.
  final String gender;

  /// Gets city of holder's address.
  final String addressCity;

  /// Gets state of holder's address.
  final String addressState;

  /// Gets holder's street address.
  final String addressStreet;

  /// Gets zip code of holder's address.
  final String addressZip;

  /// Gets birth date of the holder.
  final String birthDate;

  /// Gets "DL" for driver licenses, "ID" for ID cards.
  final String documentType;

  /// Gets driver license ID number.
  final String licenseNumber;

  /// Gets expiry date of the license.
  final String expiryDate;

  /// Gets issue date of the license.
  ///
  /// The date format depends on the issuing country. MMDDYYYY for the US, YYYYMMDD for Canada.
  final String issuingDate;

  /// Gets country in which DL/ID was issued. US = "USA", Canada = "CAN".
  final String issuingCountry;
}
