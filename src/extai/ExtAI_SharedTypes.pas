unit ExtAI_SharedTypes;
interface

type
  b = boolean;     //                        0 to 1
  // Integer
	ui8 = Byte;      //                        0 to 255
	si8 = ShortInt;  //                     -127 to 127
	ui16 = Word;     //                        0 to 65,535
	si16 = SmallInt; //                  -32,768 to 32,767
	//ui32 = LongWord; //                      0 to 4,294,967,295
	ui32 = Cardinal; //                        0 to 4,294,967,295
	//si32 = LongInt;  //         -2,147,483,648 to 2,147,483,647
	si32 = Integer;  //           -2,147,483,648 to 2,147,483,647
	//ui64 = UInt64; //                          0 to 1,84467440737096E19 // Delphi does not have ui64 in basic set?
	si64 = Int64;  // -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807

  // Float
	f4 = Single;   //  7  significant digits, exponent   -38 to +38
	f8 = Double;   // 15  significant digits, exponent  -308 to +308
	//f10 = Extended; // 19  significant digits, exponent -4932 to +4932

  // String
  wStr = WideString;

  // Pointers
  pb = ^b;
  pui8 = ^ui8;
  psi8 = ^si8;
  pui16 = ^ui16;
  psi16 = ^si16;
  pui32 = ^ui32;
  psi32 = ^si32;

  pwStr = PWideChar;

  // Unit description
  TUnitInfo = packed record
    UID: ui32;
    PosX, PosY: si16;
  end;
  PUnitInfo = ^TUnitInfo;
  TUnitInfoArray = array of TUnitInfo;

  // Group description
  TGroupInfo = packed record
    UID: ui32;
    UnitCount: ui16;
  end;
  PGroupInfo = ^TGroupInfo;
  TGroupInfoArray = array of TGroupInfo;

  // Structures
  TDLLConfig = record
    Author: wStr;
    Description: wStr;
    ExtAIName: wStr;
    Version: ui32;
  end;

  TDLLMainCfg = record
    Author: wStr;
    Description: wStr;
    ExtAIName: wStr;
    Path: wStr;
    Version: ui32;
  end;

  TDLLpConfig = record
    Author: pwStr;
    AuthorLen: ui32;
    Description: pwStr;
    DescriptionLen: ui32;
    ExtAIName: pwStr;
    ExtAINameLen: ui32;
    Version: ui32;
  end;

implementation

end.
