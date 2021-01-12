// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

/// Class to manipulate the DOM with the intention of reading files from it.
class DomHelper {
  final _container = Element.tag('file-selector');

  /// Default constructor, initializes the container DOM element.
  DomHelper() {
    final body = querySelector('body');
    body.children.add(_container);
  }

  /// Sets the <input /> attributes and waits for a file to be selected.
  Future<List<XFile>> getFiles({
    String accept = '',
    bool multiple = false,
    @visibleForTesting FileUploadInputElement input,
  }) {
    final Completer<List<XFile>> _completer = Completer();
    input = input ?? FileUploadInputElement();

    _container.children.add(
      input
        ..accept = accept
        ..multiple = multiple,
    );

    input.onChange.first.then((_) {
      final List<XFile> files = input.files.map(_convertFileToXFile).toList();
      input.remove();
      _completer.complete(files);
    });

    input.onError.first.then((event) {
      final ErrorEvent error = event;
      final platformException = PlatformException(
        code: error.type,
        message: error.message,
      );
      input.remove();
      _completer.completeError(platformException);
    });

    input.click();

    return _completer.future;
  }

  XFile _convertFileToXFile(File file) => XFile(
        Url.createObjectUrl(file),
        name: file.name,
        length: file.size,
        lastModified: DateTime.fromMillisecondsSinceEpoch(file.lastModified),
      );
}
