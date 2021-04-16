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
      print("start: programCounter " + programCounter.toString());
      print("wReg: " + wReg.value.toString());
      print("instruction: " +
          int.parse(programStorage[programCounter], radix: 2)
              .toRadixString(16));
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      storage.notifyListeners();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void pause() {
    run = false;
    print("stopped");
  }

  void reset() {
    run = false;
    programCounter = 0;
    wReg.value = "00000000";
    print("reset");
  }

  void step() {
    if (!run) {
      programCounter =
          recognizer.recognize(programCounter, programStorage[programCounter]);
      print("step: programCounter " + programCounter.toString());
      print("wReg: " +
          wReg.value.toString() +
          "  " +
          int.parse(wReg.value, radix: 2).toRadixString(16));
      print("instruction: " + int.parse(programStorage[programCounter], radix: 2).toRadixString(16));
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      storage.notifyListeners();
    }
  }
}
