unit ExtAIMaster;
{$I KM_CompilerDirectives.inc}
interface
uses
  Classes, Windows, System.SysUtils, Generics.Collections,
  HandAI_Ext, ExtAIQueueStates, ExtAIDLLs, ExtAICommDLL, ExtAIDataTypes, ExtAIUtils;

type
  // Master of ExtAIs
  // Manages DLLs and States (for now)
  TExtAIMaster = class
  private
    fDLLs: TExtAIDLLs;
    fDLLInstances: TList<TExtAICommDLL>;
    fQueueStates: TExtAIQueueStates;

    fOnLog: TLogEvent;
    procedure Log(aLog: wStr);
    function IndexOf(aDLLPath: wStr): Integer;
  public
    constructor Create(aDLLPath: TArray<string>; aLog: TLogEvent); reintroduce;
    destructor Destroy; override;
    procedure Release;

    property DLLs: TExtAIDLLs read fDLLs;
    property QueueStates: TExtAIQueueStates read fQueueStates;

    function NewExtAI(aOwnThread: Boolean; aExtAIID: ui8; aDLLPath: wStr; aInitLog: TLogEvent; aLogProgress: TLogProgressEvent): THandAI_Ext;
  end;


implementation

{ TExtAIMaster }
constructor TExtAIMaster.Create(aDLLPath: TArray<string>; aLog: TLogEvent);
begin
  inherited Create;

  fOnLog := aLog;

  fDLLInstances := TList<TExtAICommDLL>.Create;
  fDLLs := TExtAIDLLs.Create(aDLLPath, aLog);
  fQueueStates := nil; // States are interface and will be freed automatically
end;

destructor TExtAIMaster.Destroy;
begin
  Release; // Make sure that DLLs are released
  fDLLInstances.Free;
  fDLLs.Free;

  inherited;
end;


procedure TExtAIMaster.Release;
var
  K: si32;
begin
  for K := 0 to fDLLInstances.Count-1 do
    fDLLInstances[K].Free;
  fDLLInstances.Clear;
end;


function TExtAIMaster.NewExtAI(aOwnThread: Boolean; aExtAIID: ui8; aDLLPath: wStr; aInitLog: TLogEvent; aLogProgress: TLogProgressEvent): THandAI_Ext;
var
  Idx: si32;
  DLL: TExtAICommDLL;
begin
  Result := nil;

  // Make sure that DLLs exist - DLL was already refreshed in GUI
  //fDLLs.RefreshDLLs;
  if not fDLLs.DLLExists(aDLLPath) then
    Exit;

  // Check if we already have this DLL loaded
  Idx := IndexOf(aDLLPath);
  if Idx <> -1 then
    DLL := TExtAICommDLL(fDLLInstances[Idx])
  else
  begin // if not, create the DLL
    DLL := TExtAICommDLL.Create(fOnLog);
    DLL.LinkDLL(aDLLPath);
    fDLLInstances.Add(DLL);
  end;
  // Create States if does not exist
  if (fQueueStates = nil) then
    fQueueStates := TExtAIQueueStates.Create(fOnLog);
  // Create ExtAI in DLL
  Result := DLL.CreateNewExtAI(aOwnThread, aExtAIID, aInitLog, aLogProgress, fQueueStates);
end;


function TExtAIMaster.IndexOf(aDLLPath: wStr): Integer;
var
  K: Integer;
begin
  Result := -1;
  for K := 0 to fDLLInstances.Count-1 do
    if (fDLLInstances[K] <> nil) and (AnsiCompareStr(fDLLInstances[K].Config.Path, aDLLPath) = 0) then
      Exit(K);
end;


procedure TExtAIMaster.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;


end.