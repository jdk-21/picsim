import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<File> pickFileMobile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['lst'],
  );
  if (result != null) {
    File file = File(result.files.single.path!);
    return file;
  } else {
    throw "Cancelled File Picker";
  }
}
