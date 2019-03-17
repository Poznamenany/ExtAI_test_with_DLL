unit Game;
interface
uses
  Windows, Classes, Generics.Collections,
  System.Threading, System.Diagnostics, System.SysUtils, Hand,
  ExtAIMaster, HandAI_Ext, ExtAI_SharedTypes, ExtAI_SharedInterfaces, ExtAIUtils;

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
    fHands: TObjectList<THand>; // ExtAI hand entry point

    // Game properties (kind of testbed)
    fTick: Cardinal;
    fMaxTick: Cardinal;

    // Purely testbed things
    fSimState: TSimulationState;
    fOnUpdateSimStatus: TUpdateSimStatEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(aOnUpdateSimStatus: TUpdateSimStatEvent); reintroduce;
    destructor Destroy; override;

    // Game properties
    property Tick: Cardinal read fTick;
    property MaxTick: Cardinal read fMaxTick;
    property ExtAIMaster: TExtAIMaster read fExtAIMaster;

    // Game controls
    property SimulationState: TSimulationState read fSimState;
    procedure InitSimulation(aMultithread: Boolean; aExtAIIndex: TArray<Integer>; aLogProgress: TLogProgressEvent);
    procedure StartSimulation(aTicks: Cardinal);
    procedure PauseSimulation();
    procedure TerminateSimulation();
  end;

implementation
uses
  Log;

{ TGame }
constructor TGame.Create(aOnUpdateSimStatus: TUpdateSimStatEvent);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  Priority := tpHigher;

  fTick := 0;
  fMaxTick := 0;
  fSimState := ssCreated;
  fOnUpdateSimStatus := aOnUpdateSimStatus;

  fExtAIMaster := TExtAIMaster.Create(['ExtAI\']);
  fHands := TObjectList<THand>.Create;

  gLog.Log('TGame-Create');
end;


destructor TGame.Destroy;
begin

  FreeAndNil(fHands);
  // @Krom:
  // The main class of KP is an equivalent of form TPPLWin and TGame is in the KP main class of mission
  // It means that fExtAIMaster should be declared in TPPLWin and should not be terminated till app ends
  // DLLs must be released after mission end while fExtAIMaster lives in the main class of KP
  fExtAIMaster.ReleaseDLLs; // In KP call just this part
  FreeAndNil(fExtAIMaster); // fExtAIMaster lives in main KP class

  gLog.Log('TGame-Destroy');
  inherited;
end;


procedure TGame.InitSimulation(aMultithread: Boolean; aExtAIIndex: TArray<Integer>; aLogProgress: TLogProgressEvent);
var
  K: Integer;
begin
  gLog.Log('TGame-InitSimulation');

  fSimState := ssInit;
  for K := Low(aExtAIIndex) to High(aExtAIIndex) do
  if aExtAIIndex[K] >= 0 then
  begin
    fHands.Add(THand.Create(K));
    fHands.Last.SetAIType({hatExtAI});
    fHands.Last.AIExt.SetIndex(aExtAIIndex[K], fExtAIMaster, aMultithread, aLogProgress);
  end;
end;


procedure TGame.StartSimulation(aTicks: Cardinal);
begin
  gLog.Log('TGame-StartSimulation');

  fMaxTick := aTicks;

  Start;
end;


procedure TGame.Execute;
var
  K: Integer;
begin
  gLog.Log('TGame-Execute: Start');
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
  gLog.Log('TGame-Execute: End');
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
  gLog.Log('TGame-TerminateSimulation');
  fSimState := ssTerminated;
end;


end.
