
import 'package:picsim/instructionRecognizer.dart';
import 'main.dart';

class InstructionCycler {
  InstructionRecognizer recognizer = InstructionRecognizer();
  int programCounter = 0;
  var programStorage = [];
  bool run = false;

  void start() async {
    print("started");
    run = true;
    while (run) {
      programCounter =
          recognizer.recognize(programCounter, programStorage[programCounter]);
      storage.notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
      
    }
    
  }

  void pause() {
    run = false;
    print("stopped");
  }

  void reset() {
    run = false;
    programCounter = 0;
    print("reset");
  }

  void step() {
    if (!run) {
      programCounter = recognizer.recognize(programCounter, programStorage[programCounter]);
      print ("step");
    }
  }
}
