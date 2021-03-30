import 'package:flutter/material.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:picsim/simscreen.dart';

var programmSpeicher = [];
List<String> storage = List.filled(256, "00");
String wReg = "00000000"; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'PicSim'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void readProgramCode(var data) {
    programmSpeicher = [];
    data.forEach((String part) {
      if (RegExp(r"^[A-Fa-f0-9]{4}\s[A-Fa-f0-9]{4}").hasMatch(part)) {
        programmSpeicher
            .add(int.parse(part.substring(5, 9), radix: 16).toRadixString(2));
      }
    });
    print(programmSpeicher);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title!),
        ),
        body: Center(
            child: OutlinedButton(
          child: Text("Select File"),
          onPressed: () async {
            final file = OpenFilePicker()
              ..filterSpecification = {
                'Listing-Datei (*.lst)': '*.lst',
                'All Files': '*.*'
              }
              ..defaultFilterIndex = 0
              ..defaultExtension = 'lst'
              ..title = 'Select a Listing';

            final result = file.getFile();
            if (result != null) {
              var input = await result.readAsLines();

              print(input.toString());
              print(result.path);
              readProgramCode(input);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SimScreen()),
              );
            }
          },
        )));
  }
}
