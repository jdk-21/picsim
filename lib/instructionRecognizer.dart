import 'main.dart';

class InstructionRecognizer {
  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
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
        int.parse(wReg, radix: 2);
    String binSum = "00000000" + sum.toRadixString(2);
    // substring catches overflow
    binSum = binSum.substring(binSum.length - 8);
    wReg = binSum;
    print("Ergebnis: " + binSum.toString());
    return (++index);
  }

  int andlw(int index, String instruction) {
    print(index.toString() + " ANDLW");
    int sum = int.parse(instruction.substring(6), radix: 2) &
        int.parse(wReg, radix: 2);
    String binSum = "00000000" + sum.toRadixString(2);
    binSum = binSum.substring(binSum.length - 8);
    wReg = binSum;
    print("Ergebnis: " + binSum.toString());
    return ++index;
  }

  int addwf(int index, String instruction) {
    print(index.toString() + " ADDWF");
    int address = int.parse(instruction.substring(7), radix: 2);
    int sum =
        int.parse(storage.value[address], radix: 2) + int.parse(wReg, radix: 2);
    String binSum = "00000000" + sum.toRadixString(2);
    binSum = binSum.substring(binSum.length - 8);
    print("Ergebnis: " + binSum.toString());
    if (instruction[6] == "0") {
      wReg = binSum;
    } else {
      storage.value[address] = binSum;
    }
    return ++index;
  }

  int andwf(int index, String instruction) {
    print(index.toString() + " ANDWF");
    int address = int.parse(instruction.substring(7), radix: 2);
    int sum =
        int.parse(storage.value[address], radix: 2) & int.parse(wReg, radix: 2);
    String binSum = "00000000" + sum.toRadixString(2);
    binSum = binSum.substring(binSum.length - 8);
    print("Ergebnis: " + binSum.toString());
    if (instruction[6] == "0") {
      wReg = binSum;
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
    wReg = instruction.substring(6);
    return (++index);
  }

  int retlw(int index, String instruction) {
    print(index.toString() + " RETLW");
    wReg = "00" + instruction.substring(5);
    index = ret(index);
    return index;
  }

  int sublw(int index, String instruction) {
    print(index.toString() + " SUBLW");
    var zahl1 = int.parse(wReg, radix: 2);
    print("Zahl1: " + zahl1.toRadixString(2) + "   " + zahl1.toString());
    var zahl2 =
        int.parse(instruction.substring(instruction.length - 8), radix: 2);
    print("Zahl2: " + zahl2.toRadixString(2) + "   " + zahl2.toString());
    var sub = zahl1 - zahl2;
    print("Ergebnis int: " + sub.toString());
    String m = "";
    if (sub > 0) {
      // result is positive
      storage.value[3] = replaceCharAt(storage.value[2], 7, "1"); // C-Bit
      storage.value[3] = replaceCharAt(storage.value[2], 5, "0"); // Z-Bit
      m = "00000000" + sub.toRadixString(2);
    } else if (sub == 0) {
      // result is zero
      storage.value[3] = replaceCharAt(storage.value[2], 7, "1"); // C-Bit
      storage.value[3] = replaceCharAt(storage.value[2], 5, "1"); // Z-Bit
      m = "00000000";
    } else if (sub < 0) {
      // result is negative
      storage.value[3] = replaceCharAt(storage.value[2], 7, "0"); // C-Bit
      storage.value[3] = replaceCharAt(storage.value[2], 5, "0"); // Z-Bit
      sub = sub & 255; // invertieren
      m = "11111111" + sub.toRadixString(2); //2er Komplement bilden
      m = m.substring(m.length - 8);
    }
    m = m.substring(m.length - 8);
    print("Ergebnis: " + m + "   " + (int.parse(m, radix: 2)).toString());
    wReg = m;
    return (++index);
  }

  int iorlw(int index, String instruction) {
    print(index.toString() + " IORLW");
    int ins = int.parse(instruction.substring(instruction.length-8), radix: 2);
    int w = int.parse(wReg, radix: 2);
    int ret = w | ins; // Binary OR
    wReg = "00000000"+ ret.toRadixString(2);
    wReg = wReg.substring(wReg.length-8);
    storage.value[3] = replaceCharAt(storage.value[2], 5, "0"); // Z-Bit
    return (++index);
  }
}
