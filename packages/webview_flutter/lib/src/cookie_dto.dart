import 'dart:io';

import 'package:flutter/foundation.dart';

class CookieDto {
  CookieDto({
    @required String name,
    @required String value,
  })  : _name = name,
        _value = value,
        originalCookie = null;

  CookieDto.fromCookie(this.originalCookie)
      : _name = null,
        _value = null;

  factory CookieDto.fromJson(dynamic json) {
    return CookieDto(
      name: json['name'],
      value: json['value'],
    );
  }

  final String _name;
  final String _value;

  final Cookie originalCookie;

  String get name => originalCookie?.name ?? _name;
  String get value => originalCookie?.value ?? _value;
  bool get hasOriginalCookie => originalCookie != null;

  Cookie toCookie() => Cookie(name, value);
  Map<String, String> toJson() =>
      <String, String>{'name': name, 'value': value};

  @override
  String toString() => toCookie().toString();
}
