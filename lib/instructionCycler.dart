import 'package:picsim/instructionRecognizer.dart';
import 'main.dart';

class InstructionCycler {
  InstructionRecognizer recognizer = InstructionRecognizer();
  int programCounter = 0;
  var programStorage = [];
  bool run = false;

  void resetRegisters(bool poReset) {
    // if poReset is true set all Power-on Reset bits
    // reset registers
    storage.value[2] = "00000000"; //PCL
    storage.value[3] = poReset
        ? "00011" + storage.value[10].substring(5)
        : "000" + storage.value[10].substring(3); //Status
    storage.value[10] = "00000000"; //PCLatch
    storage.value[11] = "0000000" + storage.value[11][7]; //INTCON
    storage.value[129] = "11111111"; //Option
    storage.value[133] =
        "00011111"; //TrisA first three digits undefined -> read as 0
    storage.value[134] = "11111111"; //TrisB
    storage.value[138] = "00000000"; //PCLATH
    storage.value[139] = "0000000" + storage.value[139][7]; //INTCON
    if (poReset) {
      stack.forEach((element) {
        element = "00000000000000";
      });
    }
    recognizer.stackPointer = 0;
  }

  void programm() {
    programCounter =
        recognizer.recognize(programCounter, programStorage[programCounter]);
    print("wReg: " + wReg.value.toString()+" Hex: " + int.parse(wReg.value, radix: 2).toRadixString(16));   
    String dc = storage.value[3][recognizer.statustoBit("DC")];
    String c = storage.value[3][recognizer.statustoBit("C")];
    String z = storage.value[3][recognizer.statustoBit("Z")];
    print("DC= "+dc+" C= "+c+" Z= "+z);
    print("---");
  }

  void start() async {
    print("started");
    run = true;
    while (run) {
      print("start: PC " + programCounter.toString());
      programm();

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
    resetRegisters(true);
    print("reset");
  }

  void step() {
    if (!run) {
      print("step: PC " + programCounter.toString());
      programm();

      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      storage.notifyListeners();
    }
  }
}
