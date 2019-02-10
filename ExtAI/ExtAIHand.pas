unit ExtAIHand;
interface
uses
  Windows, System.SysUtils,
  ExtAIInterfaceDelphi, ExtAIUtils, ExtAIDataTypes;

type
  // ExtAI class for Hands - process flow of events and actions
  TExtAIHand = class(TInterfacedObject, IActions)
  private
    fID: ui8;
    fOnLog: TLogEvent;
    // IActions
    procedure GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32); StdCall;
    procedure GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDirection: ui16); StdCall;
    procedure LogDLL(apLog: pwStr; aLen: ui32); StdCall;
    // Log
    procedure Log(aLog: wStr);
  public
    Events: IEvents;
    property ID: ui8 read fID;

    constructor Create(aID: ui8; aLog: TLogEvent); reintroduce;
    destructor Destroy(); override;

    // Events - or use public variable Events: IEvents to directly call events in DLL
    procedure OnMissionStart();
    procedure OnTick(aTick: ui32);
    procedure OnPlayerDefeated(aPlayer: si8);
    procedure OnPlayerVictory(aPlayer: si8);
  end;

implementation


{ TExtAIHand }
constructor TExtAIHand.Create(aID: ui8; aLog: TLogEvent);
begin
  inherited Create();
  fID := aID;
  fOnLog := aLog;
  Log('  TExtAIHand-Create: ID = '+IntToStr(fID));
end;

destructor TExtAIHand.Destroy();
begin
  Log('  TExtAIHand-Destroy: ID = '+IntToStr(fID));
  inherited;
end;


// IActions - definition of functions in the interface
procedure TExtAIHand.GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32);
begin
  // Check if parameters are correct and call action...
  // For test check only if parameters are correct
  if (aGroupID <> 11) OR (aUnitID <> 22) then
    Log('  TExtAIHand-GroupOrderAttackUnit: wrong parameters, ID = '+IntToStr(fID));
end;

procedure TExtAIHand.GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDirection: ui16);
begin
  // Check if parameters are correct and call action...
  // For test check only if parameters are correct
  if (aGroupID <> 1) OR (aX <> 50) OR (aY <> 50) OR (aDirection <> 1) then
    Log('  TExtAIHand-GroupOrderWalk: wrong parameters, ID = '+IntToStr(fID));
end;


// IEvents - calling of functions in the interface (or delete this part and use directly public variable Events)
procedure TExtAIHand.OnMissionStart();
begin
  Events.OnMissionStart();
end;

procedure TExtAIHand.OnTick(aTick: ui32);
begin
  Events.OnTick(aTick);
end;

procedure TExtAIHand.OnPlayerDefeated(aPlayer: si8);
begin
  Events.OnPlayerDefeated(aPlayer);
end;

procedure TExtAIHand.OnPlayerVictory(aPlayer: si8);
begin
  Events.OnPlayerVictory(aPlayer);
end;


// Logs from DLL
procedure TExtAIHand.LogDLL(apLog: pwStr; aLen: ui32);
var
  Str: wStr;
begin
  SetLength(Str,aLen);
  Move(apLog^, Str[1], aLen * SizeOf(Str[1]));
  Log(Str);
end;


procedure TExtAIHand.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;

end.