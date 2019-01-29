unit ExtAIQueueStates;
interface
uses
  Windows, System.SysUtils,
  ExtAIStates, ExtAIUtils, ExtAIInterfaceDelphi, ExtAIDataTypes;

type

// Queue of states for multithreading
TExtAIQueueStates = class(TInterfacedObject, IStates)
private
  fStartStates: TExtAIStates;
  fEndStates: TExtAIStates;
  fOnLog: TLog;
  // Queue
  procedure FreeUnused();
  // IStates
  function State1(aID: ui32): ui8; StdCall;
  function MapTerrain(var aFirstElem: pui32; var aLength: si32): b; StdCall;
  // Log
  procedure Log(aLog: wStr);
public
  constructor Create(aLog: TLog); reintroduce;
  destructor Destroy(); override;

  // Extract states
  procedure ExtractStates();
end;

implementation


{ TExtAIQueueStates }
constructor TExtAIQueueStates.Create(aLog: TLog);
begin
  inherited Create();
  fOnLog := aLog;
  fStartStates := nil;
  fEndStates := nil;
  Log('  TExtAIQueueStates-Create');
end;

destructor TExtAIQueueStates.Destroy();
begin
  Log('  TExtAIQueueStates-Destroy');
  FreeUnused();
  fEndStates.Free;
  inherited;
end;


procedure TExtAIQueueStates.FreeUnused();
var
  tmp1, tmp2: TExtAIStates;
begin
  tmp1 := fStartStates;
  while (tmp1 <> nil) AND (tmp1.Next <> nil)do
    if NOT tmp1.IsLocked then
    begin
      tmp2 := tmp1;
      tmp1 := tmp1.Next;
      if (tmp2 = fStartStates) then // Free first element
        fStartStates := tmp1;
      tmp2.Free();
    end;
end;

procedure TExtAIQueueStates.ExtractStates();
begin
  fEndStates.Next := TExtAIStates.Create(fOnLog);
  fEndStates := fEndStates.Next;
  fEndStates.ExtractStates();
  FreeUnused();
end;


// States
function TExtAIQueueStates.State1(aID: ui32): ui8;
begin
  // Check if request for State1 is correct
  //...
  // Get State1
  Result := 0; // Some default case
  if (fEndStates <> nil) then
    Result := fEndStates.State1(aID);
end;

function TExtAIQueueStates.MapTerrain(var aFirstElem: pui32; var aLength: si32): b;
begin
  // Check if request for MapTerrain is correct
  //...
  // Get State1
  Result := False;
  if (fEndStates <> nil) then
    Result := fEndStates.MapTerrain(aFirstElem, aLength);
end;


procedure TExtAIQueueStates.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;

end.