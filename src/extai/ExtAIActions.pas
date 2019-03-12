unit ExtAIActions;
interface
uses
  Windows, System.SysUtils,
  Consts, ExtAI_SharedInterfaces, ExtAIUtils, ExtAI_SharedTypes;

type
  // ExtAI Actions
  TExtAIActions = class(TInterfacedObject, IActions)
  private
    fHandIndex: TKMHandIndex;
    fOnLog: TLogEvent;

    // IActions
    function GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32): b; StdCall;
    function GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDirection: ui8): b; StdCall;
    procedure LogDLL(apLog: pwStr; aLen: ui32); StdCall;

    // Log
    procedure Log(aLog: wStr);
  public
    constructor Create(aHandIndex: TKMHandIndex; aLog: TLogEvent); reintroduce;
    destructor Destroy(); override;
  end;

implementation


{ TExtAIActions }
constructor TExtAIActions.Create(aHandIndex: TKMHandIndex; aLog: TLogEvent);
begin
  inherited Create;

  fHandIndex := aHandIndex;
  fOnLog := aLog;
  Log('  TExtAIActions-Create: HandIndex = ' + IntToStr(fHandIndex));
end;


destructor TExtAIActions.Destroy();
begin
  Log('  TExtAIActions-Destroy: HandIndex = ' + IntToStr(fHandIndex));

  inherited;
end;


// IActions - definition of functions in the interface
function TExtAIActions.GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32): b;
begin
  if DBG_LOG_VERBOSE then
    Log(Format('TExtAIActions(%d).GroupOrderAttackUnit [%d, %d]', [fHandIndex, aGroupID, aUnitID]));

  Result := (aGroupID = 11) and (aUnitID = 22);

  // Check if parameters are correct and call action...
  // For test check only if parameters are correct
  if (aGroupID <> 11) or (aUnitID <> 22) then
    Log('  TExtAIActions-GroupOrderAttackUnit: wrong parameters, HandIndex = ' + IntToStr(fHandIndex));
end;


function TExtAIActions.GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDirection: ui8): b;
begin
  if DBG_LOG_VERBOSE then
    Log(Format('TExtAIActions(%d).GroupOrderWalk [%d, %d, %d, %d]', [fHandIndex, aGroupID, aX, aY, aDirection]));

  Result := (aGroupID = 1) and (aX = 50) and (aY = 50) and (aDirection = 1);

  // Check if parameters are correct and call action...
  // For test check only if parameters are correct
  if (aGroupID <> 1) or (aX <> 50) or (aY <> 50) or (aDirection <> 1) then
    Log('  TExtAIActions-GroupOrderWalk: wrong parameters, HandIndex = ' + IntToStr(fHandIndex));
end;


// Logs from DLL
procedure TExtAIActions.LogDLL(apLog: pwStr; aLen: ui32);
var
  Str: wStr;
begin
  SetLength(Str, aLen);
  Move(apLog^, Str[1], aLen * SizeOf(Str[1]));
  Log(Str);
end;


procedure TExtAIActions.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;


end.
