import 'package:flutter/material.dart';
import 'package:picsim/main.dart';
import 'package:google_fonts/google_fonts.dart';

class SimScreen extends StatefulWidget {
  @override
  _SimScreenState createState() => _SimScreenState();
}

class _SimScreenState extends State<SimScreen> {
  var lastIndex = 0;

  Future<void> highlighter() async {
    while (cycler.run) {
      setState(() {
        // line highlighting
        // c counts index
        var c = 0;
        print(program.length);
        for (var element in program) {
          print(element);
          if (element['index'] == cycler.programCounter) {
            program[lastIndex]['isSelected'] = false;
            element['isSelected'] = true;
            lastIndex = c;
            break;
          }
          c++;
        }

        // show changes in storage
      });
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    createStorageDialog(BuildContext context, int index) {
      var txt = TextEditingController();

      return showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              contentPadding: EdgeInsets.all(25),
              title: Text('Set value'),
              children: [
                Text("Set a hex value"),
                TextField(
                  controller: txt,
                  autofocus: true,
                  maxLength: 2,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    child: Text("OK"),
                    onPressed: () {
                      if (txt.text.length == 2 &&
                              RegExp(r"[A-Fa-f0-9]{2}").hasMatch(txt.text) ||
                          txt.text.length == 1 &&
                              RegExp(r"[A-Fa-f0-9]{1}").hasMatch(txt.text)) {
                        String a = "00" + txt.text;
                        setState(() {
                          storage.value[index] = a.substring(a.length - 2);
                        });
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Not an hex value!")));
                      }
                    },
                  ),
                ),
              ],
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("PicSim"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  width: 300,
                  height: 200,
                  child: ValueListenableBuilder(
                    valueListenable: storage,
                    builder: (context, value, child) {
                      return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 9),
                          itemCount: 288,
                          itemBuilder: (context, index) {
                            // row calculates the current row
                            var row = index ~/ 9;
                            // checks if this is a line start
                            if (index % 9 == 0) {
                              return Container(
                                color: Colors.amber,
                                child: Center(
                                    child: Text(
                                        "0x" + (row * 8).toRadixString(16))),
                              );
                            } else {
                              return InkWell(
                                onTap: () {
                                  print("hello");
                                  createStorageDialog(context, index - row - 1);
                                },
                                child: Container(
                                    child: Center(
                                        child: Text(
                                            storage.value[index - row - 1]))),
                              );
                            }
                          });
                    },
                  ),
                ),
              ),
            ],
          ),
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
                        highlighter();
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
