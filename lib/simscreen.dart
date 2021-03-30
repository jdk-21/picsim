import 'package:flutter/material.dart';
import 'package:picsim/instructionRecognizer.dart';
import 'package:picsim/main.dart';

class SimScreen extends StatefulWidget {
  @override
  _SimScreenState createState() => _SimScreenState();
}

class _SimScreenState extends State<SimScreen> {
  InstructionRecognizer instructionRecognizer = InstructionRecognizer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PicSim"),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.blue[50]),
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                    onPressed: () => instructionRecognizer.recognize("01011111111111"),
                    child: Text("Start"),
                    style: OutlinedButton.styleFrom(
                        primary: Colors.white, backgroundColor: Colors.green)),
                OutlinedButton(
                    onPressed: () => print("step"), child: Text("Step")),
                OutlinedButton(
                  onPressed: () => print("reset"),
                  child: Text("Reset"),
                  style: OutlinedButton.styleFrom(
                      primary: Colors.white, backgroundColor: Colors.red),
                )
              ],
            ),
          ),
          Container(
            height: 500,
            child: ListView.builder(
              itemCount: programmSpeicher.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Checkbox(
                    activeColor: Colors.redAccent,
                    value: false,
                    onChanged: (value) => print("value changed"),
                  ),
                  title: Text(programmSpeicher[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
