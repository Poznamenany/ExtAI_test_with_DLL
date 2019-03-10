unit ExtAIQueueStates;
{$I KM_CompilerDirectives.inc}
interface
uses
  Windows, System.SysUtils, Math,
  {ExtAIStates,} ExtAIUtils, ExtAIInterfaceDelphi, ExtAIDataTypes;

type
  // Queue of states for multithreading
  TExtAIQueueStates = class(TInterfacedObject, IStates)
  private
    //fStartStates: TExtAIStates;
    //fEndStates: TExtAIStates;
    //fLiveStatesCnt: si32;
    //fLastPointer: PTExtAIStates;
    //fClassLock: array [0..12] of TExtAIStates;
    fOnLog: TLogEvent;
    // Queue
    //procedure FreeUnused(aIgnoreLock: Boolean);
    // IStates
    function State1(aID: ui32): ui8; StdCall;
    function UnitAt(aX: ui16; aY: ui16): ui32; StdCall;
    function MapTerrain(aID: ui8; var aFirstElem: pui32; var aLength: si32): b; StdCall;
    procedure TerrainSize(var aX: ui16; var aY: ui16); StdCall;
    procedure TerrainPassability(var aPassability: pb); StdCall;
    // Log
    procedure Log(aLog: wStr);
  public
    constructor Create(aLog: TLogEvent); reintroduce;
    destructor Destroy(); override;

    // Extract states
    //procedure ExtractStates();
  end;

implementation


{ TExtAIQueueStates }
constructor TExtAIQueueStates.Create(aLog: TLogEvent);
//var
//  K: Integer;
begin
  inherited Create();
  fOnLog := aLog;
  //fLiveStatesCnt := 0;
  //fStartStates := TExtAIStates.Create(fOnLog);
  //Inc(fLiveStatesCnt);
  //fEndStates := fStartStates;
  //for K := Low(fClassLock) to High(fClassLock) do
  //  fClassLock[K] := nil;
  Log('  TExtAIQueueStates-Create');
end;

destructor TExtAIQueueStates.Destroy();
begin
  Log('  TExtAIQueueStates-Destroy');
  //FreeUnused(True);
  //fEndStates.Free;
  //Dec(fLiveStatesCnt);
  //if (fLiveStatesCnt <> 0) then
  //  Log('  TExtAIQueueStates-Destroy: States termination error, cnt = ' + IntToStr(fLiveStatesCnt));
  inherited;
end;


{procedure TExtAIQueueStates.FreeUnused(aIgnoreLock: Boolean);
var
  tmp1, tmp2, tmp3: TExtAIStates;
begin
  tmp1 := nil;
  tmp2 := fStartStates;
  if (tmp2 <> nil) then
  begin
    tmp3 := tmp2.Next;
    while (tmp3 <> nil) do
    begin
      if aIgnoreLock OR (NOT tmp2.IsLocked) then
      begin
        if (tmp1 <> nil) then // Secure connection
          tmp1.Next := tmp3
        else if (tmp2 = fStartStates) then // Actualize first class
          fStartStates := tmp3;
        tmp2.Free();
        Dec(fLiveStatesCnt);
      end
      else
        tmp1 := tmp2;
      tmp2 := tmp3;
      tmp3 := tmp3.Next;
    end;
  end;
end;


procedure TExtAIQueueStates.ExtractStates();
begin
  fEndStates.DeclareNext();
  Inc(fLiveStatesCnt);
  fEndStates.Next.ExtractStates();
  fEndStates := fEndStates.Next;
  AtomicExchange(fLastPointer, @fEndStates);
  FreeUnused(False);
end;}


// States
function TExtAIQueueStates.State1(aID: ui32): ui8;
begin
  // Check if request for State1 is correct
  //...
  if (aID <> 11) then
    Log('  TExtAIQueueStates-State1: Wrong ID');
  // Get State1
  Result := 0; // Some default case
  //if (fEndStates <> nil) then
  //  Result := fLastPointer^.State1(aID);
end;


procedure TExtAIQueueStates.TerrainPassability(var aPassability: pb);
type
  TB = array of Boolean;
var
  I, K: Integer;
begin
  for I := 0 to 15 do
    for K := 0 to 15 do
      TB(aPassability)[I * 16 + K] := InRange(I, 1, 14) and InRange(K, 1, 14);
end;


procedure TExtAIQueueStates.TerrainSize(var aX: ui16; var aY: ui16);
begin
  aX := 16;
  aY := 16;
end;


function TExtAIQueueStates.UnitAt(aX, aY: ui16): ui32;
begin
  Result := 11;
end;


function TExtAIQueueStates.MapTerrain(aID: ui8; var aFirstElem: pui32; var aLength: si32): b;
begin
  // Check if request for MapTerrain is correct
  //...
  // Get State1
  Result := False;
//  if (fLastPointer <> nil) then
//    Result := fLastPointer^.MapTerrain(fClassLock[aID], aFirstElem, aLength);
end;


procedure TExtAIQueueStates.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;


end.