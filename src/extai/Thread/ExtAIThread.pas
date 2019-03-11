unit ExtAIThread;
interface
uses
  Windows, Classes,
  System.Threading, System.Diagnostics, System.SysUtils,
  ExtAIQueueEvents, ExtAIUtils, ExtAI_SharedTypes;

const
  SLEEP_BEFORE_RUN = 1;
  SLEEP_BEFORE_NEXT_TICK = 1;

type
  // Thread management for ExtAI (optional)
  TExtAIThread = class(TThread)
  private
    fHandIndex: Integer;
    fState: TExtAIThreadState;
    fOnLog: TLogEvent;
    fOnLogProgress: TLogProgressEvent;
    fLastTick: ui32;
    fQueueEvents: TExtAIQueueEvents;
    procedure SetState(aState: TExtAIThreadState);
    procedure Log(aLog: wStr);
    procedure LogProgress();
  public
    property HandIndex: Integer read fHandIndex;
    property State: TExtAIThreadState read fState write SetState;

    constructor Create(aHandIndex: Integer; aLog: TLogEvent; aLogProgress: TLogProgressEvent; var aThreadLog: TLogEvent); reintroduce;
    destructor Destroy(); override;

    procedure Init(aQueueEvents: TExtAIQueueEvents);
    procedure Execute(); override;
  end;

implementation


{ TExtAIThread }
constructor TExtAIThread.Create(aHandIndex: Integer; aLog: TLogEvent; aLogProgress: TLogProgressEvent; var aThreadLog: TLogEvent);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  Priority := tpNormal;

  fHandIndex := aHandIndex;
  fOnLog := aLog;
  fOnLogProgress := aLogProgress;
  fQueueEvents := nil;
  fLastTick := 0;
  aThreadLog := Log;
  State := tsInit;
  LogProgress();
  Log('  TExtAIThread-Create: HandIndex = '+IntToStr(fHandIndex));
end;

destructor TExtAIThread.Destroy();
begin
  Log('  TExtAIThread-Destroy: HandIndex = '+IntToStr(fHandIndex));
  inherited;
end;

procedure TExtAIThread.Init(aQueueEvents: TExtAIQueueEvents);
begin
  fQueueEvents := aQueueEvents;
end;

procedure TExtAIThread.Execute();
var
  cnt: ui32;
begin
  State := tsRun;
  while (State <> tsTerminate) do
  begin
    // Check if there are new events
    if (fQueueEvents <> nil) then
    begin
      cnt := 0;
      while fQueueEvents.CallEvent(fLastTick) do
      begin
        LogProgress();
        Inc(Cnt);
      end;
      // Sleep if there are not
      if (Cnt = 0) then
        Sleep(SLEEP_BEFORE_NEXT_TICK);
    end
    else
      Sleep(SLEEP_BEFORE_RUN);
  end;
end;


procedure TExtAIThread.SetState(aState: TExtAIThreadState);
begin
  if (fState <> aState) then
  begin
    fState := aState;
    LogProgress();
  end;
end;


procedure TExtAIThread.Log(aLog: wStr);
begin
  Synchronize(
  procedure
  begin
    if Assigned(fOnLog) then
      fOnLog(aLog);
  end);
end;

procedure TExtAIThread.LogProgress();
begin
  Synchronize(
  procedure
  begin
    if Assigned(fOnLogProgress) then
      fOnLogProgress(fHandIndex, fLastTick, fState);
  end);
end;


end.
