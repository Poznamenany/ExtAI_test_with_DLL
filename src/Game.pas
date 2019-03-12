unit Game;
interface
uses
  Windows, Classes, Generics.Collections,
  System.Threading, System.Diagnostics, System.SysUtils, Hand,
  ExtAIMaster, HandAI_Ext, ExtAI_SharedTypes, ExtAIUtils;

const
  SLEEP_BEFORE_RUN = 50;
  SLEEP_EVERY_TICK = 1;

type
  TSimulationState = (ssCreated, ssInit, ssInProgress, ssPaused, ssTerminated);
  TUpdateSimStatEvent = procedure of object;

  // The main thread of application (= KP, it contain access to DLL and also Hands and it react to the basic events)
  TGame = class(TThread)
  private
    // Game assets
    fExtAIMaster: TExtAIMaster;
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
    constructor Create(aOnLog: TLogEvent; aOnUpdateSimStatus: TUpdateSimStatEvent); reintroduce;
    destructor Destroy; override;

    // Game properties
    property Tick: Cardinal read fTick;
    property MaxTick: Cardinal read fMaxTick;
    property ExtAIMaster: TExtAIMaster read fExtAIMaster;

    // Game controls
    property SimulationState: TSimulationState read fSimState;
    procedure InitSimulation(aMultithread: Boolean; aExtAIs: TArray<string>; aLogProgress: TLogProgressEvent);
    procedure StartSimulation(aTicks: Cardinal);
    procedure PauseSimulation();
    procedure TerminateSimulation();
  end;

implementation


{ TGame }
constructor TGame.Create(aOnLog: TLogEvent; aOnUpdateSimStatus: TUpdateSimStatEvent);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  Priority := tpHigher;

  fTick := 0;
  fMaxTick := 0;
  fSimState := ssCreated;
  fOnLog := aOnLog;
  fOnUpdateSimStatus := aOnUpdateSimStatus;

  fExtAIMaster := TExtAIMaster.Create(['ExtAI\'], Log);
  fHands := TList<THand>.Create;

  Log('TGame-Create');
end;


destructor TGame.Destroy;
begin
  Log('TGame-Destroy');

  FreeAndNil(fExtAIMaster);
  FreeAndNil(fHands); // Items of list are Interfaces and will be freed automatically

  inherited;
end;


procedure TGame.InitSimulation(aMultithread: Boolean; aExtAIs: TArray<string>; aLogProgress: TLogProgressEvent);
var
  K: Integer;
begin
  Log('TGame-InitSimulation');

  fSimState := ssInit;
  for K := Low(aExtAIs) to High(aExtAIs) do
    if CompareStr(aExtAIs[K], '') <> 0 then
    begin
      fHands.Add(THand.Create(K, Log));
      fHands.Last.SetAIType({hatExtAI});
      fExtAIMaster.RigNewExtAI(fHands.Last.AIExt, aMultithread, aExtAIs[K], aLogProgress);
    end;
end;


procedure TGame.StartSimulation(aTicks: Cardinal);
begin
  Log('TGame-StartSimulation');

  fMaxTick := aTicks;

  Start;
end;


procedure TGame.Execute;
var
  K: Integer;
begin
  Log('TGame-Execute: Start');
  fSimState := ssInProgress;
  fTick := 0;

  while (fSimState <> ssTerminated) and (Tick < fMaxTick) do
  begin
    if (fSimState = ssInProgress) then
    begin
      Inc(fTick);

      // Log status
      Synchronize(
        procedure
        begin
          if Assigned(fOnUpdateSimStatus) then
            fOnUpdateSimStatus;
        end);

      // Do something else (update game logic)
      Sleep(SLEEP_EVERY_TICK);

      // Create new game states (maybe each x. tick)
      //fExtAIMaster.QueueStates.ExtractStates();
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
