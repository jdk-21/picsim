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
  group("SUBLW", () {
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
  test('BCF', () {
    final InstructionRecognizer rec = InstructionRecognizer();
    List input = [
      ["80", "1a"],
      ["40", "9a"],
      ["20", "11a"],
      ["10", "19a"],
      ["8", "21a"],
      ["4", "29a"],
      ["2", "31a"],
      ["1", "39a"],
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
      ["7f", "1a"],
      ["bf", "9a"],
      ["df", "11a"],
      ["ef", "19a"],
      ["f7", "21a"],
      ["fb", "29a"],
      ["fd", "31a"],
      ["fe", "39a"],
    ];

    input.forEach((i) {
      storage.value[26] = hexToBin8(i[0]);
      expect(rec.bsf(0, hexToBin14(i[1])), 1);
      expect(storage.value[26], "11111111");
    });
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
}
