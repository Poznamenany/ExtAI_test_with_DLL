unit GameThread;
interface
uses
  Windows, Classes,
  System.Threading, System.Diagnostics, System.SysUtils,
  ExtAIMain, ExtAIListDLL, ExtAIHand, ExtAIDataTypes, ExtAIUtils;

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
  TUpdateSimStatus = procedure () of object; //@Martin: According to KP/Delphi conventions, this should be renamed to TUpdateSimStatusEvent

  // The main thread of application (= KP, it contain access to DLL and also Hands and it react to the basic events)
  TGameThread = class(TThread)
  private
    fTick: Cardinal;
    fMaxTick: Cardinal;

    fExtAI: TExtAIMain; // ExtAI DLL entry point
    fHands: TList; // ExtAI hand entry point
    fSimState: TSimulationState;
    fUpdateSimStatus: TUpdateSimStatus; //@Martin: According to Delphi conventions, this should be renamed to fOnUpdateSimStatus
    fOnLog: TLogEvent;
    procedure Log(aLog: wStr);
  public
    constructor Create(aInitLog: TLogEvent; aUpdateSimStatus: TUpdateSimStatus); reintroduce;
    destructor Destroy(); override;

    function GetDLLs(aPaths: wStrArr): TListDLL;
    property SimulationState: TSimulationState read fSimState;
    property Tick: Cardinal read fTick;
    property MaxTick: Cardinal read fMaxTick;

    procedure InitSimulation(aMultithread: Boolean; aExtAIs: wStrArr; aLogProgress: TLogProgressEvent);
    procedure StartSimulation(aTicks: Cardinal);
    procedure PauseSimulation();
    procedure TerminateSimulation();

    procedure Execute(); override;
  end;

implementation


{ TGameThread }
constructor TGameThread.Create(aInitLog: TLogEvent; aUpdateSimStatus: TUpdateSimStatus);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  Priority := tpHigher;

  fTick := 0;
  fMaxTick := 0;
  fSimState := ssCreated;
  fOnLog := aInitLog;
  fUpdateSimStatus := aUpdateSimStatus;
  Log('TMainThread-Create');
  fExtAI := TExtAIMain.Create(Log);
  fHands := TList.Create();
end;

destructor TGameThread.Destroy();
begin
  fExtAI.Free();
  fHands.Free(); // Items of list are Interfaces and will be freed automatically
  Log('TMainThread-Destroy');
  inherited;
end;

function TGameThread.GetDLLs(aPaths: wStrArr): TListDLL;
begin
  fExtAI.ListDLL.SetDLLFolderPaths(aPaths);
  Result := fExtAI.ListDLL.List.Copy();
end;

procedure TGameThread.InitSimulation(aMultithread: Boolean; aExtAIs: wStrArr; aLogProgress: TLogProgressEvent);
var
  K: si32;
begin
  Log('TMainThread-InitSimulation');
  fSimState := ssInit;
  for K := Low(aExtAIs) to High(aExtAIs) do
    if (CompareStr(aExtAIs[K],'') <> 0) then
      fHands.Add( fExtAI.NewExtAI(aMultithread, K+1, aExtAIs[K], fOnLog, aLogProgress));
end;

procedure TGameThread.StartSimulation(aTicks: Cardinal);
var
  K,L: si32;
begin
  Log('TMainThread-StartSimulation');

  fMaxTick := aTicks;

  for L := 0 to fHands.Count-1 do
    if (fHands[L] <> nil) then
    begin
      TExtAIHand(fHands[L]).OnMissionStart();
      //...
    end;

  Start;
end;

procedure TGameThread.Execute();
var
  K: si32;
begin
  Log('TMainThread-Execute: Start');
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
      fUpdateSimStatus(); // Log status
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
        begin
          TExtAIHand(fHands[K]).OnTick(Tick);
          //... and another events
        end;
    end
    else
      Sleep(SLEEP_BEFORE_RUN);
  end;

  fSimState := ssTerminated;
  fTick := 0;
  fUpdateSimStatus();
  Log('TMainThread-Execute: End');
end;

procedure TGameThread.PauseSimulation();
begin
  if (fSimState = ssPaused) then
    fSimState := ssInProgress
  else
    fSimState := ssPaused;
end;

procedure TGameThread.TerminateSimulation();
begin
  Log('TMainThread-TerminateSimulation');
  fSimState := ssTerminated;
end;


procedure TGameThread.Log(aLog: wStr);
begin
  Synchronize(
  procedure
  begin
    if Assigned(fOnLog) then
      fOnLog(aLog);
  end);
end;


end.
