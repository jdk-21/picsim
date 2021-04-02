import 'package:flutter/material.dart';
import 'package:picsim/main.dart';
import 'package:google_fonts/google_fonts.dart';

class SimScreen extends StatefulWidget {
  @override
  _SimScreenState createState() => _SimScreenState();
}

class _SimScreenState extends State<SimScreen> {
  var lastIndex = 0;

  Future<void> lineHighlighter() async {
    while (cycler.run) {
      setState(() {
        // c counts index
        var c = 0;
        print(program.length);
        for (var element in program) {
          print(element);
          if (element['index'] == cycler.programCounter) {
            program[lastIndex]['isSelected'] = false;
            element['isSelected'] = true;
            lastIndex = c;
            print("lbubl"+ element.toString());
            break;
          }
          c++;
        };
      });
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return;
  }

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
                    onPressed: () {
                      if (cycler.run)
                        cycler.pause();
                      else {
                        cycler.start();
                        lineHighlighter();
                      }
                    },
                    child: Text("Start"),
                    style: OutlinedButton.styleFrom(
                        primary: Colors.white, backgroundColor: Colors.green)),
                OutlinedButton(
                    onPressed: () => cycler.step(), child: Text("Step")),
                OutlinedButton(
                  onPressed: () => cycler.reset(),
                  child: Text("Reset"),
                  style: OutlinedButton.styleFrom(
                      primary: Colors.white, backgroundColor: Colors.red),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: program.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.all(2),
                    color: program[index]['isSelected'] == true
                        ? Colors.amber
                        : Colors.white,
                    child: ListTile(
                        dense: true,
                        leading: Checkbox(
                          activeColor: Colors.redAccent,
                          value: false,
                          onChanged: (value) => print("value changed"),
                        ),
                        title: Text(
                          program[index]['content'],
                          style: GoogleFonts.robotoMono(),
                        )),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
