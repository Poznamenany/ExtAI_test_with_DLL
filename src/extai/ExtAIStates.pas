unit ExtAIStates;
{$I KM_CompilerDirectives.inc}
interface
uses
  Windows, System.SysUtils, Math,
  {ExtAIState,} ExtAIUtils, ExtAI_SharedInterfaces, ExtAI_SharedTypes;

type
  // Queue of states for multithreading
  TExtAIStates = class(TInterfacedObject, IStates)
  private
    //fStartStates: TExtAIState;
    //fEndStates: TExtAIState;
    //fLiveStatesCnt: si32;
    //fLastPointer: PTExtAIState;
    //fClassLock: array [0..12] of TExtAIState;
    // Queue
    //procedure FreeUnused(aIgnoreLock: Boolean);
    // IStates
    function State1(aID: ui32): ui8; StdCall;
    function UnitAt(aX: ui16; aY: ui16): ui32; StdCall;
    function MapTerrain(aID: ui8; var aFirstElem: pui32; var aLength: si32): b; StdCall;
    procedure TerrainSize(var aX: ui16; var aY: ui16); StdCall;
    procedure TerrainPassability(var aPassability: pb); StdCall;

    function GetGroupCount(aHandIndex: ui8): ui32;
    procedure GetGroups(aHandIndex: ui8; aFirst: PGroupInfo; aCount: ui32);
    function UnitIsAlive(aUnitUID: ui32): b;
    function GetUnitCount(aHandIndex: ui8): ui32;
    procedure GetUnits(aHandIndex: ui8; aFirst: PUnitInfo; aCount: ui32);
  public
    constructor Create;
    destructor Destroy; override;

    // Extract states
    //procedure ExtractStates();
  end;

implementation
uses
  Log;

{ TExtAIStates }
constructor TExtAIStates.Create;
//var
//  K: Integer;
begin
  inherited Create;
  //fLiveStatesCnt := 0;
  //fStartStates := TExtAIState.Create(fOnLog);
  //Inc(fLiveStatesCnt);
  //fEndStates := fStartStates;
  //for K := Low(fClassLock) to High(fClassLock) do
  //  fClassLock[K] := nil;
  gLog.Log('  TExtAIStates-Create');
end;

destructor TExtAIStates.Destroy;
begin
  gLog.Log('  TExtAIStates-Destroy');
  //FreeUnused(True);
  //fEndStates.Free;
  //Dec(fLiveStatesCnt);
  //if (fLiveStatesCnt <> 0) then
  //  Log('  TExtAIStates-Destroy: States termination error, cnt = ' + IntToStr(fLiveStatesCnt));
  inherited;
end;


{procedure TExtAIStates.FreeUnused(aIgnoreLock: Boolean);
var
  tmp1, tmp2, tmp3: TExtAIState;
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


procedure TExtAIStates.ExtractStates();
begin
  fEndStates.DeclareNext();
  Inc(fLiveStatesCnt);
  fEndStates.Next.ExtractStates();
  fEndStates := fEndStates.Next;
  AtomicExchange(fLastPointer, @fEndStates);
  FreeUnused(False);
end;}


// States
function TExtAIStates.State1(aID: ui32): ui8;
begin
  // Check if request for State1 is correct
  //...
  if (aID <> 11) then
    gLog.Log('  TExtAIStates-State1: Wrong ID');
  // Get State1
  Result := 0; // Some default case
  //if (fEndStates <> nil) then
  //  Result := fLastPointer^.State1(aID);
end;


procedure TExtAIStates.TerrainPassability(var aPassability: pb);
type
  TB = array of Boolean;
var
  I, K: Integer;
begin
  for I := 0 to 15 do
    for K := 0 to 15 do
      TB(aPassability)[I * 16 + K] := InRange(I, 1, 14) and InRange(K, 1, 14);
end;


procedure TExtAIStates.TerrainSize(var aX: ui16; var aY: ui16);
begin
  aX := 16;
  aY := 16;
end;


function TExtAIStates.UnitAt(aX, aY: ui16): ui32;
begin
  Result := 11;
end;


function TExtAIStates.MapTerrain(aID: ui8; var aFirstElem: pui32; var aLength: si32): b;
begin
  // Check if request for MapTerrain is correct
  //...
  // Get State1
  Result := False;
//  if (fLastPointer <> nil) then
//    Result := fLastPointer^.MapTerrain(fClassLock[aID], aFirstElem, aLength);
end;


function TExtAIStates.GetGroupCount(aHandIndex: ui8): ui32;
begin
  Result := 1;
end;


procedure TExtAIStates.GetGroups(aHandIndex: ui8; aFirst: PGroupInfo; aCount: ui32);
var
  I: Integer;
begin
  for I := 0 to aCount - 1 do
  begin
    TGroupInfoArray(aFirst)[1].UID := 12345;
    TGroupInfoArray(aFirst)[1].UnitCount := 1;
  end;
end;


function TExtAIStates.GetUnitCount(aHandIndex: ui8): ui32;
begin
  Result := 1;
end;


procedure TExtAIStates.GetUnits(aHandIndex: ui8; aFirst: PUnitInfo; aCount: ui32);
var
  I: Integer;
begin
  for I := 0 to aCount - 1 do
  begin
    TUnitInfoArray(aFirst)[I].UID := 123;
    TUnitInfoArray(aFirst)[I].PosX := 4;
    TUnitInfoArray(aFirst)[I].PosY := 4;
  end;
end;


function TExtAIStates.UnitIsAlive(aUnitUID: ui32): b;
begin
  Result := True;
end;


end.