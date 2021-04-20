import 'package:flutter_test/flutter_test.dart';

import 'package:picsim/instructionRecognizer.dart';
import 'package:picsim/main.dart';


String hexToBin8(String hex) {
  String m = "000000000" + int.parse(hex, radix: 16).toRadixString(2);
  return m.substring(m.length-8);
}

String hexToBin14(String hex) {
  String m = "000000000000000" + int.parse(hex, radix: 16).toRadixString(2);
  return m.substring(m.length-14);
}

void main() {

  group("sublw", () {
    test("36h-11h", (){
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("11");
      int index = rec.sublw(0, hexToBin14("36"));
      expect(index , 1);
      expect(wReg.value, hexToBin8("25"));
      expect(storage.value[3].substring(5), "011");
    });
    test("05h-25h", (){
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("25");
      int index = rec.sublw(0, hexToBin14("05"));
      expect(index , 1);
      expect(wReg.value, hexToBin8("e0"));
      expect(storage.value[3].substring(5), "010");
    });
    test("11h-11h", (){
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("11");
      int index = rec.sublw(0, hexToBin14("11"));
      expect(index , 1);
      expect(wReg.value, hexToBin8("0"));
      expect(storage.value[3].substring(5), "111");
    });
    test("f1h-0h", (){
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("0");
      int index = rec.sublw(0, hexToBin14("f1"));
      expect(index , 1);
      expect(wReg.value, hexToBin8("f1"));
      expect(storage.value[3].substring(5), "000");
    });
    test("f1h-1h", (){
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("1");
      int index = rec.sublw(0, hexToBin14("f1"));
      expect(index , 1);
      expect(wReg.value, hexToBin8("f0"));
      expect(storage.value[3].substring(5), "011");
    });
    test("0h-1h", (){
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("1");
      int index = rec.sublw(0, hexToBin14("0"));
      expect(index , 1);
      expect(wReg.value, hexToBin8("ff"));
      expect(storage.value[3].substring(5), "000");
    });
    test("0h-f1h", (){
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("f1");
      int index = rec.sublw(0, hexToBin14("0"));
      expect(index , 1);
      expect(wReg.value, hexToBin8("0f"));
      expect(storage.value[3].substring(5), "000");
    });
    test("f0h-1h", (){
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("1");
      int index = rec.sublw(0, hexToBin14("f0"));
      expect(index , 1);
      expect(wReg.value, hexToBin8("ef"));
      expect(storage.value[3].substring(5), "001");
    });
  });

   test("rlf", () {
    final InstructionRecognizer rec = InstructionRecognizer();
    // C-Bit = 1 Register beginnt mit 1
    storage.value[26] = hexToBin8("80");
    storage.value[3] = rec.replaceCharAt(storage.value[3], rec.statustoBit("C"), "1");
    expect(rec.rlf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("01"));
    expect(storage.value[3][rec.statustoBit("C")], "1");

    // C-Bit = 0 Register beginnt mit 0
    storage.value[26] = hexToBin8("53");
    storage.value[3] = rec.replaceCharAt(storage.value[3], rec.statustoBit("C"), "0");
    expect(rec.rlf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("A6"));
    expect(storage.value[3][rec.statustoBit("C")], "0");

    // C-Bit = 0 Register beginnt mit 1
    storage.value[26] = hexToBin8("93");
    storage.value[3] = rec.replaceCharAt(storage.value[3], rec.statustoBit("C"), "0");
    expect(rec.rlf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("26"));
    expect(storage.value[3][rec.statustoBit("C")], "1");

    // C-Bit = 1 Register beginnt mit 0
    storage.value[26] = hexToBin8("53");
    storage.value[3] = rec.replaceCharAt(storage.value[3], rec.statustoBit("C"), "1");
    expect(rec.rlf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("A7"));
    expect(storage.value[3][rec.statustoBit("C")], "0");
  });

   test("clrw", () {
     final InstructionRecognizer rec = InstructionRecognizer();
     wReg.value = hexToBin8("FF");
     expect(rec.clrw(0, hexToBin14("00")), 1);
     expect(wReg.value, hexToBin8("00"));
     expect(storage.value[3][rec.statustoBit("Z")], "1");
  });

  test("clrf", () {
     final InstructionRecognizer rec = InstructionRecognizer();
     storage.value[26] = hexToBin8("FF");
     expect(rec.clrf(0, hexToBin14("9A")), 1);
     expect(storage.value[26], hexToBin8("00"));
     expect(storage.value[3][rec.statustoBit("Z")], "1");
  });
}