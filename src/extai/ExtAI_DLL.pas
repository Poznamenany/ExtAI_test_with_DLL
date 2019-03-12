unit ExtAI_DLL;
{$I KM_CompilerDirectives.inc}
interface
uses
  Classes, Windows, System.SysUtils,
  {$IFDEF ALLOW_EXT_AI_MULTITHREADING}
  ExtAIQueueActions, ExtAIQueueEvents, ExtAIThread,
  {$ENDIF}
  ExtAIStates,
  Consts, HandAI_Ext, ExtAI_SharedInterfaces, ExtAI_SharedTypes, ExtAIUtils;

type
  TInitDLL = procedure(var aConfig: TDLLpConfig); StdCall;
  TTerminDLL = procedure(); StdCall;
  TInitNewExtAI = procedure(aHandIndex: TKMHandIndex; aActions: IActions; aStates: IStates) StdCall;
  TNewExtAI = function(): IEvents; SafeCall; // Same like StdCall but allows exceptions

  // Communication with 1 physical DLL with using exported methods.
  // Main targets: initialization of DLL, creation of ExtAIs and termination of DLL and ExtAIs
  TExtAI_DLL = class
  private
    fDLLConfig: TDLLMainCfg;
    fLibHandle: THandle;

    {$IFDEF ALLOW_EXT_AI_MULTITHREADING}
    fExtAIThread: TList;
    {$ENDIF}

    // DLL Procedures
    fDLLProc_Init: TInitDLL;
    fDLLProc_Terminate: TTerminDLL;
    fDLLProc_InitNewExtAI: TInitNewExtAI;
    fDLLProc_NewExtAI: TNewExtAI;

    fOnLog: TLogEvent;
    procedure Log(aLog: wStr);
  public
    property Config: TDLLMainCfg read fDLLConfig;

    constructor Create(aOnLog: TLogEvent); reintroduce;
    destructor Destroy; override;

    function LinkDLL(aDLLPath: wStr): Boolean;
    function CreateNewExtAI(aOwnThread: Boolean; aHandIndex: TKMHandIndex; aLogProgress: TLogProgressEvent; var aIStates: TExtAIStates): THandAI_Ext;
  end;

implementation


{ TExtAI_DLL }
constructor TExtAI_DLL.Create(aOnLog: TLogEvent);
begin
  inherited Create;

  fOnLog := aOnLog;
  {$IFDEF ALLOW_EXT_AI_MULTITHREADING}
  fExtAIThread := TList.Create();
  {$ENDIF}
  Log('  TExtAI_DLL-Create');
end;


destructor TExtAI_DLL.Destroy;
{$IFDEF ALLOW_EXT_AI_MULTITHREADING}
var
  K: si32;
{$ENDIF}
begin
  Log('  TExtAI_DLL-Destroy: ExtAI name = ' + fDLLConfig.ExtAIName);

  {$IFDEF ALLOW_EXT_AI_MULTITHREADING}
  for K := 0 to fExtAIThread.Count-1 do
    if (TExtAIThread(fExtAIThread[K]).State = tsRun) then
    begin
      Log('  TExtAI_DLL-Destroy: Wait for thread of HandIndex = ' + IntToStr(TExtAIThread(fExtAIThread[K]).HandIndex));
      TExtAIThread(fExtAIThread[K]).State := tsTerminate;
      TExtAIThread(fExtAIThread[K]).WaitFor;
    end;
  {$ENDIF}

  if Assigned(fDLLProc_Terminate) then
    fDLLProc_Terminate(); // = remove reference from ExtAIAPI

  {$IFDEF ALLOW_EXT_AI_MULTITHREADING}
  for K := 0 to fExtAIThread.Count-1 do
    TExtAIThread(fExtAIThread[K]).Free();
  FreeAndNil(fExtAIThread);
  {$ENDIF}

  FreeLibrary(fLibHandle);

  inherited;
end;


function TExtAI_DLL.LinkDLL(aDLLPath: wStr): Boolean;
var
  Err: si32;
  Cfg: TDLLpConfig;
begin
  Result := False;

  if not FileExists(aDLLPath) then
  begin
    Log('  TExtAI_DLL-LinkDLL: DLL file was NOT found');
    Exit;
  end;

  fLibHandle := SafeLoadLibrary(aDLLPath);
  if fLibHandle = 0 then
  begin
    Log('  TExtAI_DLL-LinkDLL: library was NOT loaded, error: ' + IntToStr(GetLastError()));
    Exit;
  end;

  Err := GetLastError();
  if Err <> 0 then
  begin
    Log('  TExtAI_DLL-LinkDLL: ERROR in the DLL file detected = ' + IntToStr(Err));
    Exit;
  end;

  Result := True;

  fDLLProc_Init := GetProcAddress(fLibHandle, 'InitDLL');
  fDLLProc_Terminate := GetProcAddress(fLibHandle, 'TerminDLL');
  fDLLProc_NewExtAI := GetProcAddress(fLibHandle, 'NewExtAI');
  fDLLProc_InitNewExtAI := GetProcAddress(fLibHandle, 'InitNewExtAI');

  if Assigned(fDLLProc_Init)
  AND Assigned(fDLLProc_Terminate)
  AND Assigned(fDLLProc_NewExtAI)
  AND Assigned(fDLLProc_InitNewExtAI) then
  begin
    Result := True;
    fDLLConfig.Path := aDLLPath;
    fDLLProc_Init(Cfg);
    SetLength(fDLLConfig.Author, Cfg.AuthorLen);
    Move(Cfg.Author^, fDLLConfig.Author[1], Cfg.AuthorLen * SizeOf(fDLLConfig.Author[1]));
    SetLength(fDLLConfig.Description, Cfg.DescriptionLen);
    Move(Cfg.Description^, fDLLConfig.Description[1], Cfg.DescriptionLen * SizeOf(fDLLConfig.Description[1]));
    SetLength(fDLLConfig.ExtAIName, Cfg.ExtAINameLen);
    Move(Cfg.ExtAIName^, fDLLConfig.ExtAIName[1], Cfg.ExtAINameLen * SizeOf(fDLLConfig.ExtAIName[1]));
    fDLLConfig.Version := Cfg.Version;
    Log('  TExtAI_DLL-LinkDLL: DLL detected, Name: ' + fDLLConfig.ExtAIName + '; Version: ' + IntToStr(fDLLConfig.Version));
  end;
end;


function TExtAI_DLL.CreateNewExtAI(aOwnThread: Boolean; aHandIndex: TKMHandIndex; aLogProgress: TLogProgressEvent; var aIStates: TExtAIStates): THandAI_Ext;
{$IFDEF ALLOW_EXT_AI_MULTITHREADING}
var
  Thread: TExtAIThread;
  ThreadLog: TLogEvent;
  QueueActions: TExtAIQueueActions;
  QueueEvents: TExtAIQueueEvents;
  {$ENDIF}
begin
  Result := nil;
  if not Assigned(fDLLProc_NewExtAI) then Exit;

  //Log('  CommDLL-CreateNewExtAI: HandIndex = ' + IntToStr(aHandIndex));
  Result := THandAI_Ext.Create(aHandIndex, fOnLog);
  try
    if aOwnThread then
    begin
      {$IFDEF ALLOW_EXT_AI_MULTITHREADING}
      // Create thread
      Thread := TExtAIThread.Create(aHandIndex, fOnLog, aLogProgress, ThreadLog);
      // Create interfaces
      QueueActions := TExtAIQueueActions.Create(aHandIndex, ThreadLog);
      QueueActions.Actions := Result; // = add reference to THandAI_Ext
      QueueEvents := TExtAIQueueEvents.Create(aHandIndex, ThreadLog);
      QueueEvents.Events := fDLLProc_NewExtAI(); // = add reference to TExtAI in DLL
      QueueEvents.QueueActions := QueueActions; // Mark actions so they are called OnTick event from main thread
      Result.AssignEvents(QueueEvents); // = add reference to TExtAIQueueEvents
      Thread.Init(QueueEvents);
      // Create ExtAI in DLL
      fDLLProc_InitNewExtAI(aHandIndex, QueueActions, aStates); // = add reference to TExtAIQueueActions and States
      fExtAIThread.Add(Thread);
      Thread.Start;
      {$ELSE}
      Assert(False, 'ALLOW_EXT_AI_MULTITHREADING is not set');
      {$ENDIF}
    end else
    begin
      // Create interface
      Result.AssignEvents(fDLLProc_NewExtAI); // = add reference to TExtAI in DLL
      // Create ExtAI in DLL
      fDLLProc_InitNewExtAI(aHandIndex, Result, aIStates); // = add reference to THandAI_Ext and States
    end;
  except
    on E: Exception do
    begin
      Log('  TExtAI_DLL-CreateNewExtAI: Error ' + E.ClassName + ': ' + E.Message);
      Readln;
    end;
  end;
end;


procedure TExtAI_DLL.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;


end.
