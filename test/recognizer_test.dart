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
    test("9x call 2x return", (){
      final InstructionRecognizer rec = InstructionRecognizer();
      expect(rec.call(0, hexToBin14("7ff")), int.parse("7ff", radix: 16));
      expect(stack[0], 1);
      expect(rec.stackPointer, 1);
      int i = rec.call(1, hexToBin14("7fe"));
      i = rec.call(1, hexToBin14("7fd"));
      i = rec.call(2, hexToBin14("7fc"));
      i = rec.call(3, hexToBin14("7fb"));
      i = rec.call(4, hexToBin14("7fa"));
      i = rec.call(5, hexToBin14("7f9"));
      i = rec.call(6, hexToBin14("7f8"));
      i = rec.call(7, hexToBin14("7f7"));
      expect(rec.stackPointer, 1);
      expect(i, int.parse("7f7", radix: 16));
      expect(rec.ret(0), 8);
      expect(rec.stackPointer, 0);
      expect(rec.ret(0), 7);
      expect(rec.stackPointer, 7);
    });
    test("Call with PCLATH", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      storage.value[10] = "00001000";
      expect(rec.call(0, hexToBin14("1")), 2049);
    });

    test("GOTO with PCLATH", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      storage.value[10] = "00001000";
      expect(rec.goto(0, hexToBin14("12")), 2066);
    });

    // TODO addwf, incf ... with PCL
  });
  test("andlw", (){
    final InstructionRecognizer rec  = InstructionRecognizer();
    wReg.value=hexToBin8("ff");
    rec.andlw(0, hexToBin8("0"));
    expect(wReg.value, hexToBin8("0"));
    expect(storage.value[3][5], "1");
    
  });
  test("", () {

  });
}



