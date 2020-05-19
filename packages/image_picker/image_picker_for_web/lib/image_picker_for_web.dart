import 'dart:async';
import 'dart:html' as html;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

final String _kImagePickerInputsDomId = '__image_picker_web-file-input';
final String _kAcceptImageMimeType = 'image/*';
final String _kAcceptVideoMimeType = 'video/*';

/// The web implementation of [ImagePickerPlatform].
///
/// This class implements the `package:image_picker` functionality for the web.
class ImagePickerPlugin extends ImagePickerPlatform {
  final Function _overrideCreateInput;
  bool get _shouldOverrideInput => _overrideCreateInput != null;

  html.Element _target;

  /// A constructor that allows tests to override the function that creates file inputs.
  ImagePickerPlugin({@visibleForTesting Function overrideCreateInput})
      : _overrideCreateInput = overrideCreateInput {
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
    String capture = _computeCaptureAttribute(source, preferredCameraDevice);
    return _pickFile(accept: _kAcceptImageMimeType, capture: capture);
  }

  @override
  Future<PickedFile> pickVideo({
    @required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration maxDuration,
  }) {
    String capture = _computeCaptureAttribute(source, preferredCameraDevice);
    return _pickFile(accept: _kAcceptVideoMimeType, capture: capture);
  }

  /// Injects a file input with the specified accept+capture attributes, and
  /// returns the PickedFile that the user selected locally.
  ///
  /// `capture` is only supported in mobile browsers.
  /// See https://caniuse.com/#feat=html-media-capture
  Future<PickedFile> _pickFile({
    String accept,
    String capture,
  }) {
    html.FileUploadInputElement input = _createInputElement(accept, capture);
    _injectAndActivate(input);
    return _getSelectedFile(input);
  }

  // DOM methods

  /// Converts plugin configuration into a proper value for the `capture` attribute.
  String _computeCaptureAttribute(ImageSource source, CameraDevice device) {
    String capture;
    if (source == ImageSource.camera) {
      capture = device == CameraDevice.front ? 'user' : 'environment';
    }
    return capture;
  }

  /// Handles the OnChange event from a FileUploadInputElement object
  /// Returns the objectURL of the selected file.
  String _handleOnChangeEvent(html.Event event) {
    // load the file...
    final html.FileUploadInputElement input = event.target;
    final html.File file = input.files[0];

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
  html.Element _createInputElement(String accept, String capture) {
    html.Element element;

    if (_shouldOverrideInput) {
      return _overrideCreateInput(accept, capture);
    }

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
    if (!_shouldOverrideInput) {
      _target.children.clear();
      _target.children.add(element);
    }
    element.click();
  }
}
