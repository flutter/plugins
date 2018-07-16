#import "FirebaseMlVisionPlugin.h"

@implementation BarcodeDetector
static FIRVisionBarcodeDetector *barcodeDetector;

+ (void)handleDetection:(FIRVisionImage *)image
                options:(NSDictionary *)options
                 result:(FlutterResult)result {
  if (barcodeDetector == nil) {
    FIRVision *vision = [FIRVision vision];
    barcodeDetector = [vision barcodeDetector];
  }
  NSMutableArray *ret = [NSMutableArray array];
  [barcodeDetector detectInImage:image
                      completion:^(NSArray<FIRVisionBarcode *> *barcodes, NSError *error) {
                        if (error) {
                          [FLTFirebaseMlVisionPlugin handleError:error result:result];
                          return;
                        } else if (!barcodes) {
                          result(@[]);
                          return;
                        }

                        // Scanned barcode
                        for (FIRVisionBarcode *barcode in barcodes) {
                          [ret addObject:visionBarcodeToDictionary(barcode)];
                        }
                        result(ret);
                      }];
}

NSDictionary *visionBarcodeToDictionary(FIRVisionBarcode *barcode) {
  __block NSMutableArray<NSArray *> *points = [NSMutableArray array];

  for (NSValue *point in points) {
    [points addObject:@[ @(((__bridge CGPoint *)point)->x), @(((__bridge CGPoint *)point)->y) ]];
  }
  return @{
    @"raw_value" : barcode.rawValue,
    @"display_value" : barcode.displayValue ? barcode.displayValue : [NSNull null],
    @"left" : @((int)barcode.frame.origin.x),
    @"top" : @((int)barcode.frame.origin.y),
    @"width" : @((int)barcode.frame.size.width),
    @"height" : @((int)barcode.frame.size.height),
    @"format" : @(barcode.format),
    @"value_type" : @(barcode.valueType),
    @"points" : points,
    @"wifi" : barcode.wifi ? visionBarcodeWiFiToDictionary(barcode.wifi) : [NSNull null],
    @"email" : barcode.email ? visionBarcodeEmailToDictionary(barcode.email) : [NSNull null],
    @"phone" : barcode.phone ? visionBarcodePhoneToDictionary(barcode.phone) : [NSNull null],
    @"sms" : barcode.sms ? visionBarcodeSMSToDictionary(barcode.sms) : [NSNull null],
    @"url" : barcode.URL ? visionBarcodeURLToDictionary(barcode.URL) : [NSNull null],
    @"geo_point" : barcode.geoPoint ? visionBarcodeGeoPointToDictionary(barcode.geoPoint)
                                    : [NSNull null],
    @"contact_info" : barcode.contactInfo ? barcodeContactInfoToDictionary(barcode.contactInfo)
                                          : [NSNull null],
    @"calendar_event" : barcode.calendarEvent ? calendarEventToDictionary(barcode.calendarEvent)
                                              : [NSNull null],
    @"driver_license" : barcode.driverLicense ? driverLicenseToDictionary(barcode.driverLicense)
                                              : [NSNull null],
  };
}

NSDictionary *visionBarcodeWiFiToDictionary(FIRVisionBarcodeWiFi *wifi) {
  return @{
    @"ssid" : wifi.ssid,
    @"password" : wifi.password,
    @"encryption_type" : @(wifi.type),
  };
}

NSDictionary *visionBarcodeEmailToDictionary(FIRVisionBarcodeEmail *email) {
  return @{
    @"address" : email.address,
    @"body" : email.body,
    @"subject" : email.subject,
    @"type" : @(email.type),
  };
}

NSDictionary *visionBarcodePhoneToDictionary(FIRVisionBarcodePhone *phone) {
  return @{
    @"number" : phone.number,
    @"type" : @(phone.type),
  };
}

NSDictionary *visionBarcodeSMSToDictionary(FIRVisionBarcodeSMS *sms) {
  return @{
    @"phone_number" : sms.phoneNumber,
    @"message" : sms.message,
  };
}

NSDictionary *visionBarcodeURLToDictionary(FIRVisionBarcodeURLBookmark *url) {
  return @{
    @"title" : url.title,
    @"url" : url.url,
  };
}

NSDictionary *visionBarcodeGeoPointToDictionary(FIRVisionBarcodeGeoPoint *geo) {
  return @{
    @"longitude" : @(geo.longitude),
    @"latitude" : @(geo.latitude),
  };
}

NSDictionary *barcodeContactInfoToDictionary(FIRVisionBarcodeContactInfo *contact) {
  __block NSMutableArray<NSDictionary *> *addresses = [NSMutableArray array];
  [contact.addresses enumerateObjectsUsingBlock:^(FIRVisionBarcodeAddress *_Nonnull address,
                                                  NSUInteger idx, BOOL *_Nonnull stop) {
    __block NSMutableArray<NSString *> *addressLines = [NSMutableArray array];
    [address.addressLines enumerateObjectsUsingBlock:^(NSString *_Nonnull addressLine,
                                                       NSUInteger idx, BOOL *_Nonnull stop) {
      [addressLines addObject:addressLine];
    }];
    [addresses addObject:@{
      @"address_lines" : addressLines,
      @"type" : @(address.type),
    }];
  }];

  __block NSMutableArray<NSDictionary *> *emails = [NSMutableArray array];
  [contact.emails enumerateObjectsUsingBlock:^(FIRVisionBarcodeEmail *_Nonnull email,
                                               NSUInteger idx, BOOL *_Nonnull stop) {
    [emails addObject:@{
      @"address" : email.address,
      @"body" : email.body,
      @"subject" : email.subject,
      @"type" : @(email.type),
    }];
  }];

  __block NSMutableArray<NSDictionary *> *phones = [NSMutableArray array];
  [contact.phones enumerateObjectsUsingBlock:^(FIRVisionBarcodePhone *_Nonnull phone,
                                               NSUInteger idx, BOOL *_Nonnull stop) {
    [phones addObject:@{
      @"number" : phone.number,
      @"type" : @(phone.type),
    }];
  }];

  __block NSMutableArray<NSString *> *urls = [NSMutableArray array];
  [contact.urls
      enumerateObjectsUsingBlock:^(NSString *_Nonnull url, NSUInteger idx, BOOL *_Nonnull stop) {
        [urls addObject:url];
      }];
  return @{
    @"addresses" : addresses,
    @"emails" : emails,
    @"name" : @{
      @"formatted_name" : contact.name.formattedName,
      @"first" : contact.name.first,
      @"last" : contact.name.last,
      @"middle" : contact.name.middle,
      @"prefix" : contact.name.prefix,
      @"pronunciation" : contact.name.pronounciation,
      @"suffix" : contact.name.suffix,
    },
    @"phones" : phones,
    @"urls" : urls,
    @"job_title" : contact.jobTitle,
    @"organization" : contact.organization,
  };
}

NSDictionary *calendarEventToDictionary(FIRVisionBarcodeCalendarEvent *calendar) {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  dateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
  dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
  return @{
    @"event_description" : calendar.eventDescription,
    @"location" : calendar.location,
    @"organizer" : calendar.organizer,
    @"status" : calendar.status,
    @"summary" : calendar.summary,
    @"start" : [dateFormatter stringFromDate:calendar.start],
    @"end" : [dateFormatter stringFromDate:calendar.end],
  };
}

NSDictionary *driverLicenseToDictionary(FIRVisionBarcodeDriverLicense *license) {
  return @{
    @"first_name" : license.firstName,
    @"middle_name" : license.middleName,
    @"last_name" : license.lastName,
    @"gender" : license.gender,
    @"address_city" : license.addressCity,
    @"address_street" : license.addressStreet,
    @"address_state" : license.addressState,
    @"address_zip" : license.addressZip,
    @"birth_date" : license.birthDate,
    @"document_type" : license.documentType,
    @"license_number" : license.licenseNumber,
    @"expiry_date" : license.expiryDate,
    @"issuing_date" : license.issuingDate,
    @"issuing_country" : license.issuingCountry,
  };
}

@end
