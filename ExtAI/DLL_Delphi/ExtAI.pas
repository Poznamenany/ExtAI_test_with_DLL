unit ExtAI;
interface
uses
  Windows, System.SysUtils,
  ExtAIInterfaceDelphi, ExtAIDataTypes;

type
  TExtAI = class(TInterfacedObject, IEvents)
  private
    fMap: ui32Arr;
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
var
  feedback: ui8;
  Len, K: si32;
  pFirstElem: pui32;
  res: b;
begin
  //Log('    TExtAI-OnTick: ID = ' + IntToStr(ID));
  // Test actions
  res := Actions.GroupOrderAttackUnit(11,22);
  res := Actions.GroupOrderWalk(1,50,50,1);
  // Test states
  feedback := States.State1(11);
  if (feedback <> 11) then
    Log('    TExtAI-OnTick: wrong state feedback = ' + IntToStr(feedback));
  if States.MapTerrain(ID,pFirstElem,Len) then
  begin
    if (Len <> Length(fMap)) then
      SetLength(fMap,Len);
    Move(pFirstElem^, fMap[0], SizeOf(fMap[0]) * Length(fMap));
    for K := Low(fMap) to High(fMap)-1 do
      if (fMap[K] >= fMap[K+1]) then
      begin
        Log('    TExtAI-OnTick: problem in testing map, val: ' + IntToSTr(fMap[K]) + ' vs ' + IntToSTr(fMap[K+1]));
        break;
      end;
  end;
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


end.
