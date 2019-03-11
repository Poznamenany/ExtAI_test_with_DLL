unit ExtAIMaster;
{$I KM_CompilerDirectives.inc}
interface
uses
  Classes, Windows, System.SysUtils, Generics.Collections,
  Consts, HandAI_Ext, ExtAIQueueStates, ExtAI_DLLs, ExtAI_DLL, ExtAI_SharedTypes, ExtAIUtils;

type
  // Master of ExtAIs
  // Manages DLLs and States (for now)
  TExtAIMaster = class
  private
    fDLLs: TExtAIDLLs;
    fDLLInstances: TList<TExtAI_DLL>;
    fQueueStates: TExtAIQueueStates;

    fOnLog: TLogEvent;
    procedure Log(aLog: wStr);
    function IndexOf(aDLLPath: wStr): Integer;
  public
    constructor Create(aDLLPaths: TArray<string>; aLog: TLogEvent); reintroduce;
    destructor Destroy; override;
    procedure Release;

    property DLLs: TExtAIDLLs read fDLLs;
    property QueueStates: TExtAIQueueStates read fQueueStates;

    function NewExtAI(aOwnThread: Boolean; aHandIndex: TKMHandIndex; aDLLPath: wStr; aLogProgress: TLogProgressEvent): THandAI_Ext;
  end;


implementation

{ TExtAIMaster }
constructor TExtAIMaster.Create(aDLLPaths: TArray<string>; aLog: TLogEvent);
begin
  inherited Create;

  fOnLog := aLog;

  fDLLInstances := TList<TExtAI_DLL>.Create;
  fDLLs := TExtAIDLLs.Create(aDLLPaths, aLog);
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
  K: Integer;
begin
  for K := 0 to fDLLInstances.Count-1 do
    fDLLInstances[K].Free;
  fDLLInstances.Clear;
end;


function TExtAIMaster.NewExtAI(aOwnThread: Boolean; aHandIndex: TKMHandIndex; aDLLPath: wStr; aLogProgress: TLogProgressEvent): THandAI_Ext;
var
  Idx: Integer;
  DLL: TExtAI_DLL;
begin
  Result := nil;

  // Make sure that DLLs exist - DLL was already refreshed in GUI
  //fDLLs.RefreshDLLs;
  if not fDLLs.DLLExists(aDLLPath) then
    Exit;

  // Check if we already have this DLL loaded
  Idx := IndexOf(aDLLPath);
  if Idx <> -1 then
    DLL := fDLLInstances[Idx]
  else
  begin // if not, create the DLL
    DLL := TExtAI_DLL.Create(fOnLog);
    DLL.LinkDLL(aDLLPath);
    fDLLInstances.Add(DLL);
  end;

  // Create States if does not exist
  if fQueueStates = nil then
    fQueueStates := TExtAIQueueStates.Create(fOnLog);

  // Create ExtAI in DLL
  Result := DLL.CreateNewExtAI(aOwnThread, aHandIndex, aLogProgress, fQueueStates);
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