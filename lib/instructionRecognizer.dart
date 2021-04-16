import 'main.dart';

class InstructionRecognizer {
  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  int statustoBit(String ch) {
    ch = ch.toUpperCase();
    switch (ch) {
      case "IRP":
        return 0;
      case "RP1":
        return 1;
      case "RP0":
        return 2;
      case "TO":
        return 3;
      case "Z":
        return 4;
      case "IRP":
        return 5;
      case "DC":
        return 6;
      case "C":
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
    return ++index;
  }

  int addwf(int index, String instruction) {
    print(index.toString() + " ADDWF");
    int address = int.parse(instruction.substring(7), radix: 2);
    int sum =
        int.parse(storage.value[address], radix: 2) + int.parse(wReg.value, radix: 2);
    String binSum = "00000000" + sum.toRadixString(2);
    binSum = binSum.substring(binSum.length - 8);
    print("Ergebnis: " + binSum.toString());
    if (instruction[6] == "0") {
      wReg.value = binSum;
    } else {
      storage.value[address] = binSum;
    }
    return ++index;
  }

  int andwf(int index, String instruction) {
    print(index.toString() + " ANDWF");
    int address = int.parse(instruction.substring(7), radix: 2);
    int sum =
        int.parse(storage.value[address], radix: 2) & int.parse(wReg.value, radix: 2);
    String binSum = "00000000" + sum.toRadixString(2);
    binSum = binSum.substring(binSum.length - 8);
    print("Ergebnis: " + binSum.toString());
    if (instruction[6] == "0") {
      wReg.value = binSum;
    } else {
      storage.value[address] = binSum;
    }
    return ++index;
  }

  int bcf(int index, String instruction) {
    print(index.toString() + " BCF");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    int address = int.parse(instruction.substring(7), radix: 2);
    String data = storage.value[address];
    storage.value[address] = replaceCharAt(data, bit, "0");
    print("Ergebnis: " + storage.value[address].toString());
    return ++index;
  }

  int bsf(int index, String instruction) {
    print(index.toString() + " BSF");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    int address = int.parse(instruction.substring(7), radix: 2);
    String data = storage.value[address];
    storage.value[address] = replaceCharAt(data, bit, "1");
    print("Ergebnis: " + storage.value[address].toString());
    return ++index;
  }

  int btfsc(int index, String instruction) {
    print(index.toString() + " BTFSC");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    int address = int.parse(instruction.substring(7), radix: 2);
    if (storage.value[address][bit] == "1") {
      //next instruction if bit b at register f is 1
      return ++index;
    } else {
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
      return ++index;
    } else {
      print(index + 2);
      return (index + 2); //the next instruction is skiped when bit is a 1
    }
  }

  int call(int index, String instruction) {
    print(index.toString() + " CALL");
    stack.push(++index); //index+1 auf Stack (return adresse)
    String pclath = storage.value[2];
    int address = int.parse((pclath.substring(3, 5) + instruction.substring(3)),
        radix: 2);
    return address;
  }

  int ret(int index) {
    print(index.toString() + " RETURN");
    if (stack.isNotEmpty) {
      index = stack.top();
      stack.pop();
    } else {
      ++index;
    }
    return index;
  }

  int goto(int index, String instruction) {
    print(index.toString() + " GOTO");
    String pclath = storage.value[10];
    int address = int.parse((pclath.substring(3, 5) + instruction.substring(3)),
        radix: 2);
    return address;
  }

  int nop(int index) {
    print(index.toString() + " NOP");
    return (++index);
  }

  int movlw(int index, String instruction) {
    print(index.toString() + " MOVLW");
    wReg.value = instruction.substring(6);
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
    // TODO: C und DC Bit nicht korrekt gesetzt
    print(index.toString() + " SUBLW");
    var zahl1 = int.parse(wReg.value, radix: 2);
    print("Zahl1: " + zahl1.toRadixString(2) + "   " + zahl1.toString());
    var zahl2 =
        int.parse(instruction.substring(instruction.length - 8), radix: 2);
    print("Zahl2: " + zahl2.toRadixString(2) + "   " + zahl2.toString());
    var sub = zahl2 - zahl1;
    print("Ergebnis int: " + sub.toString());
    String m = "";
    String out = "";
    if ((sub > 16) || (sub < -16) || (sub == 0)) {
      // Overflow der ersten 4 Bit
      setStatusBit("DC");
      out = "DC-Bit: 1 ";
    } else {
      clearStatusBit("DC");
      out = "DC-Bit: 0 ";
    }
    if (sub > 0) {
      // result is positive
      setStatusBit("C"); // C-Bit
      clearStatusBit("Z"); // Z-Bit
      m = "00000000" + sub.toRadixString(2);
      out += "C-Bit: 1 Z-Bit: 0";
    } else if (sub == 0) {
      // result is zero
      setStatusBit("C"); // C-Bit
      setStatusBit("Z"); // Z-Bit
      m = "00000000";
      out += ("C-Bit: 1 Z-Bit: 1");
    } else if (sub < 0) {
      // result is negative
      clearStatusBit("C"); // C-Bit
      clearStatusBit("Z"); // Z-Bit
      sub = (sub & 255); // invertieren
      m = "11111111" + sub.toRadixString(2); //2er Komplement bilden
      m = m.substring(m.length - 8);
      out += ("C-Bit: 0 Z-Bit: 0");
    }
    print(out);
    m = m.substring(m.length - 8);
    print("Ergebnis: " + m + "   " + (int.parse(m, radix: 2)).toString());
    wReg.value = m;
    return (++index);
  }

  int iorlw(int index, String instruction) {
    print(index.toString() + " IORLW");
    int ins = int.parse(instruction.substring(instruction.length-8), radix: 2);
    int w = int.parse(wReg.value, radix: 2);
    int ret = w | ins; // Binary OR
    wReg.value = "00000000"+ ret.toRadixString(2);
    wReg.value = wReg.value.substring(wReg.value.length-8);
    storage.value[3] = replaceCharAt(storage.value[2], 5, "0"); // Z-Bit
    print("wReg: " +
        wReg.value +
        " Int: " +
        ret.toString() +
        " Hex: " +
        ret.toRadixString(16) +
        "   zBit: 0");
    return (++index);
  }

  int xorlw(int index, String instruction) {
    // 1 Word 1 Cycle
    print(index.toString() + " IORLW");
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
    return (++index);
  }
}
