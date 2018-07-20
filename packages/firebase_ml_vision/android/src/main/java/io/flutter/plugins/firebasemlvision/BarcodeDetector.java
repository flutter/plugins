package io.flutter.plugins.firebasemlvision;

import android.graphics.Point;
import android.graphics.Rect;
import android.support.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.barcode.FirebaseVisionBarcode;
import com.google.firebase.ml.vision.barcode.FirebaseVisionBarcodeDetector;
import com.google.firebase.ml.vision.barcode.FirebaseVisionBarcodeDetectorOptions;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class BarcodeDetector implements Detector {
  public static final BarcodeDetector instance = new BarcodeDetector();

  private BarcodeDetector() {}

  @Override
  public void handleDetection(
      FirebaseVisionImage image, Map<String, Object> options, final MethodChannel.Result result) {

    FirebaseVisionBarcodeDetector detector = FirebaseVision.getInstance().getVisionBarcodeDetector(parseOptions(options));

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
                    barcodeMap.put("left", bounds.left);
                    barcodeMap.put("top", bounds.top);
                    barcodeMap.put("width", bounds.width());
                    barcodeMap.put("height", bounds.height());
                  }

                  List<int[]> points = new ArrayList<>();
                  if (barcode.getCornerPoints() != null) {
                    for (Point point : barcode.getCornerPoints()) {
                      points.add(new int[] {point.x, point.y});
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
                      typeValue.put("type", barcode.getEmail().getType());
                      typeValue.put("address", barcode.getEmail().getAddress());
                      typeValue.put("body", barcode.getEmail().getBody());
                      typeValue.put("subject", barcode.getEmail().getSubject());
                      barcodeMap.put("email", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_PHONE:
                      typeValue.put("number", barcode.getPhone().getNumber());
                      typeValue.put("type", barcode.getPhone().getType());
                      barcodeMap.put("phone", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_SMS:
                      typeValue.put("message", barcode.getSms().getMessage());
                      typeValue.put("phoneNumber", barcode.getSms().getPhoneNumber());
                      barcodeMap.put("sms", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_URL:
                      typeValue.put("title", barcode.getUrl().getTitle());
                      typeValue.put("url", barcode.getUrl().getUrl());
                      barcodeMap.put("url", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_WIFI:
                      typeValue.put("ssid", barcode.getWifi().getSsid());
                      typeValue.put("password", barcode.getWifi().getPassword());
                      typeValue.put("encryptionType", barcode.getWifi().getEncryptionType());
                      barcodeMap.put("wifi", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_GEO:
                      typeValue.put("latitude", barcode.getGeoPoint().getLat());
                      typeValue.put("longitude", barcode.getGeoPoint().getLng());
                      barcodeMap.put("geoPoint", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_CONTACT_INFO:
                      List<Map<String, Object>> addresses = new ArrayList<>();
                      for (FirebaseVisionBarcode.Address address :
                          barcode.getContactInfo().getAddresses()) {
                        Map<String, Object> addressMap = new HashMap<>();
                        addressMap.put("addressLines", address.getAddressLines());
                        addressMap.put("type", address.getType());
                        addresses.add(addressMap);
                      }
                      typeValue.put("addresses", addresses);

                      List<Map<String, Object>> emails = new ArrayList<>();
                      for (FirebaseVisionBarcode.Email email :
                          barcode.getContactInfo().getEmails()) {
                        Map<String, Object> emailMap = new HashMap<>();
                        emailMap.put("address", email.getAddress());
                        emailMap.put("type", email.getType());
                        emailMap.put("body", email.getBody());
                        emailMap.put("subject", email.getSubject());
                        emails.add(emailMap);
                      }
                      typeValue.put("emails", emails);

                      Map<String, Object> name = new HashMap<>();
                      if (barcode.getContactInfo().getName() != null) {
                        name.put(
                            "formattedName", barcode.getContactInfo().getName().getFormattedName());
                        name.put("first", barcode.getContactInfo().getName().getFirst());
                        name.put("last", barcode.getContactInfo().getName().getLast());
                        name.put("middle", barcode.getContactInfo().getName().getMiddle());
                        name.put("prefix", barcode.getContactInfo().getName().getPrefix());
                        name.put(
                            "pronunciation", barcode.getContactInfo().getName().getPronunciation());
                        name.put("suffix", barcode.getContactInfo().getName().getSuffix());
                      }
                      typeValue.put("name", name);

                      List<Map<String, Object>> phones = new ArrayList<>();
                      for (FirebaseVisionBarcode.Phone phone :
                          barcode.getContactInfo().getPhones()) {
                        Map<String, Object> phoneMap = new HashMap<>();
                        phoneMap.put("number", phone.getNumber());
                        phoneMap.put("type", phone.getType());
                        phones.add(phoneMap);
                      }
                      typeValue.put("phones", phones);

                      typeValue.put("urls", barcode.getContactInfo().getUrls());
                      typeValue.put("jobTitle", barcode.getContactInfo().getTitle());
                      typeValue.put("organization", barcode.getContactInfo().getOrganization());

                      barcodeMap.put("contactInfo", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_CALENDAR_EVENT:
                      typeValue.put(
                          "eventDescription", barcode.getCalendarEvent().getDescription());
                      typeValue.put("location", barcode.getCalendarEvent().getLocation());
                      typeValue.put("organizer", barcode.getCalendarEvent().getOrganizer());
                      typeValue.put("status", barcode.getCalendarEvent().getStatus());
                      typeValue.put("summary", barcode.getCalendarEvent().getSummary());
                      if (barcode.getCalendarEvent().getStart() != null) {
                        typeValue.put("start", barcode.getCalendarEvent().getStart().getRawValue());
                      }
                      if (barcode.getCalendarEvent().getEnd() != null) {
                        typeValue.put("end", barcode.getCalendarEvent().getEnd().getRawValue());
                      }
                      barcodeMap.put("calendarEvent", typeValue);
                      break;
                    case FirebaseVisionBarcode.TYPE_DRIVER_LICENSE:
                      typeValue.put("firstName", barcode.getDriverLicense().getFirstName());
                      typeValue.put("middleName", barcode.getDriverLicense().getMiddleName());
                      typeValue.put("lastName", barcode.getDriverLicense().getLastName());
                      typeValue.put("gender", barcode.getDriverLicense().getGender());
                      typeValue.put("addressCity", barcode.getDriverLicense().getAddressCity());
                      typeValue.put(
                          "addressStreet", barcode.getDriverLicense().getAddressStreet());
                      typeValue.put("addressState", barcode.getDriverLicense().getAddressState());
                      typeValue.put("addressZip", barcode.getDriverLicense().getAddressZip());
                      typeValue.put("birthDate", barcode.getDriverLicense().getBirthDate());
                      typeValue.put("documentType", barcode.getDriverLicense().getDocumentType());
                      typeValue.put(
                          "licenseNumber", barcode.getDriverLicense().getLicenseNumber());
                      typeValue.put("expiryDate", barcode.getDriverLicense().getExpiryDate());
                      typeValue.put("issuingDate", barcode.getDriverLicense().getIssueDate());
                      typeValue.put(
                          "issuingCountry", barcode.getDriverLicense().getIssuingCountry());
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