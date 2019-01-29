unit ExtAIMain;
interface
uses
  Classes, Windows, System.SysUtils,
  ExtAIHand, ExtAIQueueStates, ExtAIListDLL, ExtAICommDLL, ExtAIDataTypes, ExtAIUtils;

type
  // Main ExtAI class (manage DLLs and States (for now))
  TExtAIMain = class
  private
    fCommDLL: TList;
    fListDLL: TExtAIListDLL;
    fQueueStates: TExtAIQueueStates;

    fOnLog: TLog;
    procedure Log(aLog: wStr);
    function IndexOf(aDLLPath: wStr): si32;
  public
    property ListDLL: TExtAIListDLL read fListDLL write fListDLL;

    constructor Create(aLog: TLog); reintroduce;
    destructor Destroy(); override;
    procedure Release();

    function NewExtAI(aOwnThread: b; aExtAIID: ui8; aDLLPath: wStr; aInitLog: TLog; aLogProgress: TLogProgress): TExtAIHand;
end;


implementation

{ TExtAIMain }
constructor TExtAIMain.Create(aLog: TLog);
begin
  inherited Create();
  fOnLog := aLog;
  fCommDLL := TList.Create();
  fListDLL := TExtAIListDLL.Create(aLog);
  fQueueStates := nil; // States are interface and will be freed automatically
end;

destructor TExtAIMain.Destroy();
begin
  Release(); // Make sure that DLLs are released
  fCommDLL.Free();
  fListDLL.Free();
  inherited;
end;


procedure TExtAIMain.Release();
var
  K: si32;
begin
  for K := 0 to fCommDLL.Count-1 do
    TExtAICommDLL(fCommDLL[K]).Free();
  fCommDLL.Clear();
end;


function TExtAIMain.NewExtAI(aOwnThread: b; aExtAIID: ui8; aDLLPath: wStr; aInitLog: TLog; aLogProgress: TLogProgress): TExtAIHand;
var
  Idx: si32;
  DLL: TExtAICommDLL;
begin
  Result := nil;

  // Make sure that DLLs exist - DLL was already refreshed in GUI
  //fListDLL.RefreshDLLs();
  if NOT fListDLL.ContainDLL(aDLLPath) then
    Exit;

  // Check if we already have this DLL loaded
  Idx := IndexOf(aDLLPath);
  if (Idx <> -1) then
    DLL := TExtAICommDLL(fCommDLL[Idx])
  else
  begin // if not, create the DLL
    DLL := TExtAICommDLL.Create(fOnLog);
    DLL.LinkDLL(aDLLPath);
    fCommDLL.Add( DLL );
  end;
  // Create States if does not exist
  if (fQueueStates = nil) then
    fQueueStates := TExtAIQueueStates.Create(fOnLog);
  // Create ExtAI in DLL
  Result := DLL.CreateNewExtAI( aOwnThread, aExtAIID, aInitLog, aLogProgress, fQueueStates);
end;


function TExtAIMain.IndexOf(aDLLPath: wStr): si32;
var
  K: si32;
begin
  Result := -1;
  for K := 0 to fCommDLL.Count-1 do
    if (fCommDLL[K] <> nil) AND (  AnsiCompareStr( TExtAICommDLL(fCommDLL[K]).Config.Path, aDLLPath ) = 0  ) then
    begin
      Result := K;
      break;
    end;
end;


procedure TExtAIMain.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;


end.