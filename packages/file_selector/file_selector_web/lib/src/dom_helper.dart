import 'dart:async';
import 'dart:html';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

/// Class to manipulate the DOM with the intention of reading files from it.
class DomHelper {
  final _container = Element.tag('file-selector');

  DomHelper() {
    final body = querySelector('body');
    body.children.add(_container);
  }

  /// Sets the <input /> attributes and waits for a file to be selected.
  Future<List<File>> getFiles({
    String accept = '',
    bool multiple = false,
    @visibleForTesting FileUploadInputElement input,
  }) {
    final Completer<List<File>> _completer = Completer();

    _container.children.add(
      (input ?? FileUploadInputElement())
        ..accept = accept
        ..multiple = multiple,
    );

    input.onChange.first.then((_) {
      final List<File> files = input.files;
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
}
