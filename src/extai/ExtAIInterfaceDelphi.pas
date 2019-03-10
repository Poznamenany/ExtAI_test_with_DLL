unit ExtAIInterfaceDelphi;
interface
uses
  ExtAIDataTypes;

type
  // Interface for Actions (when ExtAI wants the Game to do something, e.g. move soldiers)
  // ExtAI -> Game
  IActions = interface(IInterface)
    ['{66FDB631-E3DC-4B8E-A745-4337C487ED69}']
    function GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32): b; StdCall;
    function GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDirection: ui8): b; StdCall;
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
    function State1(aID: ui32): ui8; StdCall;
    function UnitAt(aX: ui16; aY: ui16): ui32; StdCall;
    function MapTerrain(aID: ui8; var aFirstElem: pui32; var aLength: si32): b; StdCall;
    procedure TerrainSize(var aX: ui16; var aY: ui16); StdCall;
    // DLL should allocate TerrainSize.X * TerrainSize.Y elements
    procedure TerrainPassability(var aPassability: pb); StdCall;
  end;


implementation

end.

