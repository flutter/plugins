#import "FirebaseMlVisionPlugin.h"

@implementation BarcodeDetector
static FIRVisionBarcodeDetector *barcodeDetector;

+ (void)handleDetection:(FIRVisionImage *)image
                options:(NSDictionary *)options
                 result:(FlutterResult)result {
  if (barcodeDetector == nil) {
    FIRVision *vision = [FIRVision vision];
    barcodeDetector = [vision barcodeDetectorWithOptions:[BarcodeDetector parseOptions:options]];
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
    @"rawValue" : barcode.rawValue,
    @"displayValue" : barcode.displayValue ? barcode.displayValue : [NSNull null],
    @"left" : @((int)barcode.frame.origin.x),
    @"top" : @((int)barcode.frame.origin.y),
    @"width" : @((int)barcode.frame.size.width),
    @"height" : @((int)barcode.frame.size.height),
    @"format" : @(barcode.format),
    @"valueType" : @(barcode.valueType),
    @"points" : points,
    @"wifi" : barcode.wifi ? visionBarcodeWiFiToDictionary(barcode.wifi) : [NSNull null],
    @"email" : barcode.email ? visionBarcodeEmailToDictionary(barcode.email) : [NSNull null],
    @"phone" : barcode.phone ? visionBarcodePhoneToDictionary(barcode.phone) : [NSNull null],
    @"sms" : barcode.sms ? visionBarcodeSMSToDictionary(barcode.sms) : [NSNull null],
    @"url" : barcode.URL ? visionBarcodeURLToDictionary(barcode.URL) : [NSNull null],
    @"geoPoint" : barcode.geoPoint ? visionBarcodeGeoPointToDictionary(barcode.geoPoint)
                                   : [NSNull null],
    @"contactInfo" : barcode.contactInfo ? barcodeContactInfoToDictionary(barcode.contactInfo)
                                         : [NSNull null],
    @"calendarEvent" : barcode.calendarEvent ? calendarEventToDictionary(barcode.calendarEvent)
                                             : [NSNull null],
    @"driverLicense" : barcode.driverLicense ? driverLicenseToDictionary(barcode.driverLicense)
                                             : [NSNull null],
  };
}

NSDictionary *visionBarcodeWiFiToDictionary(FIRVisionBarcodeWiFi *wifi) {
  return @{
    @"ssid" : wifi.ssid,
    @"password" : wifi.password,
    @"encryptionType" : @(wifi.type),
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
    @"phoneNumber" : sms.phoneNumber,
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
      @"addressLines" : addressLines,
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
      @"formattedName" : contact.name.formattedName,
      @"first" : contact.name.first,
      @"last" : contact.name.last,
      @"middle" : contact.name.middle,
      @"prefix" : contact.name.prefix,
      @"pronunciation" : contact.name.pronounciation,
      @"suffix" : contact.name.suffix,
    },
    @"phones" : phones,
    @"urls" : urls,
    @"jobTitle" : contact.jobTitle,
    @"organization" : contact.organization,
  };
}

NSDictionary *calendarEventToDictionary(FIRVisionBarcodeCalendarEvent *calendar) {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  dateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
  dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
  return @{
    @"eventDescription" : calendar.eventDescription,
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
    @"firstName" : license.firstName,
    @"middleName" : license.middleName,
    @"lastName" : license.lastName,
    @"gender" : license.gender,
    @"addressCity" : license.addressCity,
    @"addressStreet" : license.addressStreet,
    @"addressState" : license.addressState,
    @"addressZip" : license.addressZip,
    @"birthDate" : license.birthDate,
    @"documentType" : license.documentType,
    @"licenseNumber" : license.licenseNumber,
    @"expiryDate" : license.expiryDate,
    @"issuingDate" : license.issuingDate,
    @"issuingCountry" : license.issuingCountry,
  };
}

+ (FIRVisionBarcodeDetectorOptions *)parseOptions:(NSDictionary *)optionsData {
  NSNumber *barcodeFormat = optionsData[@"barcodeFormats"];
  return [[FIRVisionBarcodeDetectorOptions alloc]
      initWithFormats:(FIRVisionBarcodeFormat)barcodeFormat.intValue];
}
@end
