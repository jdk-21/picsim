import 'main.dart';

class InstructionRecognizer {
  void recognize(String instruction) {
    // ADDLW
    if (instruction.startsWith("11111")) {
      addlw(instruction);
    }
    // ANDLW
    else if (instruction.startsWith("111001")) {
      andlw(instruction);
    }
    // ADDWF
    else if (instruction.startsWith("000111")) {
      addwf(instruction);
    }
    // ANDWF
    else if (instruction.startsWith("000101")) {
      andwf(instruction);
    }
    // BCF
    else if (instruction.startsWith("0100")) {
      bcf(instruction);
    }
    // BSF
    else if (instruction.startsWith("0101")) {
      bsf(instruction);
    }
    // add new instruction with else if
  }

  void addlw(String instruction) {
    // convert to base 10 than back to hex and string
    int sum = int.tryParse(((int.parse(instruction.substring(6), radix: 2))
            .toRadixString(10)))! +
        int.tryParse(((int.parse(wReg, radix: 2)).toRadixString(10)))!;
    String binSum = "00000000" + sum.toRadixString(2);
    // substring catches overflow
    wReg = binSum.substring(binSum.length - 8);
  }

  void andlw(String instruction) {
    int sum = int.parse(instruction.substring(6), radix: 2) &
        int.parse(wReg, radix: 2);
    String binSum = "00000000" + sum.toRadixString(2);
    wReg = binSum.substring(binSum.length - 8);
  }

  void addwf(String instruction) {
    int address = int.parse(instruction.substring(7), radix: 2);
      int sum =
          int.parse(storage[address], radix: 16) + int.parse(wReg, radix: 2);
      if (instruction[6] == "0") {
        String binSum = "00000000" + sum.toRadixString(2);
        wReg = binSum.substring(binSum.length - 8);
      } else {
        String hexSum = "00" + sum.toRadixString(16);
        storage[address] = hexSum.substring(hexSum.length - 2);
      }
  }

  void andwf(String instruction) {
    int address = int.parse(instruction.substring(7), radix: 2);
      int sum =
          int.parse(storage[address], radix: 16) & int.parse(wReg, radix: 2);
      if (instruction[6] == "0") {
        String binSum = "00000000" + sum.toRadixString(2);
        wReg = binSum.substring(binSum.length - 8);
      } else {
        String hexSum = "00" + sum.toRadixString(16);
        storage[address] = hexSum.substring(hexSum.length - 2);
      }
  }

  void bcf(String instruction) {
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
      int address = int.parse(instruction.substring(7), radix: 2);
      String d =
          "00000000" + int.parse(storage[address], radix: 16).toRadixString(2);
      String data = d.substring(d.length - 8);
      String result = int.parse(
              data.substring(0, bit) + "0" + data.substring(bit + 1),
              radix: 2)
          .toRadixString(16);
      storage[address] = result.substring(result.length - 2);
  }

  void bsf(String instruction) {
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
      int address = int.parse(instruction.substring(7), radix: 2);
      storage[address] = "10";
      String d =
          "00000000" + int.parse(storage[address], radix: 16).toRadixString(2);
      String data = d.substring(d.length - 8);
      String result = "00" +
          int.parse(data.substring(0, bit) + "1" + data.substring(bit + 1),
                  radix: 2)
              .toRadixString(16);
      storage[address] = result.substring(result.length - 2);
      print(storage[address]);
  }
}
