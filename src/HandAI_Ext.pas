unit HandAI_Ext;
interface
uses
  Windows, System.SysUtils,
  ExtAIInterfaceDelphi, ExtAIUtils, ExtAIDataTypes;

type
  // ExtAI class for Hands - process flow of events and actions
  THandAI_Ext = class(TInterfacedObject, IActions)
  private
    fOwner: Integer;
    fOnLog: TLogEvent;

    fEvents: IEvents;

    // IActions
    procedure GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32); StdCall;
    procedure GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDirection: ui16); StdCall;
    procedure LogDLL(apLog: pwStr; aLen: ui32); StdCall;

    // Log
    procedure Log(aLog: wStr);
  public
    property Owner: Integer read fOwner;

    constructor Create(aOwner: Integer; aLog: TLogEvent); reintroduce;
    destructor Destroy(); override;

    procedure AssignEvents(aEvents: IEvents);

    // fEvents: IEvents to directly call events in DLL
    procedure OnMissionStart();
    procedure OnTick(aTick: Cardinal);
    procedure OnPlayerDefeated(aPlayer: si8);
    procedure OnPlayerVictory(aPlayer: si8);
  end;

implementation


{ THandAI_Ext }
constructor THandAI_Ext.Create(aOwner: Integer; aLog: TLogEvent);
begin
  inherited Create;

  fOwner := aOwner;
  fOnLog := aLog;
  Log('  THandAIExt-Create: ID = ' + IntToStr(fOwner));
end;


destructor THandAI_Ext.Destroy();
begin
  Log('  THandAIExt-Destroy: ID = ' + IntToStr(fOwner));
  inherited;
end;


procedure THandAI_Ext.AssignEvents(aEvents: IEvents);
begin
  fEvents := aEvents;
end;


// IActions - definition of functions in the interface
procedure THandAI_Ext.GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32);
begin
  // Check if parameters are correct and call action...
  // For test check only if parameters are correct
  if (aGroupID <> 11) or (aUnitID <> 22) then
    Log('  THandAIExt-GroupOrderAttackUnit: wrong parameters, ID = ' + IntToStr(fOwner));
end;


procedure THandAI_Ext.GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDirection: ui16);
begin
  // Check if parameters are correct and call action...
  // For test check only if parameters are correct
  if (aGroupID <> 1) or (aX <> 50) or (aY <> 50) or (aDirection <> 1) then
    Log('  THandAIExt-GroupOrderWalk: wrong parameters, ID = ' + IntToStr(fOwner));
end;


// IEvents - calling of functions in the interface (or delete this part and use directly public variable Events)
procedure THandAI_Ext.OnMissionStart();
begin
  fEvents.OnMissionStart();
end;


procedure THandAI_Ext.OnTick(aTick: Cardinal);
begin
  fEvents.OnTick(aTick);
end;


procedure THandAI_Ext.OnPlayerDefeated(aPlayer: si8);
begin
  fEvents.OnPlayerDefeated(aPlayer);
end;


procedure THandAI_Ext.OnPlayerVictory(aPlayer: si8);
begin
  fEvents.OnPlayerVictory(aPlayer);
end;


// Logs from DLL
procedure THandAI_Ext.LogDLL(apLog: pwStr; aLen: ui32);
var
  Str: wStr;
begin
  SetLength(Str, aLen);
  Move(apLog^, Str[1], aLen * SizeOf(Str[1]));
  Log(Str);
end;


procedure THandAI_Ext.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;


end.
