unit ExtAIInterfaceDelphi;
interface
uses
  Windows, System.SysUtils,
  ExtAIDataTypes;

type
  // Interface for Actions
  IActions = interface(IInterface)
    ['{66FDB631-E3DC-4B8E-A745-4337C487ED69}']
    procedure GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32); StdCall;
    procedure GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDirection: ui16); StdCall;
    procedure LogDLL(apLog: pwStr; aLen: ui32); StdCall;
  end;

  // Interface for Events
  IEvents = interface(IInterface)
    ['{8E77167C-CC59-4917-BE0B-BCF311B3CEEE}']
    procedure OnMissionStart(); StdCall;
    procedure OnTick(aTick: ui32); StdCall;
    procedure OnPlayerDefeated(aPlayer: si8); StdCall;
    procedure OnPlayerVictory(aPlayer: si8); StdCall;
  end;

  // Interface for States
  IStates = interface(IInterface)
    ['{2A228001-8FE0-4A01-8B5D-5D7D8394B1DD}']
    function State1(aID: ui32): ui8; StdCall;
    function MapTerrain(aID: ui8; var aFirstElem: pui32; var aLength: si32): b; StdCall;
  end;


implementation

end.

