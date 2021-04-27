import 'package:flutter/material.dart';
import 'package:picsim/main.dart';
import 'package:google_fonts/google_fonts.dart';

class SimScreen extends StatefulWidget {
  @override
  _SimScreenState createState() => _SimScreenState();
}

class _SimScreenState extends State<SimScreen> {
  int lastIndex = 0;
  String quartzFrequency = "4.000000";
  double runtimeDisplay = 0;

  Future<void> highlighter() async {
    do {
      setState(() {
        // line highlighting
        // c counts index
        var c = 0;
        var index = cycler.programCounter;
        for (var element in program) {
          if (element['index'] == index) {
            program[lastIndex]['isSelected'] = false;
            element['isSelected'] = true;
            lastIndex = c;
            // stop if there is a breakpoint
            if(element['isBreakpoint']) cycler.run = false;
            break;
          }
          c++;
        }
        stack = stack;
      });
      await Future.delayed(const Duration(milliseconds: 100));
    } while (cycler.run);
    return;
  }

  // shows dialog to change storage values
  createStorageDialog(BuildContext context, int index) {
    var txt = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(25),
            title: Text('Set value'),
            children: [
              Text("Set a hex/bin value"),
              TextField(
                controller: txt,
                autofocus: true,
                maxLength: 8,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  child: Text("OK"),
                  onPressed: () {
                    String input = "000000000" +
                        int.parse(txt.text, radix: 16).toRadixString(2);
                    if (txt.text.length == 2 &&
                            RegExp(r"[A-Fa-f0-9]{2}").hasMatch(txt.text) ||
                        txt.text.length == 1 &&
                            RegExp(r"[A-Fa-f0-9]{1}").hasMatch(txt.text)) {
                      setState(() {
                        storage.value[index] =
                            input.substring(input.length - 8);
                      });
                      Navigator.of(context).pop();
                    } else if (txt.text.length == 8 &&
                        RegExp(r"[0-1]{8}").hasMatch(txt.text)) {
                      setState(() {
                        storage.value[index] =
                            input.substring(input.length - 8);
                      });
                    } else {
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

  createQuartzDialog(BuildContext context, String dropdownValue) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(25),
            title: Text('Set quartz frequency'),
            children: [
              Text("Select a quartz frequency (MHz)"),
              Center(
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return DropdownButton<String>(
                    value: dropdownValue,
                    //icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    //elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    underline: Container(
                      height: 2,
                      color: Colors.black,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: <String>[
                      "0.032768",
                      "0.100000",
                      "0.455000",
                      "0.500000",
                      "1.000000",
                      "2.000000",
                      "2.457600",
                      "3.000000",
                      "3.276800",
                      "3.680000",
                      "3.686411",
                      "4.000000",
                      "4.096000",
                      "4.194304",
                      "4.433619",
                      "4.915200",
                      "5.000000",
                      "6.000000",
                      "6.144000",
                      "6.250000",
                      "6.553600",
                      "8.000000",
                      "10.00000",
                      "12.00000",
                      "16.00000",
                      "20.00000",
                      "24.00000",
                      "32.00000",
                      "40.00000",
                      "80.00000"
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  child: Text("OK"),
                  onPressed: () {
                    double temp = double.parse(dropdownValue);
                    setState(() {
                      runtimeDisplay =
                          runtimeDisplay + (runtime * cycleDuration);
                      runtime = 0;
                      quartzFrequency = dropdownValue;
                      cycleDuration = temp * (1 / (temp * temp)) * 4;
                    });
                    Navigator.of(context).pop();
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

  @override
  initState() {
    super.initState();
    cycler.resetRegisters(true);
  }

  @override
  Widget build(BuildContext context) {
    highlighter();
    return Scaffold(
      appBar: AppBar(
        title: Text("PicSim"),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
                                    createStorageDialog(
                                        context, index - row - 1);
                                  },
                                  child: Container(
                                    child: Center(
                                      child: Text(int.parse(
                                              storage.value[index - row - 1],
                                              radix: 2)
                                          .toRadixString(16)),
                                    ),
                                  ),
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
                                    name = storage.value[133 + register][bit] ==
                                            "1"
                                        ? "i"
                                        : "o";
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
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.5),
                        borderRadius: BorderRadius.circular(7.5)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ValueListenableBuilder(
                              valueListenable: wReg,
                              builder: (context, value, child) {
                                return InkWell(
                                  onTap: () => createStorageDialog(context, 4),
                                  child: Text("WReg: " +
                                      wReg.value +
                                      " (" +
                                      int.parse(wReg.value, radix: 2)
                                          .toRadixString(16) +
                                      ")"),
                                );
                              }),
                          ValueListenableBuilder(
                              valueListenable: storage,
                              builder: (context, value, child) {
                                return Column(
                                  children: [
                                    InkWell(
                                        onTap: () =>
                                            createStorageDialog(context, 4),
                                        child: Text("FSR: " +
                                            storage.value[4] +
                                            " (" +
                                            int.parse(storage.value[4],
                                                    radix: 2)
                                                .toRadixString(16) +
                                            ")")),
                                    InkWell(
                                        onTap: () =>
                                            createStorageDialog(context, 2),
                                        child: Text("PCL: " +
                                            storage.value[2] +
                                            " (" +
                                            int.parse(storage.value[2],
                                                    radix: 2)
                                                .toRadixString(16) +
                                            ")")),
                                    InkWell(
                                        onTap: () =>
                                            createStorageDialog(context, 10),
                                        child: Text("PCLATCH: " +
                                            storage.value[10] +
                                            " (" +
                                            int.parse(storage.value[10],
                                                    radix: 2)
                                                .toRadixString(16) +
                                            ")")),
                                    InkWell(
                                        onTap: () =>
                                            createStorageDialog(context, 3),
                                        child: Text("Status: " +
                                            storage.value[3] +
                                            " (" +
                                            int.parse(storage.value[3],
                                                    radix: 2)
                                                .toRadixString(16) +
                                            ")")),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: InkWell(
                                        onTap: () => createQuartzDialog(
                                            context, quartzFrequency),
                                        child: Text(
                                          "Quartz: " +
                                              quartzFrequency +
                                              " MHz (" +
                                              cycleDuration
                                                  .toStringAsPrecision(4) +
                                              " µs)",
                                        ),
                                      ),
                                    ),
                                    Text("Runtime: " +
                                        (runtimeDisplay +
                                                (cycleDuration * runtime))
                                            .toStringAsPrecision(3) +
                                        " µs"),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Tooltip(
                                          message: "Clear runtime counter",
                                          child: OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                runtimeDisplay = 0;
                                                runtime = 0;
                                              });
                                            },
                                            child: Text("Reset Runtime",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                )),
                                          )),
                                    ),
                                  ],
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  height: 200,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8),
                    itemCount: 48,
                    itemBuilder: (context, index) {
                      int row = index ~/ 8;
                      int bit = index % 8;
                      List statusReg = [
                        "IRP",
                        "RP1",
                        "RP0",
                        "TO",
                        "PD",
                        "Z",
                        "DC",
                        "C",
                        "RBP",
                        "IntEd",
                        "T0CS",
                        "T0SE",
                        "PSA",
                        "PS2",
                        "PS1",
                        "PS0",
                        "GIE",
                        "PIE",
                        "T0IE",
                        "INTE",
                        "RBIB",
                        "T01F",
                        "INTF",
                        "RBIF"
                      ];
                      if (row == 0 || row == 2 || row == 4) {
                        return Container(
                            child: Container(
                          color: Colors.amber,
                          alignment: Alignment.center,
                          child: Text(
                            statusReg[(row * 4) + (bit)],
                            style: TextStyle(fontSize: 11),
                          ),
                        ));
                      } else if (row == 1) {
                        return InkWell(
                          onTap: () => changeTrisBit(bit, 3),
                          child: Container(
                              alignment: Alignment.center,
                              child: Text(storage.value[3][bit])),
                        );
                      } else if (row == 3) {
                        return InkWell(
                          onTap: () => changeTrisBit(bit, 129),
                          child: Container(
                              alignment: Alignment.center,
                              child: Text(storage.value[129][bit])),
                        );
                      } else {
                        return InkWell(
                          onTap: () => changeTrisBit(bit, 11),
                          child: Container(
                              alignment: Alignment.center,
                              child: Text(storage.value[11][bit])),
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.5),
                        borderRadius: BorderRadius.circular(7.5)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("Stack",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          // stack[] can be null, thats why we have to check for null and escape it with a "0" instead
                          Text("0: " +
                              int.parse(stack[0].toString() == "null"
                                      ? "0"
                                      : stack[0].toString())
                                  .toRadixString(16)),
                          Text("1: " +
                              int.parse(stack[1].toString() == "null"
                                      ? "0"
                                      : stack[1].toString())
                                  .toRadixString(16)),
                          Text("2: " +
                              int.parse(stack[2].toString() == "null"
                                      ? "0"
                                      : stack[2].toString())
                                  .toRadixString(16)),
                          Text("3: " +
                              int.parse(stack[3].toString() == "null"
                                      ? "0"
                                      : stack[3].toString())
                                  .toRadixString(16)),
                          Text("4: " +
                              int.parse(stack[4].toString() == "null"
                                      ? "0"
                                      : stack[4].toString())
                                  .toRadixString(16)),
                          Text("5: " +
                              int.parse(stack[5].toString() == "null"
                                      ? "0"
                                      : stack[5].toString())
                                  .toRadixString(16)),
                          Text("6: " +
                              int.parse(stack[6].toString() == "null"
                                      ? "0"
                                      : stack[6].toString())
                                  .toRadixString(16)),
                          Text("7: " +
                              int.parse(stack[7].toString() == "null"
                                      ? "0"
                                      : stack[7].toString())
                                  .toRadixString(16)),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
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
                            if (cycler.run) {
                              cycler.pause();
                            } else {
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
                    child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return ListTile(
                          dense: true,
                          leading: Checkbox(
                            activeColor: Colors.redAccent,
                            value: program[index]['isBreakpoint'],
                            onChanged: (value) {
                              setState(() {
                                program[index]['isBreakpoint'] = !program[index]['isBreakpoint'];
                              });
                            },
                          ),
                          title: Text(
                            program[index]['content'],
                            style: GoogleFonts.robotoMono(),
                          ));
                    }),
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
