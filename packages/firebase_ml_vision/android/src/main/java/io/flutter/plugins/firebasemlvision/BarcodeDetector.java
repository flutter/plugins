package io.flutter.plugins.firebasemlvision;

import android.graphics.Point;
import android.graphics.Rect;
import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.barcode.FirebaseVisionBarcode;
import com.google.firebase.ml.vision.barcode.FirebaseVisionBarcodeDetector;
import com.google.firebase.ml.vision.barcode.FirebaseVisionBarcodeDetectorOptions;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import io.flutter.plugin.common.MethodChannel;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class BarcodeDetector implements Detector {
  static final BarcodeDetector instance = new BarcodeDetector();

  private BarcodeDetector() {}

  private FirebaseVisionBarcodeDetector detector;
  private Map<String, Object> lastOptions;

  @Override
  public void handleDetection(
      FirebaseVisionImage image, Map<String, Object> options, final MethodChannel.Result result) {

    // Use instantiated detector if the options are the same. Otherwise, close and instantiate new
    // options.

    if (detector == null) {
      lastOptions = options;
      detector = FirebaseVision.getInstance().getVisionBarcodeDetector(parseOptions(lastOptions));
    } else if (!options.equals(lastOptions)) {
      try {
        detector.close();
      } catch (IOException e) {
        result.error("barcodeDetectorIOError", e.getLocalizedMessage(), null);
        return;
      }

      lastOptions = options;
      detector = FirebaseVision.getInstance().getVisionBarcodeDetector(parseOptions(lastOptions));
    }

    detector
        .detectInImage(image)
        .addOnSuccessListener(
            new OnSuccessListener<List<FirebaseVisionBarcode>>() {
              @Override
              public void onSuccess(List<FirebaseVisionBarcode> firebaseVisionBarcodes) {
                List<Map<String, Object>> barcodes = new ArrayList<>();

                for (FirebaseVisionBarcode barcode : firebaseVisionBarcodes) {
                  Map<String, Object> barcodeMap = new HashMap<>();

                  Rect bounds = barcode.getBoundingBox();
                  if (bounds != null) {
                    barcodeMap.put("left", (double) bounds.left);
                    barcodeMap.put("top", (double) bounds.top);
                    barcodeMap.put("width", (double) bounds.width());
                    barcodeMap.put("height", (double) bounds.height());
                  }

                  List<double[]> points = new ArrayList<>();
                  if (barcode.getCornerPoints() != null) {
                    for (Point point : barcode.getCornerPoints()) {
                      points.add(new double[] {(double) point.x, (double) point.y});
                    }
                  }
                  barcodeMap.put("points", points);

                  barcodeMap.put("rawValue", barcode.getRawValue());
                  barcodeMap.put("displayValue", barcode.getDisplayValue());
                  barcodeMap.put("format", barcode.getFormat());
                  barcodeMap.put("valueType", barcode.getValueType());

                  Map<String, Object> typeValue = new HashMap<>();
                  switch (barcode.getValueType()) {
                    case FirebaseVisionBarcode.TYPE_EMAIL:
                      FirebaseVisionBarcode.Email email = barcode.getEmail();

                      typeValue.put("type", email.getType());
                      typeValue.put("address", email.getAddress());
                      typeValue.put("body", email.getBody());
                      typeValue.put("subject", email.getSubject());

                      barcodeMap.put("email", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_PHONE:
                      FirebaseVisionBarcode.Phone phone = barcode.getPhone();

                      typeValue.put("number", phone.getNumber());
                      typeValue.put("type", phone.getType());

                      barcodeMap.put("phone", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_SMS:
                      FirebaseVisionBarcode.Sms sms = barcode.getSms();

                      typeValue.put("message", sms.getMessage());
                      typeValue.put("phoneNumber", sms.getPhoneNumber());

                      barcodeMap.put("sms", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_URL:
                      FirebaseVisionBarcode.UrlBookmark urlBookmark = barcode.getUrl();

                      typeValue.put("title", urlBookmark.getTitle());
                      typeValue.put("url", urlBookmark.getUrl());

                      barcodeMap.put("url", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_WIFI:
                      FirebaseVisionBarcode.WiFi wifi = barcode.getWifi();

                      typeValue.put("ssid", wifi.getSsid());
                      typeValue.put("password", wifi.getPassword());
                      typeValue.put("encryptionType", wifi.getEncryptionType());

                      barcodeMap.put("wifi", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_GEO:
                      FirebaseVisionBarcode.GeoPoint geoPoint = barcode.getGeoPoint();

                      typeValue.put("latitude", geoPoint.getLat());
                      typeValue.put("longitude", geoPoint.getLng());

                      barcodeMap.put("geoPoint", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_CONTACT_INFO:
                      FirebaseVisionBarcode.ContactInfo contactInfo = barcode.getContactInfo();

                      List<Map<String, Object>> addresses = new ArrayList<>();
                      for (FirebaseVisionBarcode.Address address : contactInfo.getAddresses()) {
                        Map<String, Object> addressMap = new HashMap<>();
                        addressMap.put("addressLines", address.getAddressLines());
                        addressMap.put("type", address.getType());

                        addresses.add(addressMap);
                      }
                      typeValue.put("addresses", addresses);

                      List<Map<String, Object>> emails = new ArrayList<>();
                      for (FirebaseVisionBarcode.Email contactEmail : contactInfo.getEmails()) {
                        Map<String, Object> emailMap = new HashMap<>();
                        emailMap.put("address", contactEmail.getAddress());
                        emailMap.put("type", contactEmail.getType());
                        emailMap.put("body", contactEmail.getBody());
                        emailMap.put("subject", contactEmail.getSubject());

                        emails.add(emailMap);
                      }
                      typeValue.put("emails", emails);

                      Map<String, Object> nameMap = new HashMap<>();
                      FirebaseVisionBarcode.PersonName name = contactInfo.getName();
                      if (name != null) {
                        nameMap.put("formattedName", name.getFormattedName());
                        nameMap.put("first", name.getFirst());
                        nameMap.put("last", name.getLast());
                        nameMap.put("middle", name.getMiddle());
                        nameMap.put("prefix", name.getPrefix());
                        nameMap.put("pronunciation", name.getPronunciation());
                        nameMap.put("suffix", name.getSuffix());
                      }
                      typeValue.put("name", nameMap);

                      List<Map<String, Object>> phones = new ArrayList<>();
                      for (FirebaseVisionBarcode.Phone contactPhone : contactInfo.getPhones()) {
                        Map<String, Object> phoneMap = new HashMap<>();
                        phoneMap.put("number", contactPhone.getNumber());
                        phoneMap.put("type", contactPhone.getType());

                        phones.add(phoneMap);
                      }
                      typeValue.put("phones", phones);

                      typeValue.put("urls", contactInfo.getUrls());
                      typeValue.put("jobTitle", contactInfo.getTitle());
                      typeValue.put("organization", contactInfo.getOrganization());

                      barcodeMap.put("contactInfo", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_CALENDAR_EVENT:
                      FirebaseVisionBarcode.CalendarEvent calendarEvent =
                          barcode.getCalendarEvent();

                      typeValue.put("eventDescription", calendarEvent.getDescription());
                      typeValue.put("location", calendarEvent.getLocation());
                      typeValue.put("organizer", calendarEvent.getOrganizer());
                      typeValue.put("status", calendarEvent.getStatus());
                      typeValue.put("summary", calendarEvent.getSummary());
                      if (calendarEvent.getStart() != null) {
                        typeValue.put("start", calendarEvent.getStart().getRawValue());
                      }
                      if (calendarEvent.getEnd() != null) {
                        typeValue.put("end", calendarEvent.getEnd().getRawValue());
                      }

                      barcodeMap.put("calendarEvent", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_DRIVER_LICENSE:
                      FirebaseVisionBarcode.DriverLicense driverLicense =
                          barcode.getDriverLicense();

                      typeValue.put("firstName", driverLicense.getFirstName());
                      typeValue.put("middleName", driverLicense.getMiddleName());
                      typeValue.put("lastName", driverLicense.getLastName());
                      typeValue.put("gender", driverLicense.getGender());
                      typeValue.put("addressCity", driverLicense.getAddressCity());
                      typeValue.put("addressStreet", driverLicense.getAddressStreet());
                      typeValue.put("addressState", driverLicense.getAddressState());
                      typeValue.put("addressZip", driverLicense.getAddressZip());
                      typeValue.put("birthDate", driverLicense.getBirthDate());
                      typeValue.put("documentType", driverLicense.getDocumentType());
                      typeValue.put("licenseNumber", driverLicense.getLicenseNumber());
                      typeValue.put("expiryDate", driverLicense.getExpiryDate());
                      typeValue.put("issuingDate", driverLicense.getIssueDate());
                      typeValue.put("issuingCountry", driverLicense.getIssuingCountry());

                      barcodeMap.put("driverLicense", typeValue);
                      break;
                  }

                  barcodes.add(barcodeMap);
                }
                result.success(barcodes);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception exception) {
                result.error("barcodeDetectorError", exception.getLocalizedMessage(), null);
              }
            });
  }

  private FirebaseVisionBarcodeDetectorOptions parseOptions(Map<String, Object> optionsData) {
    @SuppressWarnings("unchecked")
    Integer barcodeFormats = (Integer) optionsData.get("barcodeFormats");
    return new FirebaseVisionBarcodeDetectorOptions.Builder()
        .setBarcodeFormats(barcodeFormats)
        .build();
  }
}
