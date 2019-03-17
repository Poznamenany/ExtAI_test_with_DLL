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

    // IActions
    function GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32): b; StdCall;
    function GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDir: ui8): b; StdCall;
    procedure LogDLL(apLog: pwStr; aLen: ui32); StdCall;
  public const
    DBG_LOG_VERBOSE: Boolean = True;
    constructor Create(aHandIndex: TKMHandIndex);
    destructor Destroy; override;
  end;

implementation
uses
  Log;


{ TExtAIActions }
constructor TExtAIActions.Create(aHandIndex: TKMHandIndex);
begin
  inherited Create;

  fHandIndex := aHandIndex;

  gLog.Log('  TExtAIActions-Create: HandIndex = ' + IntToStr(fHandIndex));
end;


destructor TExtAIActions.Destroy;
begin
  gLog.Log('  TExtAIActions-Destroy: HandIndex = ' + IntToStr(fHandIndex));

  inherited;
end;


// IActions - definition of functions in the interface
function TExtAIActions.GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32): b;
begin
  if DBG_LOG_VERBOSE then
    gLog.Log(Format('TExtAIActions(%d).GroupOrderAttackUnit [%d, %d]', [fHandIndex, aGroupID, aUnitID]));

  // Check if parameters are correct and call action...
  // For test check only if parameters are correct
  Result := (aGroupID = 11) and (aUnitID = 22);
  if not Result then
    gLog.Log('  TExtAIActions-GroupOrderAttackUnit: wrong parameters, HandIndex = ' + IntToStr(fHandIndex));
end;


function TExtAIActions.GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDir: ui8): b;
begin
  if DBG_LOG_VERBOSE then
    gLog.Log(Format('TExtAIActions(%d).GroupOrderWalk [%d, %d, %d, %d]', [fHandIndex, aGroupID, aX, aY, aDir]));

  // Check if parameters are correct and call action...
  // For test check only if parameters are correct
  Result := (aGroupID = 1) and (aX = 50) and (aY = 50) and (aDir = 1);
  if not Result then
    gLog.Log('  TExtAIActions-GroupOrderWalk: wrong parameters, HandIndex = ' + IntToStr(fHandIndex));
end;


// Logs from DLL
procedure TExtAIActions.LogDLL(apLog: pwStr; aLen: ui32);
var
  Str: wStr;
begin
  SetLength(Str, aLen);
  Move(apLog^, Str[1], aLen * SizeOf(Str[1]));
  gLog.Log(Str);
end;


end.
