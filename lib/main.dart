import 'package:flutter/material.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:picsim/instructionCycler.dart';
import 'package:picsim/simscreen.dart';
import 'package:stack/stack.dart' as st;

var stack = List<dynamic>.filled(8, null);
List<Map> program = [];
var storage = ValueNotifier<List<String>>(List.filled(256, "00000000"));
var wReg = ValueNotifier<String>("00000000"); 
double runtime = 0;
double cycleDuration = 1;

InstructionCycler cycler = InstructionCycler();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PicSim',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(bodyText2: TextStyle(fontSize: 11)),
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
  	cycler.programStorage = [];
    data.forEach((String part) {
      if (RegExp(r"^[A-Fa-f0-9]{4}\s[A-Fa-f0-9]{4}").hasMatch(part)) {
        String m = "00000000000000" + int.parse(part.substring(5, 9), radix: 16).toRadixString(2);
        m = m.substring(m.length-14);
        cycler.programStorage
            .add(m);
        program.add({'index': cycler.programStorage.length-1, 'content': part, 'isSelected': false});
      }
      else program.add({'content': part, 'isSelected': false});
    });
    print(cycler.programStorage);
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
              var data = await result.readAsLines();

              print(data.toString());
              print(result.path);
              program = [];
              readProgramCode(data);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SimScreen()),
              );
            }
          },
        )));
  }
}
