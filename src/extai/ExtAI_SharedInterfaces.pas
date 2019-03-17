unit ExtAI_SharedInterfaces;
interface
uses
  ExtAI_SharedTypes;

// @Krom: is in Delphi DEFINE like in C?
// #define ADDCALL __stdcall   = #define name_of_variable code_which_will_be_inserted
// void ADDCALL fcn1();
// void ADDCALL fcn2();
// ...
// So you can change StdCall to different calling convention in 1 place?
// So far I see only 1 solution
// {$DEFINE DelphiConvention}
// procedure fcn1(); {$IFDEF DelphiConvention} StdCall; {$ELSE} cdecl; {$ENDIF}
type
  // Interface for Actions (when ExtAI wants the Game to do something, e.g. move soldiers)
  // ExtAI -> Game
  IActions = interface(IInterface)
    ['{66FDB631-E3DC-4B8E-A745-4337C487ED69}']
    function GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32): b; StdCall;
    function GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDir: ui8): b; StdCall;
    procedure LogDLL(apLog: pwStr; aLen: ui32); StdCall;
  end;

  // Interface for Events (when Game wants to tell ExtAI something has happened, e.g. new Tick)
  // Game -> ExtAI, no feedback
  IEvents = interface(IInterface)
    ['{8E77167C-CC59-4917-BE0B-BCF311B3CEEE}']
    procedure OnMissionStart(); StdCall;
    procedure OnTick(aTick: ui32); StdCall;
    procedure OnPlayerDefeated(aHandIndex: si8); StdCall;
    procedure OnPlayerVictory(aHandIndex: si8); StdCall;
  end;

  // Interface for States (when ExtAI wants to know some Game's state)
  // ExtAI -> Game -> ExtAI
  IStates = interface(IInterface)
    ['{2A228001-8FE0-4A01-8B5D-5D7D8394B1DD}']
    function State1(aID: ui32): ui8; StdCall; deprecated;
    function UnitAt(aX: ui16; aY: ui16): ui32; StdCall;
    function MapTerrain(aID: ui8; var aFirstElem: pui32; var aLength: si32): b; StdCall;
    procedure TerrainSize(var aX: ui16; var aY: ui16); StdCall;
    // DLL should allocate TerrainSize.X * TerrainSize.Y elements
    procedure TerrainPassability(var aPassability: pb); StdCall;

    function GetGroupCount(aHandIndex: ui8): ui32; StdCall;
    procedure GetGroups(aHandIndex: ui8; aFirst: PGroupInfo; aCount: ui32); StdCall;
    function UnitIsAlive(aUnitUID: ui32): b; StdCall;
    function GetUnitCount(aHandIndex: ui8): ui32; StdCall;
    procedure GetUnits(aHandIndex: ui8; aFirst: PUnitInfo; aCount: ui32); StdCall;
  end;


implementation

end.

