import 'package:flutter_test/flutter_test.dart';

import 'package:picsim/instructionRecognizer.dart';
import 'package:picsim/main.dart';

String hexToBin8(String hex) {
  String m = "000000000" + int.parse(hex, radix: 16).toRadixString(2);
  return m.substring(m.length - 8);
}

String hexToBin14(String hex) {
  String m = "000000000000000" + int.parse(hex, radix: 16).toRadixString(2);
  return m.substring(m.length - 14);
}

void main() {
  group("sublw", () {
    test("36h-11h", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("11");
      int index = rec.sublw(0, hexToBin14("36"));
      expect(index, 1);
      expect(wReg.value, hexToBin8("25"));
      expect(storage.value[3].substring(5), "011");
    });
    test("05h-25h", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("25");
      int index = rec.sublw(0, hexToBin14("05"));
      expect(index, 1);
      expect(wReg.value, hexToBin8("e0"));
      expect(storage.value[3].substring(5), "010");
    });
    test("11h-11h", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("11");
      int index = rec.sublw(0, hexToBin14("11"));
      expect(index, 1);
      expect(wReg.value, hexToBin8("0"));
      expect(storage.value[3].substring(5), "111");
    });
    test("f1h-0h", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("0");
      int index = rec.sublw(0, hexToBin14("f1"));
      expect(index, 1);
      expect(wReg.value, hexToBin8("f1"));
      expect(storage.value[3].substring(5), "000");
    });
    test("f1h-1h", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("1");
      int index = rec.sublw(0, hexToBin14("f1"));
      expect(index, 1);
      expect(wReg.value, hexToBin8("f0"));
      expect(storage.value[3].substring(5), "011");
    });
    test("0h-1h", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("1");
      int index = rec.sublw(0, hexToBin14("0"));
      expect(index, 1);
      expect(wReg.value, hexToBin8("ff"));
      expect(storage.value[3].substring(5), "000");
    });
    test("0h-f1h", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("f1");
      int index = rec.sublw(0, hexToBin14("0"));
      expect(index, 1);
      expect(wReg.value, hexToBin8("0f"));
      expect(storage.value[3].substring(5), "000");
    });
    test("f0h-1h", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      wReg.value = hexToBin8("1");
      int index = rec.sublw(0, hexToBin14("f0"));
      expect(index, 1);
      expect(wReg.value, hexToBin8("ef"));
      expect(storage.value[3].substring(5), "001");
    });
  });

  test("rlf", () {
    final InstructionRecognizer rec = InstructionRecognizer();
    // C-Bit = 1 Register beginnt mit 1
    storage.value[26] = hexToBin8("80");
    storage.value[3] =
        rec.replaceCharAt(storage.value[3], rec.statustoBit("C"), "1");
    expect(rec.rlf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("01"));
    expect(storage.value[3][rec.statustoBit("C")], "1");

    // C-Bit = 0 Register beginnt mit 0
    storage.value[26] = hexToBin8("53");
    storage.value[3] =
        rec.replaceCharAt(storage.value[3], rec.statustoBit("C"), "0");
    expect(rec.rlf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("A6"));
    expect(storage.value[3][rec.statustoBit("C")], "0");

    // C-Bit = 0 Register beginnt mit 1
    storage.value[26] = hexToBin8("93");
    storage.value[3] =
        rec.replaceCharAt(storage.value[3], rec.statustoBit("C"), "0");
    expect(rec.rlf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("26"));
    expect(storage.value[3][rec.statustoBit("C")], "1");

    // C-Bit = 1 Register beginnt mit 0
    storage.value[26] = hexToBin8("53");
    storage.value[3] =
        rec.replaceCharAt(storage.value[3], rec.statustoBit("C"), "1");
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

  test("incf", () {
    final InstructionRecognizer rec = InstructionRecognizer();
    int test = 0;
    List input = [
      // Storage, Instruction, storage out, wReg out, Z-Bit out
      ["00", "9A", "01", "00", "0"], // Reg: 0 d-Bit: 1
      ["01", "9A", "02", "00", "0"], // Reg: 1 d-Bit: 1
      ["FF", "9A", "00", "00", "1"], // Reg: 255 d-Bit: 1
      ["00", "1A", "00", "01", "0"], // Reg: 0 d-Bit: 0
      ["01", "1A", "01", "02", "0"], // Reg: 1 d-Bit: 0
      ["FF", "1A", "FF", "00", "1"] // Reg: 255 d-Bit: 0
    ];

    input.forEach((element) {
      test++;
      print("Test: " + test.toString());
      wReg.value = hexToBin8("00");
      storage.value[26] = hexToBin8(element[0]);
      expect(rec.incf(0, hexToBin14(element[1])), 1);
      expect(storage.value[26], hexToBin8(element[2]));
      expect(wReg.value, hexToBin8(element[3]));
      expect(storage.value[3][rec.statustoBit("Z")], element[4]);
    });
  });

  test("incfsz", () {
    final InstructionRecognizer rec = InstructionRecognizer();
    int test = 0;
    List input = [
      ["02", "9A", 1], // d-Bit 1 Reg: 2
      ["01", "1A", 2] // d-Bit 0 Reg: 1
    ];
    input.forEach((element) {
      test++;
      print("Test: " + test.toString());
      wReg.value = hexToBin8("00");
      storage.value[26] = hexToBin8(element[0]);
      expect(rec.decfsz(0, hexToBin14(element[1])), element[2]);
    });
  });

  test("movwf", () {
    final InstructionRecognizer rec = InstructionRecognizer();
    storage.value[26] = hexToBin8("FF");
    wReg.value = hexToBin8("AA");
    expect(rec.movwf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("AA"));
    expect(wReg.value, hexToBin8("AA"));
  });

  test("rrf", () {
    final InstructionRecognizer rec = InstructionRecognizer();
    // C-Bit = 1 Register endet mit 0
    storage.value[26] = hexToBin8("80");
    storage.value[3] =
        rec.replaceCharAt(storage.value[3], rec.statustoBit("C"), "1");
    expect(rec.rrf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("C0"));
    expect(storage.value[3][rec.statustoBit("C")], "0");
    // C-Bit = 0 Register endet mit 1
    storage.value[26] = hexToBin8("53");
    storage.value[3] =
        rec.replaceCharAt(storage.value[3], rec.statustoBit("C"), "0");
    expect(rec.rrf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("29"));
    expect(storage.value[3][rec.statustoBit("C")], "1");
    // C-Bit = 1 Register endet mit 1
    storage.value[26] = hexToBin8("93");
    storage.value[3] =
        rec.replaceCharAt(storage.value[3], rec.statustoBit("C"), "1");
    expect(rec.rrf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("C9"));
    expect(storage.value[3][rec.statustoBit("C")], "1");
    // C-Bit = 0 Register endet mit 0
    storage.value[26] = hexToBin8("D2");
    storage.value[3] =
        rec.replaceCharAt(storage.value[3], rec.statustoBit("C"), "0");
    expect(rec.rrf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("69"));
    expect(storage.value[3][rec.statustoBit("C")], "0");
    // C-Bit = 0 Register endet mit 1 (wReg)
    storage.value[26] = hexToBin8("53");
    storage.value[3] =
        rec.replaceCharAt(storage.value[3], rec.statustoBit("C"), "0");
    expect(rec.rrf(0, hexToBin14("1A")), 1);
    expect(wReg.value, hexToBin8("29"));
    expect(storage.value[3][rec.statustoBit("C")], "1");
  });

  test("movf", () {
    final InstructionRecognizer rec = InstructionRecognizer();
    // D-Bit 1 Reg FF
    storage.value[26] = hexToBin8("FF");
    expect(rec.movf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("FF"));
    expect(storage.value[3][rec.statustoBit("Z")], "0");
    // D-Bit 0 Reg FF
    storage.value[26] = hexToBin8("FF");
    wReg.value = hexToBin8("A5");
    expect(rec.movf(0, hexToBin14("1A")), 1);
    expect(wReg.value, hexToBin8("FF"));
    expect(storage.value[26], hexToBin8("FF"));
    expect(storage.value[3][rec.statustoBit("Z")], "0");
    // D-Bit 1 Reg 00
    storage.value[26] = hexToBin8("00");
    expect(rec.movf(0, hexToBin14("9A")), 1);
    expect(storage.value[26], hexToBin8("00"));
    expect(storage.value[3][rec.statustoBit("Z")], "1");
    // D-Bit 0 Reg 00
    storage.value[26] = hexToBin8("00");
    wReg.value = hexToBin8("A5");
    expect(rec.movf(0, hexToBin14("1A")), 1);
    expect(wReg.value, hexToBin8("00"));
    expect(storage.value[26], hexToBin8("00"));
    expect(storage.value[3][rec.statustoBit("Z")], "1");
  });

  test("decf", () {
    final InstructionRecognizer rec = InstructionRecognizer();
    int test = 0;
    List input = [
      ["02", "9A", "01", "00", "0"], // d-Bit 1 Reg: 2
      ["01", "9A", "00", "00", "1"], // d-Bit 1 Reg: 1
      ["00", "9A", "FF", "00", "0"], // d-Bit 1 Reg: 0
      ["02", "1A", "02", "01", "0"], // d-Bit 0 Reg: 2
      ["01", "1A", "01", "00", "1"] // d-Bit 0 Reg: 1
    ];

    input.forEach((element) {
      test++;
      print("Test: " + test.toString());
      wReg.value = hexToBin8("00");
      storage.value[26] = hexToBin8(element[0]);
      expect(rec.decf(0, hexToBin14(element[1])), 1);
      expect(storage.value[26], hexToBin8(element[2]));
      expect(wReg.value, hexToBin8(element[3]));
      expect(storage.value[3][rec.statustoBit("Z")], element[4]);
    });
  });

  test("decfsz", () {
    final InstructionRecognizer rec = InstructionRecognizer();
    int test = 0;
    List input = [
      ["02", "9A", 1], // d-Bit 1 Reg: 2
      ["01", "1A", 2] // d-Bit 0 Reg: 1
    ];
    input.forEach((element) {
      test++;
      print("Test: " + test.toString());
      wReg.value = hexToBin8("00");
      storage.value[26] = hexToBin8(element[0]);
      expect(rec.decfsz(0, hexToBin14(element[1])), element[2]);
    });
  });

  test("subwf", () {
    final InstructionRecognizer rec = InstructionRecognizer();
    int test = 0;
    List input = [
      // wReg, Storage, Instruction, wReg out, Storage out
      ["04", "01", "9A", "01", "03"], // d-Bit 1 Reg: 2 --> Storage
      ["04", "01", "1A", "03", "04"] // d-Bit 0 Reg: 2 --> wReg
    ];
    input.forEach((element) {
      test++;
      print("Test: " + test.toString());
      storage.value[26] = hexToBin8(element[0]);
      wReg.value = hexToBin8(element[1]);
      expect(rec.subwf(0, hexToBin14(element[2])), 1);
      expect(wReg.value, hexToBin8(element[3]));
      expect(storage.value[26], hexToBin8(element[4]));
    });
  });

  test("indirekte Adressierung", () {
    final InstructionRecognizer rec = InstructionRecognizer();
    storage.value[26] = hexToBin8("FF");
    storage.value[4] = hexToBin8("1A"); // FSR Register
    expect(rec.clrf(0, hexToBin14("00")), 1); // 0 als Adresse
    expect(storage.value[26], hexToBin8("00"));
    expect(storage.value[3][rec.statustoBit("Z")], "1");
  });
}
