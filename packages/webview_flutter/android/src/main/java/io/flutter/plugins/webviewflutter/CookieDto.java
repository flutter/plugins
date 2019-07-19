package io.flutter.plugins.webviewflutter;

import java.net.HttpCookie;
import java.util.HashMap;
import java.util.Map;

class CookieDto {
  private CookieDto(String name, String value) {
    this._name = name;
    this._value = value;
  }

  static CookieDto fromHttpCookie(HttpCookie httpCookie) {
    return new CookieDto(httpCookie.getName(), httpCookie.getValue());
  }

  static CookieDto fromMap(Map<String, String> map) {
    return new CookieDto(map.get("name"), map.get("value"));
  }

  private final String _name;
  private final String _value;

  public String getName() {
    return this._name;
  }

  public String getValue() {
    return this._value;
  }

  public HttpCookie toHttpCookie() {
    return new HttpCookie(getName(), getValue());
  }

  public Map<String, String> toMap() {
    final Map<String, String> result = new HashMap<>();
    result.put("name", getName());
    result.put("value", getValue());

    return result;
  }
}
