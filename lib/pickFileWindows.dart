import 'dart:io';
import 'package:filepicker_windows/filepicker_windows.dart';

File pickFileWin() {
  final file = OpenFilePicker()
    ..filterSpecification = {
      'Listing-Datei (*.lst)': '*.lst',
      'All Files': '*.*'
    }
    ..defaultFilterIndex = 0
    ..defaultExtension = 'lst'
    ..title = 'Select a Listing';
    final result = file.getFile()!;
  return result;
}
