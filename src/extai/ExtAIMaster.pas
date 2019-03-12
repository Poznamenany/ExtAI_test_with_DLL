unit ExtAIMaster;
{$I KM_CompilerDirectives.inc}
interface
uses
  Classes, Windows, System.SysUtils, Generics.Collections,
  Consts, HandAI_Ext, ExtAIStates, ExtAI_DLLs, ExtAI_DLL, ExtAI_SharedTypes, ExtAIUtils;

type
  // Master of ExtAIs
  // Manages DLLs and States (for now)
  TExtAIMaster = class
  private
    fDLLs: TExtAIDLLs;
    fDLLInstances: TList<TExtAI_DLL>;
    fIStates: TExtAIStates;

    fOnLog: TLogEvent;
    procedure Log(aLog: wStr);
    function IndexOf(aDLLPath: wStr): Integer;
  public
    constructor Create(aDLLPaths: TArray<string>; aLog: TLogEvent); reintroduce;
    destructor Destroy; override;
    procedure Release;

    property DLLs: TExtAIDLLs read fDLLs;
    property QueueStates: TExtAIStates read fIStates;

    procedure RigNewExtAI(aAI: THandAI_Ext; aOwnThread: Boolean; aDLLPath: wStr; aLogProgress: TLogProgressEvent);
  end;


implementation
uses
  ExtAI_SharedInterfaces;


{ TExtAIMaster }
constructor TExtAIMaster.Create(aDLLPaths: TArray<string>; aLog: TLogEvent);
begin
  inherited Create;

  fOnLog := aLog;

  fDLLInstances := TList<TExtAI_DLL>.Create;
  fDLLs := TExtAIDLLs.Create(aDLLPaths, aLog);
  fIStates := nil; // States are interface and will be freed automatically
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


// -> HandIndex
// -> Actions
// <- Events
procedure TExtAIMaster.RigNewExtAI(aAI: THandAI_Ext; aOwnThread: Boolean; aDLLPath: wStr; aLogProgress: TLogProgressEvent);
var
  Idx: Integer;
  DLL: TExtAI_DLL;
  e: IEvents;
begin
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

  // Create IStates if it does not exist
  if fIStates = nil then
    fIStates := TExtAIStates.Create(fOnLog);

  // Create ExtAI in DLL
  DLL.CreateNewExtAI(aOwnThread, aAI.HandIndex, aLogProgress, aAI.IActions, fIStates, e);
  aAI.AssignEvents(e);
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