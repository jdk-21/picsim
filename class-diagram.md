@startuml
set namespaceSeparator ::

class "picsim::instructionCycler.dart::InstructionCycler" {
  +InstructionRecognizer recognizer
  +int programCounter
  +List programStorage
  +bool run
  +int psaCounter
  +int oldPSA
  +int calculatePSA()
  +void timer0()
  +bool interrupt()
  +void resetRegisters()
  +void programm()
  +void start()
  +void pause()
  +void reset()
  +void step()
}

"picsim::instructionCycler.dart::InstructionCycler" o-- "picsim::instructionRecognizer.dart::InstructionRecognizer"

class "picsim::instructionRecognizer.dart::InstructionRecognizer" {
  +int stackPointer
  +String binToHex()
  +String replaceCharAt()
  +int changedPCL()
  +int complement()
  +int statustoBit()
  +void clearStatusBit()
  +void setStatusBit()
  +String normalize()
  +String setZDcCBit()
  +int catchAddress()
  +void wf()
  +void f()
  +int recognize()
  +int addlw()
  +int andlw()
  +int addwf()
  +int andwf()
  +int bcf()
  +int bsf()
  +int btfsc()
  +int btfss()
  +int call()
  +int ret()
  +int goto()
  +int nop()
  +int movlw()
  +int retlw()
  +int sublw()
  +int iorlw()
  +int xorlw()
  +int rlf()
  +int clrw()
  +int clrf()
  +int incf()
  +int incfsz()
  +int movwf()
  +int rrf()
  +int movf()
  +int decf()
  +int decfsz()
  +int subwf()
  +int iorwf()
  +int xorwf()
  +int comf()
  +int swapf()
  +int clrwdt()
  +int retfie()
}

class "picsim::main.dart::MyApp" {
  +Widget build()
}

"flutter::src::widgets::framework.dart::StatelessWidget" <|-- "picsim::main.dart::MyApp"

class "picsim::main.dart::MyHomePage" {
  +dynamic title
  +_MyHomePageState createState()
}

"flutter::src::widgets::framework.dart::StatefulWidget" <|-- "picsim::main.dart::MyHomePage"

class "picsim::main.dart::_MyHomePageState" {
  +void readProgramCode()
  +Widget build()
}

"flutter::src::widgets::framework.dart::State<T>" <|-- "picsim::main.dart::_MyHomePageState"

class "picsim::simscreen.dart::SimScreen" {
  +_SimScreenState createState()
}

"flutter::src::widgets::framework.dart::StatefulWidget" <|-- "picsim::simscreen.dart::SimScreen"

class "picsim::simscreen.dart::_SimScreenState" {
  +int lastIndex
  +dynamic quartzFrequency
  +double runtimeDisplay
  +dynamic highlighter()
  +dynamic createStorageDialog()
  +dynamic createQuartzDialog()
  +dynamic changeTrisBit()
  +void initState()
  +Widget build()
}

"flutter::src::widgets::framework.dart::State<T>" <|-- "picsim::simscreen.dart::_SimScreenState"


@enduml