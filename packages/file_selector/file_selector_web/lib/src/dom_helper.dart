// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Class to manipulate the DOM with the intention of reading files from it.
class DomHelper {
  /// Default constructor, initializes the container DOM element.
  DomHelper() {
    final Element body = querySelector('body')!;
    body.children.add(_container);
  }

  final Element _container = Element.tag('file-selector');

  /// Sets the <input /> attributes and waits for a file to be selected.
  Future<List<XFile>> getFiles({
    String accept = '',
    bool multiple = false,
    @visibleForTesting FileUploadInputElement? input,
  }) {
    final Completer<List<XFile>> completer = Completer<List<XFile>>();
    final FileUploadInputElement inputElement =
        input ?? FileUploadInputElement();

    _container.children.add(
      inputElement
        ..accept = accept
        ..multiple = multiple,
    );

    inputElement.onChange.first.then((_) {
      final List<XFile> files =
          inputElement.files!.map(_convertFileToXFile).toList();
      inputElement.remove();
      completer.complete(files);
    });

    inputElement.onError.first.then((Event event) {
      final ErrorEvent error = event as ErrorEvent;
      final PlatformException platformException = PlatformException(
        code: error.type,
        message: error.message,
      );
      inputElement.remove();
      completer.completeError(platformException);
    });

    inputElement.click();

    return completer.future;
  }

  XFile _convertFileToXFile(File file) => XFile(
        Url.createObjectUrl(file),
        name: file.name,
        length: file.size,
        lastModified: DateTime.fromMillisecondsSinceEpoch(
            file.lastModified ?? DateTime.now().millisecondsSinceEpoch),
      );
}
