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
        print(cycler.programCounter);
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
    setState(() {
      program[lastIndex]['isSelected'] = false;
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    // shows dialog to change the storage
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

    changeTrisBit(int bit, int index) {
      String temp = "00000000" +
          int.parse(storage.value[index], radix: 16).toRadixString(2);
      temp = temp.substring(temp.length - 8);
      switch (int.parse(temp[bit])) {
        case 0:
          temp = temp.substring(0, bit) + "1" + temp.substring(bit + 1);
          break;
        case 1:
          temp = temp.substring(0, bit) + "0" + temp.substring(bit + 1);
          break;
      }
      temp = "00" + int.parse(temp, radix: 2).toRadixString(16);
      setState(() {
        storage.value[index] = temp.substring(temp.length - 2);
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
                          itemCount: 135,
                          itemBuilder: (context, index) {
                            // row calculates the current row
                            var row = index ~/ 9;
                            var register = row ~/ 3;
                            var bit = index % 9 - 1;
                            // checks if this is a line start
                            String name = "";
                            if (index % 9 == 0) {
                              switch (row % 3) {
                                case 0:
                                  switch (register) {
                                    case 0:
                                      name = "RA";
                                      break;
                                    case 1:
                                      name = "RB";
                                      break;
                                    case 2:
                                      name = "RC";
                                      break;
                                    case 3:
                                      name = "RD";
                                      break;
                                    case 4:
                                      name = "RE";
                                      break;
                                  }
                                  break;
                                case 1:
                                  name = "Tris";
                                  break;

                                case 2:
                                  name = "Pin";
                                  break;
                              }

                              return Container(
                                color: Colors.amber,
                                child: Center(child: Text(name)),
                              );
                            } else {
                              switch (row % 3) {
                                case 0:
                                  name = (7 - bit).toString();
                                  break;
                                case 1:
                                  name = (7 - bit).toString();
                                  break;
                                case 2:
                                  String temp = "00000000" +
                                      int.parse(storage.value[register + 5],
                                              radix: 16)
                                          .toRadixString(2);
                                  name = temp.substring(temp.length - 8)[bit];
                                  return InkWell(
                                    onTap: () {
                                      changeTrisBit(bit, register + 5);
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey,
                                                  width: 2)),
                                          color: Colors.blue[100],
                                        ),
                                        child: Center(child: Text(name))),
                                  );
                              }
                              return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                  ),
                                  child: Center(child: Text(name)));
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 2,
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
                              primary: Colors.white,
                              backgroundColor: Colors.green)),
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
                Column(
                  children: [
                    Text(
                      "Quartz: " + "4,000000" + " MHz (" + "1.000" + " µs)",
                    ),
                    Row(
                      children: [
                        Text("Runtime: " + "00:13" + " µs"),
                        Tooltip(
                            message: "Clear runtime counter",
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.clear,
                                size: 15,
                              ),
                              color: Colors.red[600],
                              hoverColor: Colors.transparent,
                            )),
                      ],
                    ),
                  ],
                ),
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
