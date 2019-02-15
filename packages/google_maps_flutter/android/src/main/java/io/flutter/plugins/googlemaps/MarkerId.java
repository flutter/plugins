package io.flutter.plugins.googlemaps;

/**
 * Represents the user assigned MarkerId.
 *
 * <p>To be kept in sync with MarkerId on dart side.
 */
public class MarkerId {

  private final String value;

  MarkerId(String value) {
    this.value = value;
  }

  String getValue() {
    return value;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }

    MarkerId markerId = (MarkerId) o;

    return value != null ? value.equals(markerId.value) : markerId.value == null;
  }

  @Override
  public int hashCode() {
    return value != null ? value.hashCode() : 0;
  }

  @Override
  public String toString() {
    return "MarkerId{" + "value='" + value + '\'' + '}';
  }
}
