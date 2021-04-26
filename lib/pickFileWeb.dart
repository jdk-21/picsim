
import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;

Future pickFile() async {
  /*FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['lst'],
  );
  print(result?.files.first.bytes);
  if (result?.files.first != null) {
    print(result?.files.first.bytes);
    //return file;
  } else {
    throw "Cancelled File Picker";
  }*/
  // get file
  /*FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: FileType.any, allowMultiple: false);
  await Future.delayed(Duration(seconds: 3));
  print(result?.files.first.name);
  if (result?.files.first != null) {
    var fileBytes = result?.files.first.bytes;
    var fileName = result?.files.first.name;
    print(fileBytes);
    print(fileName);

  }*/
  final typeGroup = XTypeGroup(label: 'images', extensions: ['lst']);
  final file = await openFile(acceptedTypeGroups: [typeGroup]);
  if (file != null) {
    print(file.name);
    print(file.path);
    //var res = File();

    final res = await http.get(Uri.dataFromString(file.path.toString()));
    print(res.body);
    //var res = BASE64.decode(result);
    print(res.toString());
    print("blub");
    print(await file.readAsString());
    //final result = file.toFile();
    //return result;
  }
}
