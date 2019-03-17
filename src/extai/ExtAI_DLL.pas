unit ExtAI_DLL;
{$I KM_CompilerDirectives.inc}
interface
uses
  Classes, Windows, System.SysUtils,
  {$IFDEF ALLOW_EXT_AI_MULTITHREADING}
  ExtAIQueueActions, ExtAIQueueEvents, ExtAIThread,
  {$ENDIF}
  ExtAIStates,
  Consts, ExtAI_SharedInterfaces, ExtAI_SharedTypes, ExtAIUtils, ExtAIActions;

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
  public
    constructor Create;
    destructor Destroy; override;

    property Config: TDLLMainCfg read fDLLConfig;

    function LinkDLL(aDLLPath: string): Boolean;
    procedure CreateNewExtAI(aHandIndex: TKMHandIndex; aIActions: TExtAIActions; aIStates: TExtAIStates;
      aOwnThread: Boolean; aLogProgress: TLogProgressEvent; out aIEvents: IEvents);
  end;

implementation
uses
  Log;

{ TExtAI_DLL }
constructor TExtAI_DLL.Create;
begin
  inherited;

  {$IFDEF ALLOW_EXT_AI_MULTITHREADING}
  fExtAIThread := TList.Create;
  {$ENDIF}
  gLog.Log('  TExtAI_DLL-Create');
end;


destructor TExtAI_DLL.Destroy;
{$IFDEF ALLOW_EXT_AI_MULTITHREADING}
var
  K: si32;
{$ENDIF}
begin
  gLog.Log('  TExtAI_DLL-Destroy: ExtAI name = ' + fDLLConfig.ExtAIName);

  {$IFDEF ALLOW_EXT_AI_MULTITHREADING}
  for K := 0 to fExtAIThread.Count-1 do
    if (TExtAIThread(fExtAIThread[K]).State = tsRun) then
    begin
      gLog.Log('  TExtAI_DLL-Destroy: Wait for thread of HandIndex = %d', [TExtAIThread(fExtAIThread[K]).HandIndex]);
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


function TExtAI_DLL.LinkDLL(aDLLPath: string): Boolean;
var
  Err: si32;
  Cfg: TDLLpConfig;
begin
  Result := False;
  try
    if not FileExists(aDLLPath) then
    begin
      gLog.Log('  TExtAI_DLL-LinkDLL: DLL file was NOT found');
      Exit;
    end;

    // Load without displaying any pop up error messages
    fLibHandle := SafeLoadLibrary(aDLLPath, $FFFF);
    if fLibHandle = 0 then
    begin
      gLog.Log('  TExtAI_DLL-LinkDLL: library was NOT loaded, error: ', [GetLastError]);
      Exit;
    end;

    Err := GetLastError();
    if Err <> 0 then
    begin
      gLog.Log('  TExtAI_DLL-LinkDLL: ERROR in the DLL file detected = ', [Err]);
      Exit;
    end;

    fDLLProc_Init := GetProcAddress(fLibHandle, 'InitDLL');
    fDLLProc_Terminate := GetProcAddress(fLibHandle, 'TerminDLL');
    fDLLProc_NewExtAI := GetProcAddress(fLibHandle, 'NewExtAI');
    fDLLProc_InitNewExtAI := GetProcAddress(fLibHandle, 'InitNewExtAI');

    if not Assigned(fDLLProc_Init)
    or not Assigned(fDLLProc_Terminate)
    or not Assigned(fDLLProc_NewExtAI)
    or not Assigned(fDLLProc_InitNewExtAI) then
    begin
      gLog.Log('  TExtAI_DLL-LinkDLL: Exported methods not found');
      Exit;
    end;

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
    gLog.Log('  TExtAI_DLL-LinkDLL: DLL detected, Name: %s; Version: %d', [fDLLConfig.ExtAIName, fDLLConfig.Version]);
  except
    // We failed for whatever unknown reason
    on E: Exception do
    begin
      Result := False;

      // We are not really interested in the Exception message in runtime. Just log it
      gLog.Log('  TExtAI_DLL-LinkDLL: Failed with exception "%s"', [E.Message]);
    end;
  end;
end;


procedure TExtAI_DLL.CreateNewExtAI(aHandIndex: TKMHandIndex; aIActions: TExtAIActions; aIStates: TExtAIStates;
  aOwnThread: Boolean; aLogProgress: TLogProgressEvent; out aIEvents: IEvents);
{$IFDEF ALLOW_EXT_AI_MULTITHREADING}
var
  Thread: TExtAIThread;
  ThreadLog: TLogEvent;
  QueueActions: TExtAIQueueActions;
  QueueEvents: TExtAIQueueEvents;
  {$ENDIF}
begin
  gLog.Log('  TExtAI_DLL-CreateNewExtAI: HandIndex = ' + IntToStr(aHandIndex));

  if not Assigned(fDLLProc_NewExtAI) then Exit;

  Assert(aIActions <> nil);
  Assert(aIStates <> nil);

  gLog.Log(Format('aIActions.RefCount = %d', [aIActions.RefCount]));
  gLog.Log(Format('aIStates.RefCount = %d', [aIStates.RefCount]));

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
      aIEvents := fDLLProc_NewExtAI;
      // Create ExtAI in DLL
      fDLLProc_InitNewExtAI(aHandIndex, aIActions, aIStates);
    end;
  except
    on E: Exception do
    begin
      gLog.Log('  TExtAI_DLL-CreateNewExtAI: Error ' + E.ClassName + ': ' + E.Message);
      Readln;
    end;
  end;

  gLog.Log(Format('aIActions.RefCount = %d', [aIActions.RefCount]));
  gLog.Log(Format('aIStates.RefCount = %d', [aIStates.RefCount]));
end;


end.
