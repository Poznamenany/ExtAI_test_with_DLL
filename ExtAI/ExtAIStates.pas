unit ExtAIStates;
interface
uses
  Windows, Classes,
  System.Threading, System.Diagnostics, System.SysUtils,
  ExtAIUtils, ExtAIDataTypes;

type

// Store data for ExtAI in 1 tick
// There is needed another buffer for arrays which will be send to the DLL
// because they are sent like pointers to first value so ExtAI can replace
// values in arraz -> possible trouble
TExtAIStates = class
private
  // Thread variables
  fLock: ui32; // Standard read lock
  fSpecLock: ui32; // Special lock which will lock class till it is not unlocked
  // Data set
  fTick: ui32; // = ID of this class
  fMapTerrain: ui32Arr;
  //fWalkable: bArr;
  //fTerrain: ui8Arr;
  //...
  fOnLog: TLog;
  // Log
  procedure Log(aLog: wStr);
public
  Next: TExtAIStates;
  property Tick: ui32 read fTick;
  property Lock: ui32 read fLock;
  property SpecialLock: ui32 read fSpecLock;

  constructor Create(aLog: TLog); reintroduce;
  destructor Destroy(); override;

  // Extract states
  procedure ExtractStates();
  // Distribute states
  function State1(aID: ui32): ui8;
  function MapTerrain(var aFirstElem: pui32; var aLength: si32): b;

  // Lock
  function IsLocked(): b;
  procedure SpecLock();
  procedure SpecUnLock();
end;

implementation
uses MainThread;


{ TExtAIStates }
constructor TExtAIStates.Create(aLog: TLog);
begin
  inherited Create();
  Next := nil;
  fLock := 0;
  fSpecLock := 0;
  fOnLog := aLog;
end;

destructor TExtAIStates.Destroy();
begin
  inherited;
end;


function TExtAIStates.IsLocked(): b;
begin
  Result := (fLock + fSpecLock) > 0;
end;


// Extract data which are useful for ExtAI and transform them into usable format
procedure TExtAIStates.ExtractStates();
begin
  fTick := gMainData.Tick;
  SetLength(fMapTerrain,Length(gMainData.Map));
  Move(fMapTerrain[0], gMainData.Map[0], Length(fMapTerrain) * SizeOf(fMapTerrain[0]));
end;


function TExtAIStates.State1(aID: ui32): ui8;
begin
  AtomicIncrement(fLock);
  // Get the correct data
  Result := 1;
  AtomicDecrement(fLock);
end;

function TExtAIStates.MapTerrain(var aFirstElem: pui32; var aLength: si32): b;
begin
  AtomicIncrement(fLock);
  aFirstElem := @fMapTerrain[0]; // Arrays will have to be copied into special containers so
  aLength := Length(fMapTerrain);
  Result := True;
  AtomicDecrement(fLock);
end;

procedure TExtAIStates.SpecLock();
begin
  AtomicIncrement(fSpecLock);
end;

procedure TExtAIStates.SpecUnLock();
begin
  AtomicDecrement(fSpecLock);
end;


procedure TExtAIStates.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;

end.