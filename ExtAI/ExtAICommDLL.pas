unit ExtAICommDLL;
interface
uses
  Classes, Windows, System.SysUtils,
  ExtAIQueueActions, ExtAIQueueEvents, ExtAIQueueStates, ExtAIThread,
  ExtAIHand, ExtAIInterfaceDelphi, ExtAIDataTypes, ExtAIUtils;

type
  TInitDLL = procedure(var aConfig: TDLLpConfig); StdCall;
  TTerminDLL = procedure(); StdCall;
  TInitNewExtAI = procedure(aID: ui8; aActions: IActions; aStates: IStates) StdCall;
  TNewExtAI = function(): IEvents; SafeCall; // Same like StdCall but allows exceptions

  // Communication with 1 physical DLL with using exported methods.
  // Main targets: initialization of DLL, creation of ExtAIs and termination of DLL and ExtAIs
  TExtAICommDLL = class
  private
    fDLLConfig: TDLLMainCfg;
    fLibHandle: THandle;
    fExtAIThread: TList;

    fOnInitDLL: TInitDLL;
    fOnTerminDLL: TTerminDLL;
    fOnInitNewExtAI: TInitNewExtAI;
    fOnNewExtAI: TNewExtAI;

    fOnLog: TLog;
    procedure Log(aLog: wStr);
  public
    property Config: TDLLMainCfg read fDLLConfig;

    constructor Create(aLog: TLog); reintroduce;
    destructor Destroy(); override;

    function LinkDLL(aDLLPath: wStr): b;
    function CreateNewExtAI(aOwnThread: b; aExtAIID: ui8; aInitLog: TLog; aLogProgress: TLogProgress; var aStates: TExtAIQueueStates): TExtAIHand;
  end;

implementation


{ TExtAICommDLL }
constructor TExtAICommDLL.Create(aLog: TLog);
begin
  inherited Create();
  fOnLog := aLog;
  fExtAIThread := TList.Create();
  Log('  CommDLL-Create');
end;

destructor TExtAICommDLL.Destroy();
var
  K: si32;
begin
  Log('  CommDLL-Destroy: ExtAI name = ' + fDLLConfig.ExtAIName);

  for K := 0 to fExtAIThread.Count-1 do
    if (TExtAIThread(fExtAIThread[K]).State = tsRun) then
    begin
      Log('  CommDLL-Destroy: Wait for thread ID = ' + IntToStr(TExtAIThread(fExtAIThread[K]).ID));
      TExtAIThread(fExtAIThread[K]).State := tsTerminate;
      TExtAIThread(fExtAIThread[K]).WaitFor;
    end;

  if Assigned(fOnTerminDLL) then
    fOnTerminDLL(); // = remove reference from ExtAIAPI

  for K := 0 to fExtAIThread.Count-1 do
    TExtAIThread(fExtAIThread[K]).Free();
  FreeAndNil(fExtAIThread);

  FreeLibrary(fLibHandle);
  inherited;
end;


function TExtAICommDLL.LinkDLL(aDLLPath: wStr): b;
var
  Cfg: TDLLpConfig;
begin
  Result := False;
  if fileexists(aDLLPath) then
  begin
    fLibHandle := SafeLoadLibrary( aDLLPath );
    if (fLibHandle <> 0) then
    begin
      Log('  CommDLL-LinkDLL: DLL file detected, last error (should be 0): ' + IntToStr( GetLastError() ));
      Result := True;

      fOnInitDLL := GetProcAddress(fLibHandle, 'InitDLL');
      fOnTerminDLL := GetProcAddress(fLibHandle, 'TerminDLL');
      fOnNewExtAI := GetProcAddress(fLibHandle, 'NewExtAI');
      fOnInitNewExtAI := GetProcAddress(fLibHandle, 'InitNewExtAI');

      if Assigned(fOnInitDLL)
      AND Assigned(fOnTerminDLL)
      AND Assigned(fOnNewExtAI)
      AND Assigned(fOnInitNewExtAI) then
      begin
        Result := True;
        fDLLConfig.Path := aDLLPath;
        fOnInitDLL(Cfg);
        SetLength(fDLLConfig.Author, Cfg.AuthorLen);
        Move(Cfg.Author^, fDLLConfig.Author[1], Cfg.AuthorLen * SizeOf(fDLLConfig.Author[1]));
        SetLength(fDLLConfig.Description, Cfg.DescriptionLen);
        Move(Cfg.Description^, fDLLConfig.Description[1], Cfg.DescriptionLen * SizeOf(fDLLConfig.Description[1]));
        SetLength(fDLLConfig.ExtAIName, Cfg.ExtAINameLen);
        Move(Cfg.ExtAIName^, fDLLConfig.ExtAIName[1], Cfg.ExtAINameLen * SizeOf(fDLLConfig.ExtAIName[1]));
        fDLLConfig.Version := Config.Version;
        Log('  CommDLL-LinkDLL: DLL detected, DLL Name: ' + fDLLConfig.ExtAIName + '; Version: ' + IntToStr(fDLLConfig.Version));
      end;
    end
    else
      Log('  CommDLL-LinkDLL: library was NOT loaded, error: ' + IntToStr( GetLastError() ));
  end
  else
    Log('  CommDLL-LinkDLL: DLL file was NOT found');
end;


function TExtAICommDLL.CreateNewExtAI(aOwnThread: b; aExtAIID: ui8; aInitLog: TLog; aLogProgress: TLogProgress; var aStates: TExtAIQueueStates): TExtAIHand;
var
  Thread: TExtAIThread;
  Hand: TExtAIHand;
  ThreadLog: TLog;
  QueueActions: TExtAIQueueActions;
  QueueEvents: TExtAIQueueEvents;
begin
  Result := nil;
  if (Assigned(fOnNewExtAI)) then
  begin
    //Log('  CommDLL-CreateNewExtAI: ID = ' + IntToStr(aExtAIID));
    Hand := TExtAIHand.Create(aExtAIID, fOnLog);
    try
      if aOwnThread then
      begin
        // Create thread
        Thread := TExtAIThread.Create(aExtAIID, aInitLog, aLogProgress, ThreadLog);
        // Create interfaces
        QueueActions := TExtAIQueueActions.Create(aExtAIID, ThreadLog);
        QueueActions.Actions := Hand; // = add reference to TExtAIHand
        QueueEvents := TExtAIQueueEvents.Create(aExtAIID, ThreadLog);
        QueueEvents.Events := fOnNewExtAI(); // = add reference to TExtAI in DLL
        QueueEvents.QueueActions := QueueActions; // Mark actions so they are called OnTick event from main thread
        Hand.Events := QueueEvents; // = add reference to TExtAIQueueEvents
        Thread.Init(QueueEvents);
        // Create ExtAI in DLL
        fOnInitNewExtAI( aExtAIID, QueueActions, aStates ); // = add reference to TExtAIQueueActions and States
        fExtAIThread.Add(Thread);
        Thread.Start;
      end
      else
      begin
        // Create interface
        Hand.Events := fOnNewExtAI(); // = add reference to TExtAI in DLL
        // Create ExtAI in DLL
        fOnInitNewExtAI( aExtAIID, Hand, aStates ); // = add reference to TExtAIHand and States
      end;
    except
      on E: Exception do
      begin
        Log('  CommDLL-CreateNewExtAI: Error ' + E.ClassName + ': ' + E.Message);
        Readln;
      end;
    end;
    Result := Hand;
  end;
end;

procedure TExtAICommDLL.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;


end.