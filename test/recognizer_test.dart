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

  test("indirekte Adressierung", () {
    final InstructionRecognizer rec = InstructionRecognizer();
    storage.value[26] = hexToBin8("FF");
    storage.value[4] = hexToBin8("1A"); // FSR Register
    expect(rec.clrf(0, hexToBin14("80")), 1); // 0 als Adresse
    expect(storage.value[26], hexToBin8("00"));
    expect(storage.value[4], hexToBin8("1A"));
    expect(storage.value[3][rec.statustoBit("Z")], "1");
  });

  group("test jumps", () {
    test("9x call 2x return", () {
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

    test("CALL with PCLATH", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      storage.value[10] = "00001000";
      expect(rec.call(0, hexToBin14("1")), 2049);
    });

    test("GOTO with PCLATH", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      storage.value[10] = "00001000";
      expect(rec.goto(0, hexToBin14("12")), 2066);
    });

    test('RETLW', () {
      final InstructionRecognizer rec = InstructionRecognizer();
      runtime = 0;
      rec.stackPointer = 0;
      storage.value[10] = hexToBin8("0");
      expect(rec.call(0, hexToBin14("7f")), int.parse("7f", radix: 16));
      expect(runtime, 2);
      expect(rec.retlw(20, hexToBin14("ff")), 1);
      expect(wReg.value, hexToBin8("ff"));
      expect(runtime, 4);
    });

    test('BTFSC', () {
      final InstructionRecognizer rec = InstructionRecognizer();
      List input = ["1a", "9a", "11a", "19a", "21a", "29a", "31a", "39a"];

      input.forEach((i) {
        runtime = 0;
        storage.value[26] = hexToBin8("ff");
        expect(rec.btfsc(0, hexToBin14(i)), 1);
        expect(runtime, 1);
        storage.value[26] = hexToBin8("0");
        expect(rec.btfsc(0, hexToBin14(i)), 2);
        expect(runtime, 3);
      });
    });

    test('BTFSS', () {
      final InstructionRecognizer rec = InstructionRecognizer();
      List input = ["1a", "9a", "11a", "19a", "21a", "29a", "31a", "39a"];

      input.forEach((i) {
        runtime = 0;
        storage.value[26] = hexToBin8("0");
        expect(rec.btfss(0, hexToBin14(i)), 1);
        expect(runtime, 1);
        storage.value[26] = hexToBin8("ff");
        expect(rec.btfss(0, hexToBin14(i)), 2);
        expect(runtime, 3);
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

    // TODO addwf, incf ... with PCL
  });

  test("ANDLW", () {
    final InstructionRecognizer rec = InstructionRecognizer();
    wReg.value = hexToBin8("ff");
    rec.andlw(0, hexToBin14("0"));
    expect(wReg.value, hexToBin8("0"));
    expect(storage.value[3][5], "1");
    wReg.value = hexToBin8("aa");
    rec.andlw(0, hexToBin14("aa"));
    expect(wReg.value, hexToBin8("aa"));
    expect(storage.value[3][5], "0");
    wReg.value = hexToBin8("a");
    rec.andlw(0, hexToBin14("a1"));
    expect(wReg.value, hexToBin8("0"));
    expect(storage.value[3][5], "1");
  });

  group('WF', () {
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

    test("iorwf", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      int test = 0;
      List input = [
        // wReg, Storage, Instruction, wReg out, Storage out
        ["0f", "f0", "9A", "f0", "ff"], // d-Bit 1 Reg: 2 --> Storage
        ["0f", "f0", "1A", "ff", "0f"] // d-Bit 0 Reg: 2 --> wReg
      ];
      input.forEach((element) {
        test++;
        print("Test: " + test.toString());
        storage.value[26] = hexToBin8(element[0]);
        wReg.value = hexToBin8(element[1]);
        expect(rec.iorwf(0, hexToBin14(element[2])), 1);
        expect(wReg.value, hexToBin8(element[3]));
        expect(storage.value[26], hexToBin8(element[4]));
      });
    });

    test("xorwf", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      int test = 0;
      List input = [
        // Storage, wReg, Instruction, wReg out, Storage out
        ["ab", "ef", "9A", "ef", "44"], // d-Bit 1 Reg: 2 --> Storage
        ["ab", "ef", "1A", "44", "ab"] // d-Bit 0 Reg: 2 --> wReg
      ];
      input.forEach((element) {
        test++;
        print("Test: " + test.toString());
        storage.value[26] = hexToBin8(element[0]);
        wReg.value = hexToBin8(element[1]);
        expect(rec.xorwf(0, hexToBin14(element[2])), 1);
        expect(wReg.value, hexToBin8(element[3]));
        expect(storage.value[26], hexToBin8(element[4]));
      });
    });

    group('ANDWF', () {
      test("ANDWF with destination = 0", () {
        final InstructionRecognizer rec = InstructionRecognizer();
        wReg.value = hexToBin8("ff");
        storage.value[26] = hexToBin8("0");
        expect(rec.andwf(0, hexToBin14("1A")), 1);
        expect(wReg.value, hexToBin8("0"));
        expect(storage.value[3][5], "1");
        wReg.value = hexToBin8("aa");
        storage.value[26] = hexToBin8("aa");
        rec.andwf(0, hexToBin14("1A"));
        expect(wReg.value, hexToBin8("aa"));
        expect(storage.value[3][5], "0");
        wReg.value = hexToBin8("a");
        storage.value[26] = hexToBin8("A1");
        rec.andwf(0, hexToBin14("1A"));
        expect(wReg.value, hexToBin8("0"));
        expect(storage.value[3][5], "1");
      });

      test("ANDWF with destination = 1", () {
        final InstructionRecognizer rec = InstructionRecognizer();
        wReg.value = hexToBin8("ff");
        storage.value[26] = hexToBin8("0");
        rec.andwf(0, hexToBin14("9A"));
        expect(storage.value[26], hexToBin8("0"));
        expect(storage.value[3][5], "1");
        wReg.value = hexToBin8("aa");
        storage.value[26] = hexToBin8("aa");
        rec.andwf(0, hexToBin14("9A"));
        expect(storage.value[26], hexToBin8("aa"));
        expect(storage.value[3][5], "0");
        wReg.value = hexToBin8("a");
        storage.value[26] = hexToBin8("A1");
        rec.andwf(0, hexToBin14("9A"));
        expect(storage.value[26], hexToBin8("0"));
        expect(storage.value[3][5], "1");
      });
    });

    test("movwf", () {
      final InstructionRecognizer rec = InstructionRecognizer();
      runtime = 0;
      storage.value[26] = hexToBin8("FF");
      wReg.value = hexToBin8("AA");
      expect(rec.movwf(0, hexToBin14("9A")), 1);
      expect(storage.value[26], hexToBin8("AA"));
      expect(wReg.value, hexToBin8("AA"));
      expect(runtime, 1);
    });

    group('ADDWF', () {
      test('ADDWF with destination = 0', () {
        final InstructionRecognizer rec = InstructionRecognizer();
        List input = [
          //[wReg, storage, result, status]
          ["7f", "0", "7f", "000"],
          ["7f", "82", "01", "011"],
          ["7f", "a0", "1f", "001"],
          ["7f", "81", "0", "111"],
          ["f", "1", "10", "010"],
          ["0", "0", "0", "100"]
        ];
        input.forEach((i) {
          wReg.value = hexToBin8(i[0]);
          storage.value[26] = hexToBin8(i[1]);
          expect(rec.addwf(0, hexToBin14("1a")), 1);
          expect(wReg.value, hexToBin8(i[2]));
          expect(storage.value[3].substring(5), i[3]);
        });
      });

      test('ADDWF with destination = 1', () {
        final InstructionRecognizer rec = InstructionRecognizer();
        List input = [
          //[wReg, storage, result, status]
          ["7f", "0", "7f", "000"],
          ["7f", "82", "01", "011"],
          ["7f", "a0", "1f", "001"],
          ["7f", "81", "0", "111"],
          ["f", "1", "10", "010"],
          ["0", "0", "0", "100"]
        ];
        input.forEach((i) {
          wReg.value = hexToBin8(i[0]);
          storage.value[26] = hexToBin8(i[1]);
          rec.addwf(0, hexToBin14("9A"));
          expect(storage.value[26], hexToBin8(i[2]));
          expect(storage.value[3].substring(5), i[3]);
        });
      });
    });
  });

  group('ADDLW', () {
    final InstructionRecognizer rec = InstructionRecognizer();
    test('ffh+1h', () {
      wReg.value = hexToBin8("ff");
      expect(rec.addlw(0, hexToBin14("1")), 1);
      expect(wReg.value, hexToBin8("0"));
      expect(storage.value[3].substring(5), "111");
    });
    test('e0h+1h', () {
      wReg.value = hexToBin8("e0");
      expect(rec.addlw(0, hexToBin14("1")), 1);
      expect(wReg.value, hexToBin8("e1"));
      expect(storage.value[3].substring(5), "000");
    });
    test('1fh+1h', () {
      wReg.value = hexToBin8("1f");
      expect(rec.addlw(0, hexToBin14("1")), 1);
      expect(wReg.value, hexToBin8("20"));
      expect(storage.value[3].substring(5), "010");
    });
    test('f0h+f2h', () {
      wReg.value = hexToBin8("f0");
      expect(rec.addlw(0, hexToBin14("f2")), 1);
      expect(wReg.value, hexToBin8("e2"));
      expect(storage.value[3].substring(5), "001");
    });
  });

  test('BCF', () {
    final InstructionRecognizer rec = InstructionRecognizer();
    List input = [
      ["1", "1a"],
      ["2", "9a"],
      ["4", "11a"],
      ["8", "19a"],
      ["10", "21a"],
      ["20", "29a"],
      ["40", "31a"],
      ["80", "39a"],
    ];

    input.forEach((i) {
      storage.value[26] = hexToBin8(i[0]);
      expect(rec.bcf(0, hexToBin14(i[1])), 1);
      expect(storage.value[26], hexToBin8("0"));
    });
  });

  test('BSF', () {
    final InstructionRecognizer rec = InstructionRecognizer();
    List input = [
      ["fe", "1a"],
      ["fd", "9a"],
      ["fb", "11a"],
      ["f7", "19a"],
      ["ef", "21a"],
      ["df", "29a"],
      ["bf", "31a"],
      ["7f", "39a"],
    ];

    input.forEach((i) {
      storage.value[26] = hexToBin8(i[0]);
      expect(rec.bsf(0, hexToBin14(i[1])), 1);
      expect(storage.value[26], "11111111");
    });
  });

  test('MOVLW', () {
    final InstructionRecognizer rec = InstructionRecognizer();
    List input = ["0", "12", "ff"];

    input.forEach((i) {
      runtime = 0;
      expect(rec.movlw(0, hexToBin14(i)), 1);
      expect(wReg.value, hexToBin8(i));
      expect(runtime, 1);
    });
  });

  test('IORLW', () {
    final InstructionRecognizer rec = InstructionRecognizer();
    List input = [
      ["0", "0", "0", "1"],
      ["0", "1", "1", "0"],
      ["ff", "0", "ff", "0"],
      ["ff", "ff", "ff", "0"],
      ["f0", "0f", "ff", "0"],
      ["a0", "a0", "a0", "0"],
      ["a7", "a0", "a7", "0"],
    ];

    input.forEach((i) {
      runtime = 0;
      wReg.value = hexToBin8(i[0]);
      expect(rec.iorlw(0, hexToBin14(i[1])), 1);
      expect(wReg.value, hexToBin8(i[2]));
      expect(storage.value[3][5], i[3]);
      expect(runtime, 1);
    });
  });

  test('XORLW', () {
    final InstructionRecognizer rec = InstructionRecognizer();
    List input = [
      ["0", "0", "0", "1"],
      ["10", "10", "0", "1"],
      ["11", "1", "10", "0"],
      ["11", "0", "11", "0"],
      ["f0", "0f", "ff", "0"],
      ["ef", "ab", "44", "0"],
    ];

    input.forEach((i) {
      runtime = 0;
      wReg.value = hexToBin8(i[0]);
      expect(rec.xorlw(0, hexToBin14(i[1])), 1);
      expect(wReg.value, hexToBin8(i[2]));
      expect(storage.value[3][5], i[3]);
      expect(runtime, 1);
    });
  });

  test('COMF', () {
    final InstructionRecognizer rec = InstructionRecognizer();
    int test = 0;
    List input = [
      // W, S, I, Wo, So, Z
      ["F0", "F0", "9A", "F0", "0F", "0"], // F0 --> 0F d:1 S
      ["00", "00", "9A", "00", "FF", "0"], // 00 --> FF d:1 S
      ["00", "FF", "1A", "00", "FF", "1"], // FF --> 00 d:0 W
      ["00", "00", "1A", "FF", "00", "0"] // 00 --> FF d:0 W
    ];

    input.forEach((i) {
      test++;
      print("Test: " + test.toString());
      runtime = 0;
      wReg.value = hexToBin8(i[0]);
      storage.value[26] = hexToBin8(i[1]);
      expect(rec.comf(0, hexToBin14(i[2])), 1);
      expect(wReg.value, hexToBin8(i[3]));
      expect(storage.value[26], hexToBin8(i[4]));
      expect(storage.value[3][rec.statustoBit("Z")], i[5]);
      expect(runtime, 1);
    });
  });

  test('SWAPF', () {
    final InstructionRecognizer rec = InstructionRecognizer();
    int test = 0;
    runtime = 0;
    List input = [
      // 0W, 1S, 2I, 3Wo, 4So
      ["BB", "0F", "9A", "BB", "F0"], // 0F --> F0 d:1 S
      ["BB", "A3", "9A", "BB", "3A"], // A3 --> 3A d:1 S
      ["BB", "0F", "1A", "F0", "0F"], // 0F --> F0 d:0 W
      ["BB", "A3", "1A", "3A", "A3"] // A3 --> 3A d:0 W
    ];

    input.forEach((i) {
      test++;
      print("Test: " + test.toString());
      runtime = 0;
      wReg.value = hexToBin8(i[0]);
      storage.value[26] = hexToBin8(i[1]);
      expect(rec.swapf(0, hexToBin14(i[2])), 1);
      expect(wReg.value, hexToBin8(i[3]));
      expect(storage.value[26], hexToBin8(i[4]));
      expect(runtime, 1);
    });
  });

  test('RETFIE', () {
    final InstructionRecognizer rec = InstructionRecognizer();
    runtime = 0;
    rec.stackPointer = 1;
    storage.value[10] = hexToBin8("0"); //PCL
    stack[0] = 15;
    expect(rec.retfie(25), 15);
    expect(storage.value[11][0], "1"); // GIE Bit
    expect(runtime, 2);

    runtime = 0;
    rec.stackPointer = 1;
    storage.value[10] = hexToBin8("0"); //PCL
    stack[0] = 15;
    storage.value[3] =
        rec.replaceCharAt(storage.value[3], rec.statustoBit("RP0"), "1");
    expect(rec.retfie(25), 15);
    expect(storage.value[139][0], "1"); // GIE Bit
    expect(runtime, 2);

    storage.value[3] =
        rec.replaceCharAt(storage.value[3], rec.statustoBit("RP0"), "0"); //RP0
    storage.value[11] =
        rec.replaceCharAt(storage.value[11], 0, "0"); // GIE Bank 0
    storage.value[139] =
        rec.replaceCharAt(storage.value[139], 0, "0"); //GIE Bank 1
  });

  test('CLRWDT', () {
    final InstructionRecognizer rec = InstructionRecognizer();
    runtime = 0;
    rec.stackPointer = 1;
    storage.value[1] = hexToBin8("AB"); //TMR0
    storage.value[129] = rec.replaceCharAt(storage.value[129], 4, "1");
    expect(rec.clrwdt(0), 1); //PC
    expect(storage.value[129], hexToBin8("00")); //TMR0
    expect(storage.value[129][4], "0"); // PSA Bit
    expect(storage.value[3][rec.statustoBit("TO")], "1"); //TO Bit
    expect(storage.value[3][rec.statustoBit("PD")], "1"); //PD Bit
    expect(runtime, 1); // Cycles
  });

  test('RETLW', () {
    final InstructionRecognizer rec = InstructionRecognizer();
    runtime = 0;
    rec.stackPointer = 1;
    stack[0] = 15;
    wReg.value = hexToBin8("CC");

    expect(rec.retlw(0, hexToBin14("1A")), 15); //PC
    expect(wReg.value, hexToBin8("1A")); //TMR0
    expect(runtime, 2); // Cycles
  });
}
