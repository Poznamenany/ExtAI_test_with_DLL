unit ExtAIQueueEvents;
interface
uses
  Windows, System.SysUtils,
  ExtAIQueueActions, ExtAIUtils, ExtAIInterfaceDelphi, ExtAIDataTypes;

type
  TEvType = (etOnMissionStart, etOnTick, etOnPlayerDefeated, etOnPlayerVictory);

  TRecOnMissionStart = record end;
  TRecOnTick = record Tick: ui32; end;
  TRecOnPlayerDefeated = record Player: si8; end;
  TRecOnPlayerVictory = record Player: si8; end;

  pRecOnMissionStart = ^TRecOnMissionStart;
  pRecOnTick = ^TRecOnTick;
  pRecOnPlayerDefeated = ^TRecOnPlayerDefeated;
  pRecOnPlayerVictory = ^TRecOnPlayerVictory;

  pEv = ^TEv;
  TEv = record
    EvType: TEvType;
    Ptr: Pointer;
    Next: pEv;
  end;

// Queue of events for multithreading
TExtAIQueueEvents = class(TInterfacedObject, IEvents)
private
  fID: ui8;
  fStartEv: pEv;
  fEndEv: pEv;
  fLiveEventsCnt: si32;
  // IEvents
  procedure OnMissionStart(); StdCall;
  procedure OnTick(aTick: ui32); StdCall;
  procedure OnPlayerDefeated(aPlayer: si8); StdCall;
  procedure OnPlayerVictory(aPlayer: si8); StdCall;
  // Queue
  procedure AddEvent(aEvType: TEvType; aPtr: Pointer);
  function GetEvent(var aEvType: TEvType; var aPtr: Pointer): b;
  // Log
  procedure Log(aLog: wStr);
public
  OnLog: TLogEvent;
  Events: IEvents;
  QueueActions: TExtAIQueueActions;
  constructor Create(aID: ui8; aLog: TLogEvent); reintroduce;
  destructor Destroy(); override;

  function CallEvent(var aTick: ui32): b;
end;

implementation


{ TExtAIQueueEvents }
constructor TExtAIQueueEvents.Create(aID: ui8; aLog: TLogEvent);
begin
  inherited Create();
  fID := aID;
  OnLog := aLog;
  fLiveEventsCnt := 0;
  New(fStartEv); // 1 Event is empty and divides start and end pointer
  Inc(fLiveEventsCnt);
  fStartEv.Next := nil;
  fEndEv := fStartEv;
  Log('  TExtAIQueueEvents-Create: ID = '+IntToStr(fID));
end;

destructor TExtAIQueueEvents.Destroy();
var
  EvType: TEvType;
  EvPtr: Pointer;
begin
  Log('  TExtAIQueueEvents-Destroy: ID = '+IntToStr(fID));
  while GetEvent(EvType, EvPtr) do
  begin
    case EvType of
      etOnMissionStart:   Dispose( pRecOnMissionStart(EvPtr) );
      etOnTick:           Dispose( pRecOnTick(EvPtr) );
      etOnPlayerDefeated: Dispose( pRecOnPlayerDefeated(EvPtr) );
      etOnPlayerVictory:  Dispose( pRecOnPlayerVictory(EvPtr) );
    end;
  end;
  if (fStartEv <> nil) then // Last Event
  begin
    Dispose(fStartEv);
    Dec(fLiveEventsCnt);
  end;
  if (fLiveEventsCnt <> 0) then
    Log('  TExtAIQueueEvents-Destroy: Events termination error, ID = ' + IntToStr(fID) + '; cnt = '+IntToStr(fLiveEventsCnt));

  inherited;
end;


procedure TExtAIQueueEvents.AddEvent(aEvType: TEvType; aPtr: Pointer);
var
  newEv: pEv;
begin
  New(newEv);
  Inc(fLiveEventsCnt);
  newEv^.Next := nil;
  fEndEv^.EvType := aEvType;
  fEndEv^.Ptr := aPtr;
  AtomicExchange(fEndEv^.Next, newEv);
  fEndEv := newEv;
end;


function TExtAIQueueEvents.GetEvent(var aEvType: TEvType; var aPtr: Pointer): b;
var
  tempEv: pEv;
begin
  Result := (fStartEv <> nil) AND (fStartEv^.Next <> nil);
  if Result then
  begin
    aEvType := fStartEv^.EvType;
    aPtr := fStartEv^.Ptr;
    tempEv := fStartEv;
    AtomicExchange(fStartEv, fStartEv^.Next);
    Dispose(tempEv);
    Dec(fLiveEventsCnt);
  end;
end;


function TExtAIQueueEvents.CallEvent(var aTick: ui32): b;
var
  EvType: TEvType;
  EvPtr: Pointer;
  tckvptr: pRecOnTick;
begin
  Result := GetEvent(EvType, EvPtr);
  if Result then
  begin
    case EvType of
      etOnMissionStart:
        begin
          with pRecOnMissionStart(EvPtr)^ do
            Events.OnMissionStart();
          Dispose( pRecOnMissionStart(EvPtr) );
        end;
      etOnTick:
        begin
          tckvptr := pRecOnTick(EvPtr);
          with tckvptr^ do
          begin
            Events.OnTick(Tick);
            aTick := Tick;
          end;
          Dispose( pRecOnTick(EvPtr) );
        end;
      etOnPlayerDefeated:
        begin
          with pRecOnPlayerDefeated(EvPtr)^ do
            Events.OnPlayerDefeated(Player);
          Dispose( pRecOnPlayerDefeated(EvPtr) );
        end;
      etOnPlayerVictory:
        begin
          with pRecOnPlayerVictory(EvPtr)^ do
            Events.OnPlayerVictory(Player);
          Dispose( pRecOnPlayerVictory(EvPtr) );
        end;
    end;
  end;
end;


// IEvents - definition of functions in the interface
procedure TExtAIQueueEvents.OnMissionStart();
var
  newRec: pRecOnMissionStart;
begin
  New(newRec);
  with newRec^ do
  begin
  end;
  AddEvent(etOnMissionStart, newRec);
end;

procedure TExtAIQueueEvents.OnTick(aTick: ui32);
var
  newRec: pRecOnTick;
begin
  // Call actions
  while QueueActions.CallAction do
  begin
    // ...
  end;
  New(newRec);
  with newRec^ do
  begin
    Tick := aTick;
  end;
  AddEvent(etOnTick, newRec);
end;

procedure TExtAIQueueEvents.OnPlayerDefeated(aPlayer: si8);
var
  newRec: pRecOnPlayerDefeated;
begin
  New(newRec);
  with newRec^ do
  begin
    Player := aPlayer;
  end;
  AddEvent(etOnPlayerDefeated, newRec);
end;

procedure TExtAIQueueEvents.OnPlayerVictory(aPlayer: si8);
var
  newRec: pRecOnPlayerVictory;
begin
  New(newRec);
  with newRec^ do
  begin
    Player := aPlayer;
  end;
  AddEvent(etOnPlayerVictory, newRec);
end;


procedure TExtAIQueueEvents.Log(aLog: wStr);
begin
  if Assigned(OnLog) then
    OnLog(aLog);
end;

end.