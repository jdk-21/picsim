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
  group("test jumps", () {
    test("9 calls 1 return", (){
      final InstructionRecognizer rec = InstructionRecognizer();
      expect(rec.call(0, hexToBin14("7ff")), int.parse("7ff", radix: 16));
      expect(stack[rec.stackPointer], 1);
      expect(rec.stackPointer, 1);
    });
  });
}



