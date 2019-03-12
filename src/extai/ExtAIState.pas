unit ExtAIState;
interface
uses
  Windows, Classes,
  System.Threading, System.Diagnostics, System.SysUtils,
  ExtAIUtils, ExtAI_SharedTypes;

type
  pTExtAIState = ^TExtAIState;

  // Store data for ExtAI in 1 tick
  // There is needed another buffer for arrays which will be send to the DLL
  // because they are sent like pointers to first value so ExtAI can replace
  // values in array -> possible trouble
  TExtAIState = class
  private
    fNext: TExtAIState;
    // Thread variables
    fLock: ui32; // Standard read lock
    // Data set
    fTick: ui32; // = ID of this class
    fMapTerrain: ui32Arr;
    //fWalkable: bArr;
    //fTerrain: ui8Arr;
    //...
    fOnLog: TLogEvent;
    // Log
    procedure Log(aLog: wStr);
  public
    fSpecLock: ui32; // Special lock which will lock class till it is not unlocked
    property Next: TExtAIState read fNext write fNext;
    property Tick: ui32 read fTick;
    property Lock: ui32 read fLock;
    property SpecialLock: ui32 read fSpecLock;

    constructor Create(aLog: TLogEvent); reintroduce;
    destructor Destroy(); override;
    procedure DeclareNext();

    // Extract states
    procedure ExtractStates();
    // Distribute states
    function State1(aID: ui32): ui8;
    function MapTerrain(var aLock: TExtAIState; var aFirstElem: pui32; var aLength: si32): b;

    // Lock
    function IsLocked(): b;
    procedure SpecLock(var aLock: TExtAIState);
    procedure SpecUnLock();
  end;

implementation
uses
  Game;


{ TExtAIState }
constructor TExtAIState.Create(aLog: TLogEvent);
begin
  inherited Create();
  fNext := nil;
  fLock := 0;
  fSpecLock := 0;
  fOnLog := aLog;
end;

destructor TExtAIState.Destroy();
begin
  inherited;
end;

procedure TExtAIState.DeclareNext();
begin
  fNext := TExtAIState.Create(fOnLog);
end;


function TExtAIState.IsLocked(): b;
begin
  Result := (fLock + fSpecLock) > 0;
end;


// Extract data which are useful for ExtAI and transform them into usable format
procedure TExtAIState.ExtractStates();
begin
//  fTick := gMainData.Tick;
//  SetLength(fMapTerrain,Length(gMainData.Map));
//  Move(gMainData.Map[0], fMapTerrain[0], Length(fMapTerrain) * SizeOf(fMapTerrain[0]));
end;


function TExtAIState.State1(aID: ui32): ui8;
begin
  AtomicIncrement(fLock);
  // Get the correct data
  Result := 11;
  AtomicDecrement(fLock);
end;

function TExtAIState.MapTerrain(var aLock: TExtAIState; var aFirstElem: pui32; var aLength: si32): b;
begin
  AtomicIncrement(fLock);
  SpecLock(aLock); // Lock class till Map Terrain (or another function which send array) is not called again by same ID => array was copied
  aFirstElem := @fMapTerrain[0]; // Maybe arrays have to be copy into special containers
  aLength := Length(fMapTerrain);
  Result := True;
  AtomicDecrement(fLock);
end;

procedure TExtAIState.SpecLock(var aLock: TExtAIState);
begin
  AtomicIncrement(fSpecLock);
  // Unlock old element if it was locked
  if (aLock <> nil) then
    aLock.SpecUnLock();
  aLock := self;
end;

procedure TExtAIState.SpecUnLock();
begin
  AtomicDecrement(fSpecLock);
end;


procedure TExtAIState.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;

end.