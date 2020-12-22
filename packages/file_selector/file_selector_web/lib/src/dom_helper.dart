import 'dart:async';
import 'dart:html';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

/// Class to manipulate the DOM with the intention of reading files from it.
class DomHelper {
  final FileUploadInputElement _input;

  /// Default constructor, initializes _input (an html <input /> element).
  DomHelper({@visibleForTesting FileUploadInputElement input})
      : _input = input ?? FileUploadInputElement() {
    final body = querySelector('body');
    final container = Element.tag('file-selector');
    body.children.add(container);
    container.children.add(_input);
  }

  /// Sets the <input /> attributes and waits for a file to be selected.
  Future<List<File>> getFilesFromInput({
    String accept = '',
    bool multiple = false,
  }) {
    final Completer<List<File>> _completer = Completer();
    StreamSubscription<Event> onChangeSubscription;
    StreamSubscription<Event> onErrorSubscription;

    _input
      ..accept = accept
      ..multiple = multiple;

    onChangeSubscription = _input.onChange.listen((_) {
      final List<File> files = _input.files;
      onChangeSubscription.cancel();
      _completer.complete(files);
    });

    onErrorSubscription = _input.onError.listen((event) {
      final ErrorEvent error = event;
      final platformException = PlatformException(
        code: error.type,
        message: error.message,
      );
      onErrorSubscription.cancel();
      _completer.completeError(platformException);
    });

    _input.click();

    return _completer.future;
  }
}
