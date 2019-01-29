unit ExtAI;

interface
uses
  Windows, System.SysUtils,
  ExtAIInterfaceDelphi, ExtAIDataTypes;

type
TExtAI = class(TInterfacedObject, IEvents)
  private
    // IInterface
    //procedure AfterConstruction; override;
    //procedure BeforeDestruction; override;
    // IEvents
    procedure OnMissionStart(); StdCall;
    procedure OnTick(aTick: ui32); StdCall;
    procedure OnPlayerDefeated(aPlayer: si8); StdCall;
    procedure OnPlayerVictory(aPlayer: si8); StdCall;
    // Log
    procedure Log(aLog: wStr);
  public
    Actions: IActions;
    States: IStates;
    ID: ui8;

    constructor Create();
    destructor Destroy(); override;
  end;

implementation

{ TExtAI }
constructor TExtAI.Create();
begin
  inherited Create();
  ID := 0;
  Actions := nil;
end;

destructor TExtAI.Destroy();
begin
  Actions := nil;
  inherited;
end;


procedure TExtAI.OnMissionStart();
begin
  Log('    TExtAI-OnMissionStart: ID = ' + IntToStr(ID));
end;

procedure TExtAI.OnTick(aTick: ui32);
begin
  //Log('    TExtAI-OnTick: ID = ' + IntToStr(ID));
  //Actions.GroupOrderAttackUnit(1,1);
end;

procedure TExtAI.OnPlayerDefeated(aPlayer: si8);
begin
  Log('    TExtAI-OnPlayerDefeated: ID = ' + IntToStr(ID));
end;

procedure TExtAI.OnPlayerVictory(aPlayer: si8);
begin
  Log('    TExtAI-OnPlayerVictory: ID = ' + IntToStr(ID));
end;

procedure TExtAI.Log(aLog: wStr);
begin
  Actions.LogDLL(Addr(aLog[1]), Length(aLog));
end;

{

// Test all callbacks and events
procedure TExtAI.Event1(aID: ui32);
var
  testVar, K: ui8;
  pMap: pui32;
  mapLen: si32;
  Map: ui32Arr;
begin
  writeln('    TExtAI: Event1, class fID: ' + IntToStr(ID) + '; parameter aID: ' + IntToStr(aID)); // Show event 1
  Actions.Action1(11,22); // Check callback
  testVar := States.State1(22);
  writeln('    TExtAI: Event1, class fID: ' + IntToStr(ID) + '; testVar: ' + IntToStr(testVar)); // Show test var from State 1
  // Get array (pointer to first element) from Main program and copy memory so we can work with it
  pMap := nil;
  if States.State2(pMap, mapLen) then
  begin
    SetLength(Map,mapLen);
    Move(pMap^, Map[0], SizeOf(Map[0]) * Length(Map));
    write('    TExtAI: Event1, class fID: ' + IntToStr(ID) + '; log array:'); // Show values of array
    for K := Low(Map) to High(Map) do
      write(' ' + IntToStr(Map[K]));
    writeln('');
  end;
end;

}


end.
