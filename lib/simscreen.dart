import 'package:flutter/material.dart';
import 'package:picsim/main.dart';

class SimScreen extends StatefulWidget {
  @override
  _SimScreenState createState() => _SimScreenState();
}

class _SimScreenState extends State<SimScreen> {
  

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
                      if (cycler.run) cycler.pause();
                      else cycler.start();
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
          Container(
            height: 500,
            child: ListView.builder(
              itemCount: cycler.programStorage.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Checkbox(
                    activeColor: Colors.redAccent,
                    value: false,
                    onChanged: (value) => print("value changed"),
                  ),
                  title: Text(cycler.programStorage[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
