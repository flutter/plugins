import 'dart:ffi';
import 'package:win32/win32.dart';

/// MockOpenFileDialog provides an instance of [IFileOpenDialog](https://pub.dev/documentation/win32/latest/winrt/IFileOpenDialog-class.html) for testing purposes.
class MockOpenFileDialog extends IFileOpenDialog {
  /// OpenFileDialogMock's constructor, it receives an [COMObject](https://pub.dev/documentation/win32/latest/winrt/COMObject-class.html) [Pointer](https://api.dart.dev/stable/2.18.1/dart-ffi/Pointer-class.html) which is used in the super constructor.
  MockOpenFileDialog(Pointer<COMObject> ptr) : super(ptr);
}
