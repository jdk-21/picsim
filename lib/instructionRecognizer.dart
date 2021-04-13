import 'main.dart';

class InstructionRecognizer {
  int recognize(int index, String instruction) {
    //print(instruction);
    // RETURN
    if (instruction == "00000000001000") {
      return ret(index);
    }

    ///NOP
    else if (instruction.startsWith("0000000") &&
        instruction.endsWith("00000")) {
      return nop(index);
    }
    // ANDLW
    else if (instruction.startsWith("111001")) {
      return andlw(index, instruction);
    }
    // ADDWF
    else if (instruction.startsWith("000111")) {
      return addwf(index, instruction);
    }
    // ANDWF
    else if (instruction.startsWith("000101")) {
      return andwf(index, instruction);
    }
    // ADDLW
    else if (instruction.startsWith("11111")) {
      return addlw(index, instruction);
    }
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
    int sum = int.tryParse(((int.parse(instruction.substring(6), radix: 2))
            .toRadixString(10)))! +
        int.tryParse(((int.parse(wReg.value, radix: 2)).toRadixString(10)))!;
    String binSum = "00000000" + sum.toRadixString(2);
    // substring catches overflow
    wReg.value = binSum.substring(binSum.length - 8);
    return (++index);
  }

  int andlw(int index, String instruction) {
    print(index.toString() + " ANDLW");
    int sum = int.parse(instruction.substring(6), radix: 2) &
        int.parse(wReg.value, radix: 2);
    String binSum = "00000000" + sum.toRadixString(2);
    wReg.value = binSum.substring(binSum.length - 8);
    return ++index;
  }

  int addwf(int index, String instruction) {
    print(index.toString() + " ADDWF");
    int address = int.parse(instruction.substring(7), radix: 2);
    int sum = int.parse(storage.value[address], radix: 16) +
        int.parse(wReg.value, radix: 2);
    if (instruction[6] == "0") {
      String binSum = "00000000" + sum.toRadixString(2);
      wReg.value = binSum.substring(binSum.length - 8);
    } else {
      String hexSum = "00" + sum.toRadixString(16);
      storage.value[address] = hexSum.substring(hexSum.length - 2);
    }
    return ++index;
  }

  int andwf(int index, String instruction) {
    print(index.toString() + " ANDWF");
    int address = int.parse(instruction.substring(7), radix: 2);
    int sum = int.parse(storage.value[address], radix: 16) &
        int.parse(wReg.value, radix: 2);
    if (instruction[6] == "0") {
      String binSum = "00000000" + sum.toRadixString(2);
      wReg.value = binSum.substring(binSum.length - 8);
    } else {
      String hexSum = "00" + sum.toRadixString(16);
      storage.value[address] = hexSum.substring(hexSum.length - 2);
    }
    return ++index;
  }

  int bcf(int index, String instruction) {
    print(index.toString() + " BCF");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    int address = int.parse(instruction.substring(7), radix: 2);
    String d = "00000000" +
        int.parse(storage.value[address], radix: 16).toRadixString(2);
    String data = d.substring(d.length - 8);
    String result = int.parse(
            data.substring(0, bit) + "0" + data.substring(bit + 1),
            radix: 2)
        .toRadixString(16);
    storage.value[address] = result.substring(result.length - 2);
    return ++index;
  }

  int bsf(int index, String instruction) {
    print(index.toString() + " BSF");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    int address = int.parse(instruction.substring(7), radix: 2);
    String d = "00000000" +
        int.parse(storage.value[address], radix: 16).toRadixString(2);
    String data = d.substring(d.length - 8);
    String result = "00" +
        int.parse(data.substring(0, bit) + "1" + data.substring(bit + 1),
                radix: 2)
            .toRadixString(16);
    storage.value[address] = result.substring(result.length - 2);
    print(storage.value[address]);
    return ++index;
  }

  int btfsc(int index, String instruction) {
    print(index.toString() + " BTFSC");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    int address = int.parse(instruction.substring(7), radix: 2);
    if (int.parse(storage.value[address], radix: 16).toRadixString(2)[bit] ==
        "1") {
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
    if (int.parse(storage.value[address], radix: 16).toRadixString(2)[bit] ==
        "0") {
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
    String pclath = int.parse(storage.value[2], radix: 16).toRadixString(2);
    while (pclath.length < 8) {
      pclath = "0" + pclath;
    }
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
    String pclath =
        "00000000" + int.parse(storage.value[2], radix: 16).toRadixString(2);
    pclath = pclath.substring(pclath.length - 8);
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
}
