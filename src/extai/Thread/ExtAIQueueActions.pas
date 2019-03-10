unit ExtAIQueueActions;
interface
uses
  Windows, System.SysUtils,
  ExtAIUtils, ExtAIInterfaceDelphi, ExtAIDataTypes;

type
  TActType = (atGroupOrderAttackUnit, atGroupOrderWalk);

  TRecGroupOrderAttackUnit = record GroupID: ui32; UnitID: ui32; end;
  TRecGroupOrderWalk = record GroupID: ui32; X: ui16; Y: ui16; Direction: ui16; end;

  pRecGroupOrderAttackUnit = ^TRecGroupOrderAttackUnit;
  pRecGroupOrderWalk = ^TRecGroupOrderWalk;

  pAct = ^TAct;
  TAct = record
    ActType: TActType;
    Ptr: Pointer;
    Next: pAct;
  end;

  // Queue of actions for multithreading
  TExtAIQueueActions = class(TInterfacedObject, IActions)
  private
    fHandIndex: TKMHandIndex;
    fStartAct: pAct;
    fEndAct: pAct;
    fLiveActionsCnt: si32;
    // IActions
    procedure GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32); StdCall;
    procedure GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDirection: ui16); StdCall;
    procedure LogDLL(apLog: pwStr; aLen: ui32); StdCall;
    // Queue
    procedure AddAction(aActType: TActType; aPtr: Pointer);
    function GetAction(var aActType: TActType; var aPtr: Pointer): b;
    // Log
    procedure Log(aLog: wStr);
  public
    OnLog: TLogEvent;
    Actions: IActions;
    constructor Create(aHandIndex: TKMHandIndex; aLog: TLogEvent); reintroduce;
    destructor Destroy(); override;

    function CallAction(): b;
  end;

implementation


{ TExtAIQueueActions }
constructor TExtAIQueueActions.Create(aHandIndex: TKMHandIndex; aLog: TLogEvent);
begin
  inherited Create();
  fHandIndex := aHandIndex;
  OnLog := aLog;
  fLiveActionsCnt := 0;
  New(fStartAct);  // 1 Action is empty and divides start and end pointer
  Inc(fLiveActionsCnt);
  fStartAct.Next := nil;
  fEndAct := fStartAct;
  Log('  TExtAIQueueActions-Create: HandIndex = ' + IntToStr(fHandIndex));
end;

destructor TExtAIQueueActions.Destroy();
var
  ActType: TActType;
  ActPtr: Pointer;
begin
  Log('  TExtAIQueueActions-Destroy: HandIndex = ' + IntToStr(fHandIndex));
  while GetAction(ActType, ActPtr) do
  begin
    case ActType of
      atGroupOrderAttackUnit:   Dispose( pRecGroupOrderAttackUnit(ActPtr) );
      atGroupOrderWalk:         Dispose( pRecGroupOrderWalk(ActPtr) );
    end;
  end;
  if (fStartAct <> nil) then // Last Action
  begin
    Dispose(fStartAct);
    Dec(fLiveActionsCnt);
  end;
  if (fLiveActionsCnt <> 0) then
    Log('  TExtAIQueueActions-Destroy: Actions termination error, HandIndex = ' + IntToStr(fHandIndex) + '; cnt = '+IntToStr(fLiveActionsCnt));

  inherited;
end;


procedure TExtAIQueueActions.AddAction(aActType: TActType; aPtr: Pointer);
var
  newAct: pAct;
begin
  New(newAct);
  Inc(fLiveActionsCnt);
  newAct^.Next := nil;
  fEndAct^.ActType := aActType;
  fEndAct^.Ptr := aPtr;
  AtomicExchange(fEndAct^.Next, newAct);
  fEndAct := newAct;
end;


function TExtAIQueueActions.GetAction(var aActType: TActType; var aPtr: Pointer): b;
var
  tempAct: pAct;
begin
  Result := (fStartAct <> nil) AND (fStartAct^.Next <> nil);
  if Result then
  begin
    aActType := fStartAct^.ActType;
    aPtr := fStartAct^.Ptr;
    tempAct := fStartAct;
    AtomicExchange(fStartAct, fStartAct^.Next);
    Dispose(tempAct);
    Dec(fLiveActionsCnt);
  end;
end;


function TExtAIQueueActions.CallAction(): b;
var
  ActType: TActType;
  ActPtr: Pointer;
begin
  Result := GetAction(ActType, ActPtr);
  if Result then
  begin
    case ActType of
      atGroupOrderAttackUnit:
        begin
          with pRecGroupOrderAttackUnit(ActPtr)^ do
            Actions.GroupOrderAttackUnit(GroupID, UnitID);
          Dispose( pRecGroupOrderAttackUnit(ActPtr) );
        end;
      atGroupOrderWalk:
        begin
          with pRecGroupOrderWalk(ActPtr)^ do
            Actions.GroupOrderWalk(GroupID, X, Y, Direction);
          Dispose( pRecGroupOrderWalk(ActPtr) );
        end;
    end;
  end;
end;


// IActions - definition of functions in the interface
procedure TExtAIQueueActions.GroupOrderAttackUnit(aGroupID: ui32; aUnitID: ui32);
var
  newRec: pRecGroupOrderAttackUnit;
begin
  New(newRec);
  with newRec^ do
  begin
    GroupID := aGroupID;
    UnitID := aUnitID;
  end;
  AddAction(atGroupOrderAttackUnit, newRec);
end;


procedure TExtAIQueueActions.GroupOrderWalk(aGroupID: ui32; aX: ui16; aY: ui16; aDirection: ui16);
var
  newRec: pRecGroupOrderWalk;
begin
  New(newRec);
  with newRec^ do
  begin
    GroupID := aGroupID;
    X := aX;
    Y := aY;
    Direction := aDirection;
  end;
  AddAction(atGroupOrderWalk, newRec);
end;


procedure TExtAIQueueActions.LogDLL(apLog: pwStr; aLen: ui32);
var
  Str: wStr;
begin
  SetLength(Str,aLen);
  Move(apLog^, Str[1], aLen * SizeOf(Str[1]));
  Log(Str);
end;


procedure TExtAIQueueActions.Log(aLog: wStr);
begin
  if Assigned(OnLog) then
    OnLog(aLog);
end;

end.