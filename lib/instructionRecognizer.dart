import 'main.dart';

class InstructionRecognizer {
  int stackPointer = 0;

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  int complement(int stellen, int number) {
    String i = normalize(stellen, number);
    i = i.replaceAll("1", "a");
    i = i.replaceAll("0", "1");
    i = i.replaceAll("a", "0");
    return int.parse(i, radix: 2);
  }

  int statustoBit(String ch) {
    ch = ch.toUpperCase();
    switch (ch) {
      case "IRP": // Register Bank Select
        return 0;
      case "RP1": // Register Bank Select
        return 1;
      case "RP0": // Register Bank Select
        return 2;
      case "TO": // Time-out
        return 3;
      case "PD": // Power-down
        return 4;
      case "Z": // Zero bit
        return 5;
      case "DC": // Digit carry
        return 6;
      case "C": //
        return 7;
      default:
        return 8;
    }
  }

  void clearStatusBit(String ch) {
    int bit = statustoBit(ch);
    if (bit < 8) {
      storage.value[3] = replaceCharAt(storage.value[3], bit, "0");
    } else {
      print("Wrong StatusBit");
    }
  }

  void clearFlags() {
    clearStatusBit("C"); // C-Bit
    clearStatusBit("Z"); // Z-Bit
    clearStatusBit("DC"); // DC-Bit
  }

  void setStatusBit(String ch) {
    int bit = statustoBit(ch);
    if (bit < 8) {
      storage.value[3] = replaceCharAt(storage.value[3], bit, "1");
    } else {
      print("Wrong StatusBit");
    }
  }

  String normalize(int stellen, int number) {
    print("Normelize: " + number.toRadixString(2));
    String m = "";
    for (int i = 0; i < stellen; i++) {
      m += "0";
    }
    m += number.toRadixString(2);
    print(m);
    m = m.substring(m.length - stellen);
    print(m);
    return m;
  }

  int recognize(int index, String instruction) {
    //print(instruction);
    // 14-Stellen
    // RETURN
    if (instruction == "00000000001000") {
      return ret(index);
    }
    // 12-Stellen
    // NOP
    else if (instruction.startsWith("0000000") &&
        instruction.endsWith("00000")) {
      return nop(index);
    }
    // 6-Stellen
    // ANDLW
    else if (instruction.startsWith("111001")) {
      return andlw(index, instruction);
    }
    // XORLW
    else if (instruction.startsWith("111010")) {
      return xorlw(index, instruction);
    }
    // IORLW
    else if (instruction.startsWith("111000")) {
      return iorlw(index, instruction);
    }
    // ADDWF
    else if (instruction.startsWith("000111")) {
      return addwf(index, instruction);
    }
    // ANDWF
    else if (instruction.startsWith("000101")) {
      return andwf(index, instruction);
    }
    //5-Stellen
    // ADDLW
    else if (instruction.startsWith("11111")) {
      return addlw(index, instruction);
    }
    // SUBLW
    else if (instruction.startsWith("11110")) {
      return sublw(index, instruction);
    }
    // 4-Stellen
    // RETLW
    else if (instruction.startsWith("1101")) {
      return retlw(index, instruction);
    }
    // MOVLW
    else if (instruction.startsWith("1100")) {
      return movlw(index, instruction);
    }
    // BTFSC
    else if (instruction.startsWith("0110")) {
      return btfsc(index, instruction);
    }
    // BTFSS
    else if (instruction.startsWith("0111")) {
      return btfss(index, instruction);
    }
    // BSF
    else if (instruction.startsWith("0101")) {
      return bsf(index, instruction);
    }
    // BCF
    else if (instruction.startsWith("0100")) {
      return bcf(index, instruction);
    }
    // 3-Stellen
    // GOTO
    else if (instruction.startsWith("101")) {
      return goto(index, instruction);
    }
    // CALL
    else if (instruction.startsWith("100")) {
      return call(index, instruction);
    }
    print("No hit: " + instruction);
    return 0;
    // add new instruction with else if
  }

  int addlw(int index, String instruction) {
    print(index.toString() + " ADDLW");
    // convert to base 10 than back to hex and string
    int sum = int.parse(instruction.substring(6), radix: 2) +
        int.parse(wReg.value, radix: 2);
    String binSum = "00000000" + sum.toRadixString(2);
    // substring catches overflow
    binSum = binSum.substring(binSum.length - 8);
    wReg.value = binSum;
    print("Ergebnis: " + binSum.toString());
    //TODO: Z,C,DC-Flag
    ++runtime;
    return (++index);
  }

  int andlw(int index, String instruction) {
    print(index.toString() + " ANDLW");
    int sum = int.parse(instruction.substring(6), radix: 2) &
        int.parse(wReg.value, radix: 2);
    String binSum = "00000000" + sum.toRadixString(2);
    binSum = binSum.substring(binSum.length - 8);
    wReg.value = binSum;
    print("Ergebnis: " + binSum.toString());
    ++runtime;
    return ++index;
  }

  int addwf(int index, String instruction) {
    print(index.toString() + " ADDWF");
    int address = int.parse(instruction.substring(7), radix: 2);
    int sum = int.parse(storage.value[address], radix: 2) +
        int.parse(wReg.value, radix: 2);
    String binSum = "00000000" + sum.toRadixString(2);
    binSum = binSum.substring(binSum.length - 8);
    print("Ergebnis: " + binSum.toString());
    if (instruction[6] == "0") {
      wReg.value = binSum;
    } else {
      storage.value[address] = binSum;
    }
    ++runtime;
    return ++index;
  }

  int andwf(int index, String instruction) {
    print(index.toString() + " ANDWF");
    int address = int.parse(instruction.substring(7), radix: 2);
    int sum = int.parse(storage.value[address], radix: 2) &
        int.parse(wReg.value, radix: 2);
    String binSum = "00000000" + sum.toRadixString(2);
    binSum = binSum.substring(binSum.length - 8);
    print("Ergebnis: " + binSum.toString());
    if (instruction[6] == "0") {
      wReg.value = binSum;
    } else {
      storage.value[address] = binSum;
    }
    ++runtime;
    return ++index;
  }

  int bcf(int index, String instruction) {
    print(index.toString() + " BCF");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    int address = int.parse(instruction.substring(7), radix: 2);
    String data = storage.value[address];
    storage.value[address] = replaceCharAt(data, bit, "0");
    print("Ergebnis: " + storage.value[address].toString());
    ++runtime;
    return ++index;
  }

  int bsf(int index, String instruction) {
    print(index.toString() + " BSF");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    int address = int.parse(instruction.substring(7), radix: 2);
    String data = storage.value[address];
    storage.value[address] = replaceCharAt(data, bit, "1");
    print("Ergebnis: " + storage.value[address].toString());
    ++runtime;
    return ++index;
  }

  int btfsc(int index, String instruction) {
    print(index.toString() + " BTFSC");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    int address = int.parse(instruction.substring(7), radix: 2);
    if (storage.value[address][bit] == "1") {
      //next instruction if bit b at register f is 1
      ++runtime;
      return ++index;
    } else {
      runtime = runtime + 2;
      return (index + 2); //the next instruction is skiped when bit is a 0
    }
  }

  int btfss(int index, String instruction) {
    print(index.toString() + " BTFSS");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    int address = int.parse(instruction.substring(7), radix: 2);
    if (storage.value[address][bit] == "0") {
      //next instruction if bit b at register f is 0
      print(index + 1);
      ++runtime;
      return ++index;
    } else {
      print(index + 2);
      runtime += 2;
      return (index + 2); //the next instruction is skiped when bit is a 1
    }
  }

  int call(int index, String instruction) {
    print(index.toString() + " CALL");

    stack[stackPointer] = index + 1; //index+1 auf Stack (return adresse)
    stackPointer++;
    if (stackPointer > 7) stackPointer = 0;

    String pclath = storage.value[10];
    int address = int.parse((pclath.substring(3, 5) + instruction.substring(3)),
        radix: 2);
    runtime += 2;
    return address;
  }

  int ret(int index) {
    print(index.toString() + " RETURN");
    --stackPointer;
    if (stackPointer < 0) stackPointer = 7;
    var temp = stack[stackPointer];
    temp == null ? index++ : index = temp;

    stack[stackPointer] = null;
    runtime += 2;
    return index;
  }

  int goto(int index, String instruction) {
    print(index.toString() + " GOTO");
    String pclath = storage.value[10];
    int address = int.parse((pclath.substring(3, 5) + instruction.substring(3)),
        radix: 2);
    runtime += 2;
    return address;
  }

  int nop(int index) {
    print(index.toString() + " NOP");
    ++runtime;
    return (++index);
  }

  int movlw(int index, String instruction) {
    print(index.toString() + " MOVLW");
    wReg.value = instruction.substring(6);
    ++runtime;
    return (++index);
  }

  int retlw(int index, String instruction) {
    print(index.toString() + " RETLW");
    wReg.value = "00" + instruction.substring(5);
    index = ret(index);
    return index;
  }

  int sublw(int index, String instruction) {
    // 1 Word 1 Cycle
    // TODO: DC Bit nicht korrekt gesetzt Z DC C
    print(index.toString() + " SUBLW");
    String out = "";
    var zahl1 =
        int.parse(instruction.substring(instruction.length - 8), radix: 2);
    print("Zahl 1: " + zahl1.toRadixString(2) + "   " + zahl1.toString());
    var zahl2 = int.parse(wReg.value, radix: 2);
    print("Zahl 2: " + zahl2.toRadixString(2) + "   " + zahl2.toString());

    int komplement =
        int.parse(normalize(8, complement(8, zahl2) + 1), radix: 2);
    print("Komplement: " + komplement.toRadixString(2));
    int komplement4 =
        int.parse(normalize(4, complement(4, zahl2) + 1), radix: 2);
    /*String komplement = komplement.toRadixString(2);
    String komplementBin4 = komplement4.toRadixString(2);

    if (komplementBin8.length > 8) {
      // if zahl2=0 resolve overflow
      komplement =
          int.parse(komplementBin8.substring(komplementBin8.length - 8));
      komplementBin8 = normalize8(int.parse(komplementBin8, radix: 2));
    }
    if (komplementBin4.length > 4) {
      // if zahl2=0 resolve overflow
      komplement4 =
          int.parse(komplementBin4.substring(komplementBin4.length - 4));
      komplementBin4 = normalize4(int.parse(komplementBin4, radix: 2));
    }*/
    var sub = zahl1 + komplement;
    var sub4 =
        int.parse(instruction.substring(instruction.length - 4), radix: 2) +
            komplement4;
    var subBin = sub.toRadixString(2);
    var subBin4 = sub4.toRadixString(2);
    if (sub == 0 || sub == 256) {
      setStatusBit("Z");
      out += "Z-Bit: 1  ";
    } else {
      clearStatusBit("Z");
      out += "Z-Bit: 0  ";
    }

    if (subBin4.length > 4) {
      setStatusBit("DC");
      out += "DC-Bit: 1  ";
    } else {
      clearStatusBit("DC");
      out += "DC-Bit: 0  ";
    }

    if (subBin.length > 8) {
      setStatusBit("C");
      out += "C-Bit: 1  ";
    } else {
      out += "C-Bit: 0  ";
      clearStatusBit("C");
    }
    var m = "00000000" + sub.toRadixString(2);
    wReg.value = m.substring(m.length - 8);
    print("Ergebnis: " +
        wReg.value +
        "   " +
        sub.toRadixString(16) +
        "   " +
        sub.toString());
    print(out);

    ++runtime;
    return (++index);
  }

  int iorlw(int index, String instruction) {
    print(index.toString() + " IORLW");
    int ins =
        int.parse(instruction.substring(instruction.length - 8), radix: 2);
    int w = int.parse(wReg.value, radix: 2);
    int ret = w | ins; // Binary OR
    wReg.value = "00000000" + ret.toRadixString(2);
    wReg.value = wReg.value.substring(wReg.value.length - 8);
    storage.value[3] = replaceCharAt(storage.value[2], 5, "0"); // Z-Bit
    print("wReg: " +
        wReg.value +
        " Int: " +
        ret.toString() +
        " Hex: " +
        ret.toRadixString(16) +
        "   zBit: 0");
    ++runtime;
    return (++index);
  }

  int xorlw(int index, String instruction) {
    // 1 Word 1 Cycle
    print(index.toString() + " XORLW");
    int ins =
        int.parse(instruction.substring(instruction.length - 8), radix: 2);
    int w = int.parse(wReg.value, radix: 2);
    int ret = w ^ ins; // Binary XOR
    wReg.value = "00000000" + ret.toRadixString(2);
    wReg.value = wReg.value.substring(wReg.value.length - 8);
    print("wReg: " +
        wReg.value +
        " Int: " +
        ret.toString() +
        " Hex: " +
        ret.toRadixString(16));
    ++runtime;
    return (++index);
  }
}
