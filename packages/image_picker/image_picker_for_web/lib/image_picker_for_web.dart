import 'dart:async';
import 'dart:html' as html;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

final String _kImagePickerInputsDomId = '__image_picker_web-file-input';
final String _kAcceptImageMimeType = 'image/*';
// This may not be enough for Safari.
final String _kAcceptVideoMimeType = 'video/*';

/// The web implementation of [ImagePickerPlatform].
///
/// This class implements the `package:image_picker` functionality for the web.
class ImagePickerPlugin extends ImagePickerPlatform {
  final ImagePickerPluginTestOverrides _overrides;
  bool get _hasOverrides => _overrides != null;

  html.Element _target;

  /// A constructor that allows tests to override the function that creates file inputs.
  ImagePickerPlugin({
    @visibleForTesting ImagePickerPluginTestOverrides overrides,
  }) : _overrides = overrides {
    _target = _initTarget(_kImagePickerInputsDomId);
  }

  /// Registers this class as the default instance of [ImagePickerPlatform].
  static void registerWith(Registrar registrar) {
    ImagePickerPlatform.instance = ImagePickerPlugin();
  }

  @override
  Future<PickedFile> pickImage({
    @required ImageSource source,
    double maxWidth,
    double maxHeight,
    int imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) {
    String capture = computeCaptureAttribute(source, preferredCameraDevice);
    return pickFile(accept: _kAcceptImageMimeType, capture: capture);
  }

  @override
  Future<PickedFile> pickVideo({
    @required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration maxDuration,
  }) {
    String capture = computeCaptureAttribute(source, preferredCameraDevice);
    return pickFile(accept: _kAcceptVideoMimeType, capture: capture);
  }

  /// Injects a file input with the specified accept+capture attributes, and
  /// returns the PickedFile that the user selected locally.
  ///
  /// `capture` is only supported in mobile browsers.
  /// See https://caniuse.com/#feat=html-media-capture
  @visibleForTesting
  Future<PickedFile> pickFile({
    String accept,
    String capture,
  }) {
    html.FileUploadInputElement input = createInputElement(accept, capture);
    _injectAndActivate(input);
    return _getSelectedFile(input);
  }

  // DOM methods

  /// Converts plugin configuration into a proper value for the `capture` attribute.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/file#capture
  @visibleForTesting
  String computeCaptureAttribute(ImageSource source, CameraDevice device) {
    String capture;
    if (source == ImageSource.camera) {
      capture = device == CameraDevice.front ? 'user' : 'environment';
    }
    return capture;
  }

  html.File _getFileFromInput(html.FileUploadInputElement input) {
    if (_hasOverrides) {
      return _overrides.getFileFromInput(input);
    }
    return input.files[0];
  }

  /// Handles the OnChange event from a FileUploadInputElement object
  /// Returns the objectURL of the selected file.
  String _handleOnChangeEvent(html.Event event) {
    // load the file...
    final html.FileUploadInputElement input = event.target;
    final html.File file = _getFileFromInput(input);

    if (file != null) {
      return html.Url.createObjectUrl(file);
    }
    return null;
  }

  /// Monitors an <input type="file"> and returns the selected file.
  Future<PickedFile> _getSelectedFile(html.FileUploadInputElement input) async {
    // Observe the input until we can return something
    final Completer<PickedFile> _completer = Completer<PickedFile>();
    input.onChange.listen((html.Event event) async {
      final objectUrl = _handleOnChangeEvent(event);
      _completer.complete(PickedFile(objectUrl));
    });
    input.onError // What other events signal failure?
        .listen((html.Event event) {
      _completer.completeError(event);
    });

    return _completer.future;
  }

  /// Initializes a DOM container where we can host input elements.
  html.Element _initTarget(String id) {
    var target = html.querySelector('#${id}');
    if (target == null) {
      final html.Element targetElement =
          html.Element.tag('flt-image-picker-inputs')..id = id;

      html.querySelector('body').children.add(targetElement);
      target = targetElement;
    }
    return target;
  }

  /// Creates an input element that accepts certain file types, and
  /// allows to `capture` from the device's cameras (where supported)
  @visibleForTesting
  html.Element createInputElement(String accept, String capture) {
    if (_hasOverrides) {
      return _overrides.createInputElement(accept, capture);
    }

    html.Element element;

    if (capture != null) {
      // Capture is not supported by dart:html :/
      element = html.Element.html(
          '<input type="file" accept="$accept" capture="$capture" />',
          validator: html.NodeValidatorBuilder()
            ..allowElement('input', attributes: ['type', 'accept', 'capture']));
    } else {
      element = html.FileUploadInputElement()..accept = accept;
    }

    return element;
  }

  /// Injects the file input element, and clicks on it
  void _injectAndActivate(html.Element element) {
    _target.children.clear();
    _target.children.add(element);
    element.click();
  }
}

// Some tools to override behavior for unit-testing
typedef _OverrideCreateInputFunction = html.Element Function(
  String accept,
  String capture,
);
typedef _OverrideExtractFilesFromInputFunction = html.File Function(
  html.Element,
);

/// Overrides for some of the functionality above.
@visibleForTesting
class ImagePickerPluginTestOverrides {
  /// Override the creation of the input element.
  _OverrideCreateInputFunction createInputElement;

  /// Override the extraction of the selected file from an input element.
  _OverrideExtractFilesFromInputFunction getFileFromInput;
}
