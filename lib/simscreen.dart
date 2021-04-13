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
    do {
      setState(() {
        // line highlighting
        // c counts index
        var c = 0;
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
    } while (cycler.run);
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
                      String input = "000000000" + int.parse(txt.text, radix: 16).toRadixString(2);
                      if (txt.text.length == 2 &&
                              RegExp(r"[A-Fa-f0-9]{2}").hasMatch(txt.text) ||
                          txt.text.length == 1 &&
                              RegExp(r"[A-Fa-f0-9]{1}").hasMatch(txt.text)) {
                        setState(() {
                          storage.value[index] = input.substring(input.length - 8);
                        });
                        Navigator.of(context).pop();
                      } else if (txt.text.length == 8 && RegExp(r"[0-1]{8}").hasMatch(txt.text)) {
                        setState(() {
                          storage.value[index] = input.substring(input.length - 8);
                        });
                      } 
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Not a hex/binary value!")));
                      }
                    },
                  ),
                ),
              ],
            );
          });
    }

    changeTrisBit(int bit, int index) {
      String temp = storage.value[index];
      switch (int.parse(temp[bit])) {
        case 0:
          temp = temp.substring(0, bit) + "1" + temp.substring(bit + 1);
          break;
        case 1:
          temp = temp.substring(0, bit) + "0" + temp.substring(bit + 1);
          break;
      }
      setState(() {
        storage.value[index] = temp;
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
                                            int.parse(storage.value[index - row - 1], radix: 2).toRadixString(16)),),),
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
                                  String temp = storage.value[register + 5];
                                  name = temp[bit];
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
              Column(
                children: [
                  ValueListenableBuilder(
                      valueListenable: wReg,
                      builder: (context, value, child) {
                        return Text("WReg: " + wReg.value);
                      }),
                  ValueListenableBuilder(
                      valueListenable: storage,
                      builder: (context, value, child) {
                        return Column(
                          children: [
                            Text("FSR: " + storage.value[4]),
                            Text("PCL: " + storage.value[2]),
                            Text("PCLATCH: " + storage.value[10]),
                            Text("Status: " + storage.value[3]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                    width: 10, height: 10, child: Text("IRP")),
                                Container(
                                    width: 10, height: 10, child: Text("RP0")),
                                Container(
                                    width: 10, height: 10, child: Text("RP1")),
                                Container(
                                    width: 10, height: 10, child: Text("IRP")),
                                Container(
                                    width: 10, height: 10, child: Text("RP0")),
                                Container(
                                    width: 10, height: 10, child: Text("RP1")),
                                Container(
                                    width: 10, height: 10, child: Text("IRP")),
                                Container(
                                    width: 10, height: 10, child: Text("RP0")),
                                Container(
                                    width: 10, height: 10, child: Text("RP1")),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(storage.value[3][0]),
                                Text(storage.value[3][1]),
                                Text(storage.value[3][2]),
                                Text(storage.value[3][3]),
                                Text(storage.value[3][4]),
                                Text(storage.value[3][5]),
                                Text(storage.value[3][6]),
                                Text(storage.value[3][7]),
                              ],
                            ),
                          ],
                        );
                      }),
                ],
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
                          onPressed: () {
                            cycler.step();
                            highlighter();
                          },
                          child: Text("Step")),
                      OutlinedButton(
                        onPressed: () {
                          cycler.reset();
                          highlighter();
                        },
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
