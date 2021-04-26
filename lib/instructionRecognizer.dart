import 'main.dart';

class InstructionRecognizer {
  int stackPointer = 0;

  String binToHex(String s) {
    return int.parse(s, radix: 2).toRadixString(16);
  }

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  int changedPCL(int index, int address, String result) {
    if (address == 2 && result != storage.value[address]) {
      return int.parse(storage.value[10] + storage.value[2], radix: 2) + 1;
    } else
      return ++index;
  }

  int complement(int stellen, int number) {
    String i = normalize(stellen, number);
    i = i.replaceAll("1", "a");
    i = i.replaceAll("0", "1");
    i = i.replaceAll("a", "0");
    return int.parse(i, radix: 2);
  }

  int statustoBit(String ch) {
    // Umrechnen des StatusBit-Namen in das dazugehörige Bit
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
    //setzt das Bit auf 0
    int bit = statustoBit(ch);
    if (bit < 8) {
      storage.value[3] = replaceCharAt(storage.value[3], bit, "0");
    } else {
      print("Wrong StatusBit");
    }
  }

  void setStatusBit(String ch) {
    //setze das Bit auf 1
    int bit = statustoBit(ch);
    if (bit < 8) {
      storage.value[3] = replaceCharAt(storage.value[3], bit, "1");
    } else {
      print("Wrong StatusBit");
    }
  }

  String normalize(int stellen, int number) {
    // transformiere ine Zahl in ein n-Stellen langen Binary-String
    String m = "";
    for (int i = 0; i <= stellen; i++) {
      m += "0";
    }
    m += number.toRadixString(2);
    m = m.substring(m.length - stellen);
    return m;
  }

  String setZDcCBit(int ergebnis, int ergebnis4) {
    String out = "";
    if (ergebnis == 0 || ergebnis == 256) {
      setStatusBit("Z");
      out += "Z-Bit: 1  ";
    } else {
      clearStatusBit("Z");
      out += "Z-Bit: 0  ";
    }
    if (ergebnis4.toRadixString(2).length > 4) {
      setStatusBit("DC");
      out += "DC-Bit: 1  ";
    } else {
      clearStatusBit("DC");
      out += "DC-Bit: 0  ";
    }
    if (ergebnis.toRadixString(2).length > 8) {
      setStatusBit("C");
      out += "C-Bit: 1  ";
    } else {
      out += "C-Bit: 0  ";
      clearStatusBit("C");
    }
    return out;
  }

  int catchAddress(String instruction) {
    //Filtere die Adresse aus der instruction und beachte die indirekte Adressierung.
    int address =
        int.parse(instruction.substring(instruction.length - 7), radix: 2);
    if (storage.value[3][statustoBit("RP0")] == "1") {
      address = address + 128; //Umschalten auf Bank 1
    }
    if (address == 0) {
      // FSR Register verwenden
      return int.parse(storage.value[4], radix: 2);
    } else {
      return address;
    }
  }

  void wf(int address, String oldwReg, String instruction) {
    //Ergebnis steht im wReg. Speichere es im Storage wenn d-Bit = 1 und überschreibe den wReg mit dem old Wert
    if (instruction[6] == "1") {
      print("d-Bit: 1");
      storage.value[address] = wReg.value;
      wReg.value = oldwReg;
    } else {
      print("d-Bit: 0");
    }
  }

  void f(int address, String res, String instruction) {
    // Speichere das Ergebnis je nach d-Bit im wReg oder Storage.
    res = normalize(8, int.parse(res, radix: 2));
    if (instruction[6] == "0") {
      wReg.value = res;
    } else {
      storage.value[address] = res;
    }
  }

  int recognize(int index, String instruction) {
    // Analysieren der Instruction nach Logest-Pattern-Match
    // 14-Stellen #################################################
    // CLRWDT
    if (instruction == "00000001100100") {
      return clrwdt(index);
    }
    // RETFIE
    if (instruction == "00000000001001") {
      return retfie(index);
    }
    // RETURN
    if (instruction == "00000000001000") {
      return ret(index);
    }
    // 12-Stellen #################################################
    // NOP
    else if (instruction.startsWith("0000000") &&
        instruction.endsWith("00000")) {
      return nop(index);
    }
    // 7-Stellen #################################################
    // CLRF
    else if (instruction.startsWith("0000011")) {
      return clrf(index, instruction);
    }
    // CLRW
    else if (instruction.startsWith("0000010")) {
      return clrw(index, instruction);
    }
    // MOVWF
    else if (instruction.startsWith("0000001")) {
      return movwf(index, instruction);
    }
    // 6-Stellen #################################################
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
    // INCFSZ
    else if (instruction.startsWith("001111")) {
      return incfsz(index, instruction);
    }
    // SWAPF
    else if (instruction.startsWith("001110")) {
      return swapf(index, instruction);
    }
    // RRF
    else if (instruction.startsWith("001100")) {
      return rrf(index, instruction);
    }
    // DECFSZ
    else if (instruction.startsWith("001011")) {
      return decfsz(index, instruction);
    }
    // INCF
    else if (instruction.startsWith("001010")) {
      return incf(index, instruction);
    }
    // COMF
    else if (instruction.startsWith("001001")) {
      return comf(index, instruction);
    }
    // RLF
    else if (instruction.startsWith("001101")) {
      return rlf(index, instruction);
    }
    // MOVF
    else if (instruction.startsWith("001000")) {
      return movf(index, instruction);
    }
    // ADDWF
    else if (instruction.startsWith("000111")) {
      return addwf(index, instruction);
    }
    // ANDWF
    else if (instruction.startsWith("000101")) {
      return andwf(index, instruction);
    }
    // XORWF
    else if (instruction.startsWith("000110")) {
      return xorwf(index, instruction);
    }
    // IORWF
    else if (instruction.startsWith("000100")) {
      return iorwf(index, instruction);
    }
    // DECF
    else if (instruction.startsWith("000011")) {
      return decf(index, instruction);
    }
    // SUBWF
    else if (instruction.startsWith("000010")) {
      return subwf(index, instruction);
    }
    //5-Stellen #################################################
    // ADDLW
    else if (instruction.startsWith("11111")) {
      return addlw(index, instruction);
    }
    // SUBLW
    else if (instruction.startsWith("11110")) {
      return sublw(index, instruction);
    }
    // 4-Stellen #################################################
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
    // 3-Stellen #################################################
    // GOTO
    else if (instruction.startsWith("101")) {
      return goto(index, instruction);
    }
    // CALL
    else if (instruction.startsWith("100")) {
      return call(index, instruction);
    }
    print("NO HIT: " +
        instruction +
        "   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    return 0;
    // add new instruction with else if
  }

  int addlw(int index, String instruction) {
    //Addieren des Literals zum wReg. Ergebnis in wReg.
    print(index.toString() + " ADDLW");
    // convert to base 10 than back to hex and string
    var zahl1 = int.parse(instruction.substring(6), radix: 2);
    print("Zahl 1: " + zahl1.toRadixString(2) + "   " + zahl1.toString());
    var zahl2 = int.parse(wReg.value, radix: 2);
    print("Zahl 2: " + zahl2.toRadixString(2) + "   " + zahl2.toString());

    int sum = zahl1 + zahl2;

    var sum4 = int.parse(normalize(4, zahl1), radix: 2) +
        int.parse(normalize(4, zahl2), radix: 2);
    String binSum = normalize(8, sum);
    wReg.value = binSum;

    setZDcCBit(sum, sum4);

    print("Ergebnis: " +
        binSum.toString() +
        "   " +
        sum.toString() +
        "   " +
        sum.toRadixString(16));
    ++runtime;
    return (++index);
  }

  int andlw(int index, String instruction) {
    //Binäres & von Literal und wReg. Ergebins kommt ins wReg.
    print(index.toString() + " ANDLW");
    int sum = int.parse(instruction.substring(6), radix: 2) &
        int.parse(wReg.value, radix: 2);
    if (sum == 0) {
      setStatusBit("Z");
      print("Z-Bit: 1");
    } else {
      clearStatusBit("Z");
      print("Z-Bit: 0");
    }
    String binSum = normalize(8, sum);
    wReg.value = binSum;
    print("Ergebnis: " + binSum.toString());
    ++runtime;
    return ++index;
  }

  int addwf(int index, String instruction) {
    //Binäres & von Storage Adresse mit wReg. Ergebnis kommt je nach d-Bit in wReg oder Storage.
    print(index.toString() + " ADDWF");
    int address = catchAddress(instruction);
    var zahl1 = int.parse(storage.value[address], radix: 2);
    print("Zahl 1: " + zahl1.toRadixString(2) + "   " + zahl1.toString());
    var zahl2 = int.parse(wReg.value, radix: 2);
    print("Zahl 2: " + zahl2.toRadixString(2) + "   " + zahl2.toString());

    int sum = zahl1 + zahl2;
    var sum4 = int.parse(normalize(4, zahl1), radix: 2) +
        int.parse(normalize(4, zahl2), radix: 2);

    setZDcCBit(sum, sum4);

    String binSum = normalize(8, sum);
    print("Ergebnis: " + binSum.toString());
    index = changedPCL(index, address, binSum);
    f(address, binSum, instruction);
    ++runtime;
    return index;
  }

  int andwf(int index, String instruction) {
    // Binäres-& Inhalt Register an Adresse y mit dem Inhalt des wRegisters
    print(index.toString() + " ANDWF");
    int address = catchAddress(instruction);
    int sum = int.parse(storage.value[address], radix: 2) &
        int.parse(wReg.value, radix: 2);
    if (sum == 0) {
      setStatusBit("Z");
      print("Z-Bit: 1");
    } else {
      clearStatusBit("Z");
      print("Z-Bit: 0");
    }
    String w = wReg.value;
    wReg.value = normalize(8, sum);

    print("Ergebnis: " + wReg.value);
    index = changedPCL(index, address, wReg.value);
    wf(address, w, instruction);
    ++runtime;
    return index;
  }

  int bcf(int index, String instruction) {
    // Clear Bit x an Adresse y
    print(index.toString() + " BCF");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    bit = 7 - bit;
    int address = catchAddress(instruction);
    String data = storage.value[address];
    index = changedPCL(index, address, data);
    storage.value[address] = replaceCharAt(data, bit, "0");
    print("Ergebnis: " + storage.value[address].toString());
    ++runtime;
    return index;
  }

  int bsf(int index, String instruction) {
    // Setze Bit x an Adresse y
    print(index.toString() + " BSF");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    bit = 7 - bit;
    int address = catchAddress(instruction);
    String data = storage.value[address];
    index = changedPCL(index, address, data);
    storage.value[address] = replaceCharAt(data, bit, "1");
    print("Ergebnis: " + storage.value[address].toString());
    ++runtime;
    return index;
  }

  int btfsc(int index, String instruction) {
    // Überspringt nächsten Befehl wenn bestimmtes Bit in Adresse nicht gesetzt ist
    print(index.toString() + " BTFSC");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    bit = 7 - bit;
    int address = catchAddress(instruction);
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
    // Überspringt nächsten Befehl wenn bestimmtes Bit in Adresse gesetzt ist
    print(index.toString() + " BTFSS");
    int bit = int.parse(instruction.substring(4, 7), radix: 2);
    bit = 7 - bit;
    int address = catchAddress(instruction);
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
    // Springen zu neuem Untergrogramm an Stelle PCL + Adresse, aktl. Adresse auf Stack
    print(index.toString() + " CALL");

    stack[stackPointer] = index + 1; //index+1 auf Stack (return address)
    stackPointer++;
    if (stackPointer > 7) stackPointer = 0;

    String pclath = storage.value[10];
    int address = int.parse((pclath.substring(3, 5) + instruction.substring(3)),
        radix: 2);
    runtime += 2;
    return address;
  }

  int ret(int index) {
    // Aus unterprogramm zurück Springen zu Adresse auf Stack
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
    // Springe zu Befehl x (inkl. PCLath)
    print(index.toString() + " GOTO");
    String pclath = storage.value[10];
    int address = int.parse((pclath.substring(3, 5) + instruction.substring(3)),
        radix: 2);
    runtime += 2;
    return address;
  }

  int nop(int index) {
    // Mache nix außer die Runtime weiterzählen
    print(index.toString() + " NOP");
    ++runtime;
    return (++index);
  }

  int movlw(int index, String instruction) {
    //verschiebe das Literal aus der Instruction in das WRegister
    print(index.toString() + " MOVLW");
    wReg.value = instruction.substring(6);
    ++runtime;
    return (++index);
  }

  int retlw(int index, String instruction) {
    // Führe ein Movlw und ein Return aus
    print(index.toString() + " RETLW");
    movlw(index, instruction);
    --runtime;
    //wReg.value = instruction.substring(6);
    index = ret(index);
    //Runtime 2 Cycles
    return index;
  }

  int sublw(int index, String instruction) {
    // Subtrahiere Zahl2 von Zahl1 durch das 2er Komplement Ergebnis kommt ins wReg
    print(index.toString() + " SUBLW");
    var zahl1 =
        int.parse(instruction.substring(instruction.length - 8), radix: 2);
    print("Zahl 1: " + zahl1.toRadixString(2) + "   " + zahl1.toString());
    var zahl2 = int.parse(wReg.value, radix: 2);
    print("Zahl 2: " + zahl2.toRadixString(2) + "   " + zahl2.toString());

    int komplement =
        int.parse(normalize(8, complement(8, zahl2) + 1), radix: 2);
    int komplement4 =
        int.parse(normalize(4, complement(4, zahl2) + 1), radix: 2);

    var sub = zahl1 + komplement;
    var sub4 = int.parse(normalize(4, zahl1), radix: 2) + komplement4;

    setZDcCBit(sub, sub4);

    wReg.value = normalize(8, sub);
    print("Ergebnis: " +
        wReg.value +
        "   " +
        sub.toRadixString(16) +
        "   " +
        sub.toString());
    ++runtime;
    return (++index);
  }

  int iorlw(int index, String instruction) {
    // Binäres Oder zwischen dem wReg und dem Literal aus der Instruction Ergebnis kommt ins wReg
    print(index.toString() + " IORLW");
    int ins =
        int.parse(instruction.substring(instruction.length - 8), radix: 2);
    int w = int.parse(wReg.value, radix: 2);
    int ret = w | ins; // Binary OR
    wReg.value = normalize(8, ret);
    print("wReg: " +
        wReg.value +
        " Int: " +
        ret.toString() +
        " Hex: " +
        ret.toRadixString(16));

    if (ret == 0) {
      setStatusBit("Z");
      print("Z-Bit: 1");
    } else {
      clearStatusBit("Z");
      print("Z-Bit: 0");
    }
    ++runtime;
    return (++index);
  }

  int xorlw(int index, String instruction) {
    // Binäres Xor zwischen dem wReg und dem Literal aus der Instruction Ergebnis kommt ins wReg
    print(index.toString() + " XORLW");
    int ins =
        int.parse(instruction.substring(instruction.length - 8), radix: 2);
    int w = int.parse(wReg.value, radix: 2);
    int ret = w ^ ins; // Binary XOR
    wReg.value = normalize(8, ret);
    print("wReg: " +
        wReg.value +
        " Int: " +
        ret.toString() +
        " Hex: " +
        ret.toRadixString(16));
    if (ret == 0) {
      setStatusBit("Z");
      print("Z-Bit: 1");
    } else {
      clearStatusBit("Z");
      print("Z-Bit: 0");
    }
    ++runtime;
    return (++index);
  }

  int rlf(int index, String instruction) {
    //Binäre-Rotation nach links zwischen C-Bit & Reg an der Address x
    print(index.toString() + " RLF");
    int address = catchAddress(instruction);
    String reg = storage.value[address];
    String cBit = storage.value[3][statustoBit("C")];
    print("Register: " + binToHex(reg) + "h C-Bit: " + cBit);
    reg = reg + cBit; // C-Bit anhängen
    storage.value[3] = replaceCharAt(storage.value[3], statustoBit("C"),
        reg[0]); // Register stelle 0 in C-Bit verschieben
    reg = reg.substring(1); // verschobenes Bit löschen
    cBit = storage.value[3][statustoBit("C")];
    print("New Reister: " + binToHex(reg) + "h New C-Bit: " + cBit);
    //speichern
    if (instruction[instruction.length - 8] == "0") {
      wReg.value = reg;
      ++index;
    } else {
      index = changedPCL(index, address, reg);
      storage.value[address] = reg;
    }
    ++runtime;
    return index;
  }

  int clrw(int index, String instruction) {
    //setze wReg auf 0
    print(index.toString() + " CLRW");
    wReg.value = "00000000"; //clear
    setStatusBit("Z");
    ++runtime;
    return ++index;
  }

  int clrf(int index, String instruction) {
    //seze Reg an Adresse x auf 0
    print(index.toString() + " CLRF");
    int address = catchAddress(instruction);
    storage.value[address] = "00000000"; //clear
    setStatusBit("Z");
    ++runtime;
    return changedPCL(index, address, "00000000");
  }

  int incf(int index, String instruction) {
    //inkrementiere den Inhalt des Registers an Adresse x. Ergebnis in Register oder wReg
    print(index.toString() + " INCF");
    int address = catchAddress(instruction);
    int reg = int.parse(storage.value[address], radix: 2);
    print("Register: " +
        reg.toRadixString(2) +
        " Int: " +
        reg.toString() +
        " Hex: " +
        reg.toRadixString(16));
    reg = reg + 1;
    String res = normalize(8, reg);
    // Destination Bit
    if (instruction[6] == "0") {
      wReg.value = res;
      ++index;
    } else {
      index = changedPCL(index, address, res);
      storage.value[address] = res;
    }
    // Z-Bit setzen
    if (reg == 256 || reg == 0) {
      setStatusBit("Z");
      print("Z-Bit: 1");
    } else {
      clearStatusBit("Z");
      print("Z-Bit: 0");
    }
    ++runtime;
    return index;
  }

  int incfsz(int index, String instruction) {
    //inkrementiere den Inhalt des Registers an Adresse x. Ergebnis in Register oder wReg.
    //Wenn Ergebnis 0 Überspringe nächsten Befehl.
    print(index.toString() + " INCFSZ");
    index = incf(index, instruction); // Cycle 1

    // Ergebnis auf 0 prüfen
    if (storage.value[3][statustoBit("Z")] != "1") {
      return index; // Nächster Befehl
    } else {
      return nop(index);
      // Cycle 2 - Überspringen des nächsten Befehls, wurde durch NOP ersetzt
    }
  }

  int movwf(int index, String instruction) {
    //kopiere Inhalt wReg in Register der Adresse x
    print(index.toString() + " MOVWF");
    int address = catchAddress(instruction);
    index = changedPCL(index, address, wReg.value);
    String w = wReg.value;
    wf(address, w, instruction);
    ++runtime;
    return index;
  }

  int rrf(int index, String instruction) {
    //Binäre-Rotation nach rechts zwischen C-Bit & Reg an der Adresse x
    print(index.toString() + " RRF");
    int address = catchAddress(instruction);
    String reg = storage.value[address];
    String cBit = storage.value[3][statustoBit("C")];
    print("Register: " + binToHex(reg) + "h C-Bit: " + cBit);
    reg = cBit + reg; // C-Bit voranstellen
    print(reg);
    storage.value[3] = replaceCharAt(storage.value[3], statustoBit("C"),
        reg[reg.length - 1]); // Register letzte Stelle in C-Bit verschieben
    reg = reg.substring(0, reg.length - 1); // verschobenes Bit löschen
    print(reg);
    cBit = storage.value[3][statustoBit("C")];
    print("New Reister: " + binToHex(reg) + "h New C-Bit: " + cBit);
    //speichern
    if (instruction[instruction.length - 8] == "0") {
      wReg.value = reg;
      ++index;
    } else {
      index = changedPCL(index, address, reg);
      storage.value[address] = reg;
    }
    ++runtime;
    return index;
  }

  int movf(int index, String instruction) {
    //kopiere Inhalt Register r mit Adresse x aus Instruction nach wReg oder in Register r.
    print(index.toString() + " MOVF");
    int address = catchAddress(instruction);
    String reg = storage.value[address];
    int res = int.parse(reg, radix: 2);
    print("Register[" + address.toString() + "]: " + res.toRadixString(16));
    index = changedPCL(index, address, reg);
    f(address, res.toRadixString(2), instruction); // destination Bit
    // prüfe Z-Bit
    if (res == 0) {
      setStatusBit("Z");
    } else {
      clearStatusBit("Z");
    }
    ++runtime;
    return index;
  }

  int decf(int index, String instruction) {
    // Decrementiere Inhalt Register mit Adresse x. Ergebnis kommt in wReg oder Register
    print(index.toString() + " DECF");
    int address = catchAddress(instruction);
    int res = int.parse(storage.value[address], radix: 2);
    res = res - 1;
    if (res < 0) {
      res = 255;
    } // Fallbehandlung DECF 0
    // destination Bit
    if (instruction[6] == "0") {
      wReg.value = normalize(8, res);
      ++index;
    } else {
      String resBin = normalize(8, res);
      index = changedPCL(index, address, resBin);
      storage.value[address] = resBin;
    }
    // prüfe Z-Bit
    if (res == 0) {
      setStatusBit("Z");
    } else {
      clearStatusBit("Z");
    }
    ++runtime;
    return index;
  }

  int decfsz(int index, String instruction) {
    // Decrementiere Inhalt Register mit Adresse x. Ergebnis kommt in wReg oder Register
    // Überspringt nächten Befehl wenn Ergebnis 0.
    print(index.toString() + " DECFSZ");
    index = decf(index, instruction); // Cycle 1
    // Ergebnis auf 0 prüfen
    if (storage.value[3][statustoBit("Z")] != "1") {
      return index; // Nächster Befehl
    } else {
      return nop(
          index); // Cycle 2 - Überspringen des nächsten Befehls, wurde durch NOP ersetzt
    }
  }

  int subwf(int index, String instruction) {
    // Subtrahiere Zahl2 von Zahl1 Ergebnis kommt in Storage Adress oder wReg.
    print(index.toString() + " SUBWF");
    int address = catchAddress(instruction);
    String w = wReg.value;
    String zahl = normalize(14, int.parse(storage.value[address], radix: 2));
    index = sublw(index, zahl);
    wf(address, w, instruction);
    return index;
  }

  int iorwf(int index, String instruction) {
    //IOR Ergebnis kommt ins wReg oder in Storage Adress.
    print(index.toString() + " IORWF");
    int address = catchAddress(instruction);
    String w = wReg.value;
    String zahl = normalize(14, int.parse(storage.value[address], radix: 2));
    index = iorlw(index, zahl);
    wf(address, w, instruction);
    return index;
  }

  int xorwf(int index, String instruction) {
    //XOR Ergebnis kommt ins wReg oder in Storage Adress.
    print(index.toString() + " XORWF");
    int address = catchAddress(instruction);
    String w = wReg.value;
    String zahl = normalize(14, int.parse(storage.value[address], radix: 2));
    index = xorlw(index, zahl);
    wf(address, w, instruction);
    return index;
  }

  int comf(int index, String instruction) {
    // Complement des Inhalts vom Register r mit Adresse x. ERgebnis kommt in wReg oder in r.
    print(index.toString() + " COMF");
    int address = catchAddress(instruction);
    int zahl = int.parse(storage.value[address], radix: 2);
    int res = complement(8, zahl);
    f(address, res.toRadixString(2), instruction);
    if (res == 0) {
      setStatusBit("Z");
    } else {
      clearStatusBit("Z");
    }
    ++runtime;
    return ++index;
  }

  int swapf(int index, String instruction) {
    //Tauschen der oberen und unteren 4 Bit. Ergebnis in wReg oder Storage.
    print(index.toString() + " SWAPF");
    int address = catchAddress(instruction);
    String reg = storage.value[address];
    String oh = reg.substring(0, 4);
    String uh = reg.substring(4, 8);
    reg = uh + oh;
    f(address, reg, instruction);
    ++runtime;
    return ++index;
  }

  int clrwdt(int index) {
    //Clear Whatchdog Timer
    print(index.toString() + " CLRWDT");
    storage.value[1] = "00000000"; //TMR0Adr: 01h
    storage.value[129] =
        replaceCharAt(storage.value[129], 4, "0"); //Reset PSA Adr: 81h4

    setStatusBit("TO");
    setStatusBit("PD");
    ++runtime;
    return ++index;
  }

  int retfie(int index) {
    // Return from Interrupt
    print(index.toString() + " RETFIE");
    index = ret(index);
    int i = 0;
    if (storage.value[3][statustoBit("RP0")] == "0") {
      // Unterschiedliche Plätze bei Bank 0 und 1
      i = 11;
    } else {
      i = 139;
    }
    storage.value[i] = replaceCharAt(storage.value[i], 0,
        "1"); //GIE - Global Interrupt Freigabe Bit Adresse: 8Bh.0
    return index;
  }
}
//Testprog 3:
//Testprog 4:
