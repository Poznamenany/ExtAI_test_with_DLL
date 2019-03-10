unit HandAI_Ext;
interface
uses
  Windows, System.SysUtils,
  Consts, ExtAIInterfaceDelphi, ExtAIUtils, ExtAIDataTypes;

type
  // ExtAI class for Hands - process flow of events and actions
  THandAI_Ext = class(TInterfacedObject, IActions)
  private
    fHandIndex: TKMHandIndex;
    fOnLog: TLogEvent;

    fEvents: IEvents;

    // IActions
    function GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32): b; StdCall;
    function GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDirection: ui8): b; StdCall;
    procedure LogDLL(apLog: pwStr; aLen: ui32); StdCall;

    // Log
    procedure Log(aLog: wStr);
  public
    constructor Create(aHandIndex: TKMHandIndex; aLog: TLogEvent); reintroduce;
    destructor Destroy(); override;

    procedure AssignEvents(aEvents: IEvents);

    // fEvents: IEvents to directly call events in DLL
    procedure OnMissionStart();
    procedure OnTick(aTick: Cardinal);
    procedure OnPlayerDefeated(aHandIndex: TKMHandIndex);
    procedure OnPlayerVictory(aHandIndex: TKMHandIndex);
  end;

implementation


{ THandAI_Ext }
constructor THandAI_Ext.Create(aHandIndex: TKMHandIndex; aLog: TLogEvent);
begin
  inherited Create;

  fHandIndex := aHandIndex;
  fOnLog := aLog;
  Log('  THandAIExt-Create: HandIndex = ' + IntToStr(fHandIndex));
end;


destructor THandAI_Ext.Destroy();
begin
  Log('  THandAIExt-Destroy: HandIndex = ' + IntToStr(fHandIndex));

  inherited;
end;


procedure THandAI_Ext.AssignEvents(aEvents: IEvents);
begin
  fEvents := aEvents;
end;


// IActions - definition of functions in the interface
function THandAI_Ext.GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32): b;
begin
  if LOG_VERBOSE then
    Log(Format('THandAIExt(%d).GroupOrderAttackUnit [%d, %d]', [fHandIndex, aGroupID, aUnitID]));

  Result := (aGroupID = 11) and (aUnitID = 22);

  // Check if parameters are correct and call action...
  // For test check only if parameters are correct
  if (aGroupID <> 11) or (aUnitID <> 22) then
    Log('  THandAIExt-GroupOrderAttackUnit: wrong parameters, HandIndex = ' + IntToStr(fHandIndex));
end;


function THandAI_Ext.GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDirection: ui8): b;
begin
  if LOG_VERBOSE then
    Log(Format('THandAIExt(%d).GroupOrderWalk [%d, %d, %d, %d]', [fHandIndex, aGroupID, aX, aY, aDirection]));

  Result := (aGroupID = 1) and (aX = 50) and (aY = 50) and (aDirection = 1);

  // Check if parameters are correct and call action...
  // For test check only if parameters are correct
  if (aGroupID <> 1) or (aX <> 50) or (aY <> 50) or (aDirection <> 1) then
    Log('  THandAIExt-GroupOrderWalk: wrong parameters, HandIndex = ' + IntToStr(fHandIndex));
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


procedure THandAI_Ext.OnPlayerDefeated(aHandIndex: TKMHandIndex);
begin
  fEvents.OnPlayerDefeated(aHandIndex);
end;


procedure THandAI_Ext.OnPlayerVictory(aHandIndex: TKMHandIndex);
begin
  fEvents.OnPlayerVictory(aHandIndex);
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
