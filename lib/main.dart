import 'package:flutter/material.dart';
import 'dart:io';

import 'package:picsim/pickFileiOSAndroid.dart';
import 'package:picsim/pickFileWindows.dart';
//import 'pickFileWeb.dart';
import 'package:picsim/instructionCycler.dart';
import 'package:picsim/simscreen.dart';

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
        String m = "00000000000000" +
            int.parse(part.substring(5, 9), radix: 16).toRadixString(2);
        m = m.substring(m.length - 14);
        cycler.programStorage.add(m);
        program.add({
          'index': cycler.programStorage.length - 1,
          'content': part,
          'isSelected': false,
          'isBreakpoint': false
        });
      } else {
        program
            .add({'content': part, 'isSelected': false, 'isBreakpoint': false});
      }
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
            File result;
            if (Platform.isAndroid || Platform.isIOS) {
              result = await pickFileMobile();
            } else if (Platform.isWindows) {
              result = pickFileWin();
            } else {
              throw "Unsupported Platform";
            }
            // web support
            //result = await pickFile();
            
            var data = await result.readAsLines();

            print(data.toString());
            print(result.path);
            program = [];
            readProgramCode(data);
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SimScreen()),
            );
          },
        ),
      ),
    );
  }
}
