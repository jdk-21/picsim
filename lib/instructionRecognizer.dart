import 'main.dart';

class InstructionRecognizer {
  void recognize(String instruction) {
    if (instruction.startsWith("11111")) {
      // convert to base 10 than back to hex and string
      int sum  = int.tryParse(
              ((int.parse(instruction.substring(6, 14), radix: 2))
                  .toRadixString(10)))! + int.tryParse(
              ((int.parse(wReg, radix: 2))
                  .toRadixString(10)))!;
      String binSum = "00000000" + sum.toRadixString(2);
      // substring catches overflow
      wReg= binSum.substring(binSum.length-8);
    }
    // add new instruction with else if
  }
}
