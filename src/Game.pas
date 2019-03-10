unit Game;
interface
uses
  Windows, Classes, Generics.Collections,
  System.Threading, System.Diagnostics, System.SysUtils, Hand,
  ExtAIMain, ExtAIListDLL, HandAI_Ext, ExtAIDataTypes, ExtAIUtils;

const
  SLEEP_BEFORE_RUN = 50;
  SLEEP_EVERY_TICK = 1;
  MAP_LENGTH = 255*255*10;

var
  // Global variable with informations (informations which ExtAI needs during the simulation)
  gMainData: record
    Tick: ui32;
    Map: ui32Arr;
    //...
  end;

type
  TSimulationState = (ssCreated, ssInit, ssInProgress, ssPaused, ssTerminated);
  TUpdateSimStatEvent = procedure () of object;

  // The main thread of application (= KP, it contain access to DLL and also Hands and it react to the basic events)
  TGame = class(TThread)
  private
    // Game assets
    fExtAI: TExtAIMain; // ExtAI DLL entry point
    fHands: TList<THand>; // ExtAI hand entry point

    // Game properties (kind of testbed)
    fTick: Cardinal;
    fMaxTick: Cardinal;

    // Purely testbed things
    fSimState: TSimulationState;
    fOnUpdateSimStatus: TUpdateSimStatEvent;
    fOnLog: TLogEvent;
    procedure Log(aLog: wStr);
  protected
    procedure Execute; override;
  public
    constructor Create(aInitLog: TLogEvent; aOnUpdateSimStatus: TUpdateSimStatEvent); reintroduce;
    destructor Destroy; override;

    // Game properties
    property Tick: Cardinal read fTick;
    property MaxTick: Cardinal read fMaxTick;
    function GetDLLs(aPaths: wStrArr): TListDLL;

    // Game controls
    property SimulationState: TSimulationState read fSimState;
    procedure InitSimulation(aMultithread: Boolean; aExtAIs: wStrArr; aLogProgress: TLogProgressEvent);
    procedure StartSimulation(aTicks: Cardinal);
    procedure PauseSimulation();
    procedure TerminateSimulation();
  end;

implementation


{ TGame }
constructor TGame.Create(aInitLog: TLogEvent; aOnUpdateSimStatus: TUpdateSimStatEvent);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  Priority := tpHigher;

  fTick := 0;
  fMaxTick := 0;
  fSimState := ssCreated;
  fOnLog := aInitLog;
  fOnUpdateSimStatus := aOnUpdateSimStatus;
  Log('TGame-Create');
  fExtAI := TExtAIMain.Create(Log);
  fHands := TList<THand>.Create;
end;

destructor TGame.Destroy();
begin
  FreeAndNil(fExtAI);
  FreeAndNil(fHands); // Items of list are Interfaces and will be freed automatically
  Log('TGame-Destroy');
  inherited;
end;

function TGame.GetDLLs(aPaths: wStrArr): TListDLL;
begin
  fExtAI.ListDLL.SetDLLFolderPaths(aPaths);
  Result := fExtAI.ListDLL.List.Copy();
end;

procedure TGame.InitSimulation(aMultithread: Boolean; aExtAIs: wStrArr; aLogProgress: TLogProgressEvent);
var
  K: si32;
begin
  Log('TGame-InitSimulation');
  fSimState := ssInit;
  for K := Low(aExtAIs) to High(aExtAIs) do
    if CompareStr(aExtAIs[K], '') <> 0 then
      //@Martin here's a hand index mismatch. In KP hands are always going from 0 to N-1, without gaps.
      //@Krom I know but all variables are also initialized to 0 and I wanted to be 100% sure that ID is sent to DLL
      //      ID is decided by Game so you can easily change it in the KP
    begin
      fHands.Add(THand.Create(K, fOnLog));
      fHands.Last.SetAIType(fExtAI.NewExtAI(aMultithread, K+1, aExtAIs[K], fOnLog, aLogProgress));
    end;
end;

procedure TGame.StartSimulation(aTicks: Cardinal);
begin
  Log('TGame-StartSimulation');

  fMaxTick := aTicks;

  Start;
end;

procedure TGame.Execute();
var
  K: si32;
begin
  Log('TGame-Execute: Start');
  fSimState := ssInProgress;
  fTick := 0;
  gMainData.Tick := Tick;
  SetLength(gMainData.Map,MAP_LENGTH);
  while (fSimState <> ssTerminated) AND (Tick < fMaxTick) do
  begin
    if (fSimState = ssInProgress) then
    begin
      Inc(fTick);
      gMainData.Tick := Tick;
      fOnUpdateSimStatus(); // Log status
      // Update map
      for K := Low(gMainData.Map) to High(gMainData.Map) do
        gMainData.Map[K] := K;
      // Do something else (update game logic)
      Sleep(SLEEP_EVERY_TICK);
      // Create new game states (maybe each x. tick)
      fExtAI.QueueStates.ExtractStates();
      // Call ExtAI (Hands)
      for K := 0 to fHands.Count-1 do
        if (fHands[K] <> nil) then
          fHands[K].UpdateState(Tick);
    end
    else
      Sleep(SLEEP_BEFORE_RUN);
  end;

  fSimState := ssTerminated;
  fTick := 0;
  fOnUpdateSimStatus();
  Log('TGame-Execute: End');
end;

procedure TGame.PauseSimulation();
begin
  if (fSimState = ssPaused) then
    fSimState := ssInProgress
  else
    fSimState := ssPaused;
end;

procedure TGame.TerminateSimulation();
begin
  Log('TGame-TerminateSimulation');
  fSimState := ssTerminated;
end;


procedure TGame.Log(aLog: wStr);
begin
  Synchronize(
    procedure
    begin
      if Assigned(fOnLog) then
        fOnLog(aLog);
    end);
end;


end.
