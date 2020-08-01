import 'dart:async';

import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';


import 'dart:convert';
import 'dart:typed_data';
import 'dart:html';

import 'package:file_picker_web/file_picker_web.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';

import 'package:platform_detect/test_utils.dart' as platform;

final String expectedStringContents = 'Hello, world!';
final expectedSize = expectedStringContents.length;
final Uint8List bytes = utf8.encode(expectedStringContents);
final File textFile = File([bytes], 'hello.txt');

final String expectedStringContents2 = 'This is the other test file';
final expectedSize2 = expectedStringContents.length;
final Uint8List bytes2 = utf8.encode(expectedStringContents);
final File textFile2 = File([bytes], 'test2.txt');


/// Test Markers
void main() {
  E2EWidgetsFlutterBinding.ensureInitialized() as E2EWidgetsFlutterBinding;

  group('loadFile: ', () {
    test('Select a single file to load', () async {
      final mockInput = FileUploadInputElement();

      // Note that we override the retrieval of files from the input element.
      // We opt to do this because dart cannot edit the "files" attribute of
      // <input> tag. When performing mockInput.files = [ textFile ] we receive:
      // "Failed to set the 'files' property on 'HTMLInputElement': The provided
      // value is not of type 'FileList'."
      //
      // More on this (javascript side): https://stackoverflow.com/questions/52078853/is-it-possible-to-update-filelist
      // The dart implementation will depend on the javascript it creates.
      final plugin = FilePickerPlugin(
          overrides: FilePickerPluginTestOverrides()
            ..createFileInputElement = ((_) => mockInput)
            ..getFilesFromInputElement = ((_) => [textFile])
      );

      // Call load file
      final files = plugin.loadFile();

      // Mock selection of a file
      mockInput.dispatchEvent(Event('change'));

      // Expect the file to complete
      expect(files, completes);

      // Expect that we can read from the file
      final loadedFiles = await files;
      final loadedFile = loadedFiles.first;
      expect(loadedFile.readAsBytes(), completion(isNotEmpty));
      expect(loadedFile.length(), completion(equals(expectedSize)));
      expect(loadedFile.name, textFile.name);
    });

    test('Select multiple files to load', () async {
      final mockInput = FileUploadInputElement();

      final plugin = FilePickerPlugin(
          overrides: FilePickerPluginTestOverrides()
            ..createFileInputElement = ((_) => mockInput)
            ..getFilesFromInputElement = ((_) => [textFile, textFile2])
      );

      // Call load file
      final files = plugin.loadFile();

      // Mock selection of a file
      mockInput.dispatchEvent(Event('change'));

      // Expect the file to complete
      expect(files, completes);

      // Expect that we can read from the files
      final loadedFiles = await files;
      final file1 = loadedFiles[0];
      expect(file1.readAsBytes(), completion(isNotEmpty));
      expect(file1.length(), completion(equals(expectedSize)));
      expect(file1.name, textFile.name);

      final file2 = loadedFiles[1];
      expect(file2.readAsBytes(), completion(isNotEmpty));
      expect(file2.length(), completion(equals(expectedSize2)));
      expect(file2.name, textFile2.name);
    });
  });

  group('saveFile: ', () {
    test('Create a blob', () {
      Uint8List data = Uint8List.fromList(expectedStringContents.codeUnits);

      FilePickerPlugin plugin = FilePickerPlugin();
      final blob = plugin.createBlob(data, 'text/plain');

      expect(blob.type, 'text/plain');
      expect(blob.size, expectedSize);
    });

    test('Create an anchor', () {
      FilePickerPlugin plugin = FilePickerPlugin();
      final String href = 'https://google.com';
      final String name = 'file_name.txt';
      final anchor = plugin.createAnchorElement(href, name);

      expect(anchor.download, name);
      expect(anchor.href, href);
    });
  });
}
