// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:mime/mime.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Picker Demo',
      home: MyHomePage(title: 'Image Picker Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum PickType {
  image,
  video,
  media,
}

class _MyHomePageState extends State<MyHomePage> {
  List<XFile>? _fileList;

  set _file(XFile? value) {
    _fileList = value == null ? null : [value];
    _refreshFileMimeTypes();
  }

  dynamic _pickError;
  PickType? pickType;

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  void _refreshFileMimeTypes() {
    if (_fileList == null) {
      return;
    }
    _fileList = _fileList!
        .map((file) => XFile(file.path, mimeType: lookupMimeType(file.path)))
        .toList();
  }

  void _onPickButtonPressed(ImageSource source,
      {BuildContext? context, bool isMulti = false}) async {
    if (pickType == null) {
      return;
    }
    switch (pickType!) {
      case PickType.image:
        if (isMulti) {
          await _displayPickImageDialog(context!,
              (double? maxWidth, double? maxHeight, int? quality) async {
            try {
              final pickedFileList = await _picker.pickMultiImage(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                imageQuality: quality,
              );
              setState(() {
                _fileList = pickedFileList;
                _refreshFileMimeTypes();
              });
            } catch (e) {
              setState(() {
                _pickError = e;
              });
            }
          });
        } else {
          await _displayPickImageDialog(context!,
              (double? maxWidth, double? maxHeight, int? quality) async {
            try {
              final pickedFile = await _picker.pickImage(
                source: source,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                imageQuality: quality,
              );
              setState(() {
                _file = pickedFile;
              });
            } catch (e) {
              setState(() {
                _pickError = e;
              });
            }
          });
        }
        break;
      case PickType.media:
        await _displayPickImageDialog(context!,
            (double? maxWidth, double? maxHeight, int? quality) async {
          try {
            final pickedFileList = await _picker.pickMedia(
              options: MediaSelectionOptions(
                maxImageWidth: maxWidth,
                maxImageHeight: maxHeight,
                imageQuality: quality,
                allowMultiple: false,
              ),
            );
            setState(() {
              _fileList = pickedFileList;
              _refreshFileMimeTypes();
            });
          } catch (e) {
            setState(() {
              _pickError = e;
            });
          }
        });
        break;
      case PickType.video:
        final XFile? file = await _picker.pickVideo(
          source: source,
          maxDuration: const Duration(seconds: 10),
        );
        setState(() {
          _file = file;
        });
        break;
    }
  }

  @override
  void dispose() {
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  Widget _handlePreview() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_fileList != null) {
      return Semantics(
          child: ListView.builder(
            key: UniqueKey(),
            itemBuilder: (context, index) {
              XFile file = _fileList![index];
              if (file.mimeType?.startsWith('image/') == true) {
                return Semantics(
                  label: 'image_picker_example_picked_image',
                  // Why network for web?
                  // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
                  child: kIsWeb
                      ? Image.network(_fileList![index].path)
                      : Image.file(File(_fileList![index].path)),
                );
              } else if (file.mimeType?.startsWith('video/') == true) {
                return Semantics(
                  label: 'image_picker_example_picked_video',
                  child: AutoPlayingVideo(file),
                );
              } else {
                return Text(
                    'Picked file could not be previewed: ${file.path}, Mime: ${file.mimeType}');
              }
            },
            itemCount: _fileList!.length,
          ),
          label: 'image_picker_example_picked_images');
    } else if (_pickError != null) {
      return Text(
        'Pick error: $_pickError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image or video.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.files != null) {
      setState(() {
        _fileList = response.files;
        _refreshFileMimeTypes();
      });
    } else if (response.file != null) {
      _file = response.file;
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Text(
                        'You have not yet picked an image.',
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.done:
                      return _handlePreview();
                    default:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image/video error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const Text(
                          'You have not yet picked an image.',
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              )
            : _handlePreview(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Semantics(
            label: 'image_picker_example_from_gallery',
            child: FloatingActionButton(
              onPressed: () {
                pickType = PickType.image;
                _onPickButtonPressed(ImageSource.gallery, context: context);
              },
              heroTag: 'image0',
              tooltip: 'Pick image from gallery',
              child: const Icon(Icons.photo),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                pickType = PickType.image;
                _onPickButtonPressed(
                  ImageSource.gallery,
                  context: context,
                  isMulti: true,
                );
              },
              heroTag: 'image1',
              tooltip: 'Pick multiple images from gallery',
              child: const Icon(Icons.photo_library),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                pickType = PickType.image;
                _onPickButtonPressed(ImageSource.camera, context: context);
              },
              heroTag: 'image2',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.purple,
              onPressed: () {
                pickType = PickType.media;
                _onPickButtonPressed(
                  ImageSource.gallery,
                  isMulti: true,
                  context: context,
                );
              },
              heroTag: 'imagevideo1',
              tooltip: 'Pick multiple images and videos from gallery',
              child: const Icon(Icons.perm_media_outlined),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                pickType = PickType.video;
                _onPickButtonPressed(ImageSource.gallery, context: context);
              },
              heroTag: 'video0',
              tooltip: 'Pick Video from gallery',
              child: const Icon(Icons.video_library),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                pickType = PickType.video;
                _onPickButtonPressed(ImageSource.camera, context: context);
              },
              heroTag: 'video1',
              tooltip: 'Take a Video',
              child: const Icon(Icons.videocam),
            ),
          ),
        ],
      ),
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add optional parameters'),
            content: Column(
              children: <Widget>[
                TextField(
                  controller: maxWidthController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      InputDecoration(hintText: "Enter maxWidth if desired"),
                ),
                TextField(
                  controller: maxHeightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      InputDecoration(hintText: "Enter maxHeight if desired"),
                ),
                TextField(
                  controller: qualityController,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(hintText: "Enter quality if desired"),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: const Text('PICK'),
                  onPressed: () {
                    double? width = maxWidthController.text.isNotEmpty
                        ? double.parse(maxWidthController.text)
                        : null;
                    double? height = maxHeightController.text.isNotEmpty
                        ? double.parse(maxHeightController.text)
                        : null;
                    int? quality = qualityController.text.isNotEmpty
                        ? int.parse(qualityController.text)
                        : null;
                    onPick(width, height, quality);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }
}

typedef void OnPickImageCallback(
    double? maxWidth, double? maxHeight, int? quality);

class AutoPlayingVideo extends StatefulWidget {
  final XFile file;

  const AutoPlayingVideo(this.file, {Key? key}) : super(key: key);

  @override
  State<AutoPlayingVideo> createState() => _AutoPlayingVideoState();
}

class _AutoPlayingVideoState extends State<AutoPlayingVideo> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (_initialized != _controller!.value.isInitialized) {
      _initialized = _controller!.value.isInitialized;
      setState(() {});
    }
  }

  void _playFile(XFile file) async {
    if (_controller != null) {
      _controller!.removeListener(_onVideoControllerUpdate);
      await _controller!.dispose();
      setState(() {
        _initialized = false;
      });
    }
    if (kIsWeb) {
      _controller = VideoPlayerController.network(file.path);
    } else {
      _controller = VideoPlayerController.file(File(file.path));
    }
    // In web, most browsers won't honor a programmatic call to .play
    // if the video has a sound track (and is not muted).
    // Mute the video so it auto-plays in web!
    // This is not needed if the call to .play is the result of user
    // interaction (clicking on a "play" button, for example).
    final double volume = kIsWeb ? 0.0 : 1.0;
    await _controller!.setVolume(volume);
    await _controller!.initialize();
    await _controller!.setLooping(true);
    await _controller!.play();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _playFile(widget.file);
    _controller!.addListener(_onVideoControllerUpdate);
  }

  void didUpdateWidget(AutoPlayingVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      _playFile(widget.file);
    }
  }

  @override
  void dispose() {
    _controller!.removeListener(_onVideoControllerUpdate);
    _controller!.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller!.setVolume(0.0);
      _controller!.pause();
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}
