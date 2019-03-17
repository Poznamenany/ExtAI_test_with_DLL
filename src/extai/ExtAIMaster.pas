unit ExtAIMaster;
{$I KM_CompilerDirectives.inc}
interface
uses
  Classes, Windows, System.SysUtils, Generics.Collections,
  Consts, ExtAIActions, ExtAIStates, ExtAI_DLLs, ExtAI_DLL, ExtAI_SharedTypes, ExtAI_SharedInterfaces, ExtAIUtils;

type
  // Master of ExtAIs
  // Manages DLLs and States (for now)
  TExtAIMaster = class
  private
    fDLLs: TExtAIDLLs;
    fDLLInstances: TList<TExtAI_DLL>;
    fIStates: TExtAIStates;

    function IndexOf(aDLLPath: string): Integer;
  public
    constructor Create(aDLLPaths: TArray<string>);
    destructor Destroy; override;
    procedure ReleaseDLLs;

    property DLLs: TExtAIDLLs read fDLLs;
    property IStates: TExtAIStates read fIStates;

    procedure RigNewExtAI(aHandIndex: TKMHandIndex; aIActions: TExtAIActions; out aIEvents: IEvents;
      aOwnThread: Boolean; aDLLIndex: Integer; aLogProgress: TLogProgressEvent);
  end;


implementation
uses
  Log;


{ TExtAIMaster }
// aDLLPaths should be like 'ExeDir\ExtAI\'.
// We will scan 1 folder deep, since it'a handy to have each ExtAI DLL in it's own folder
constructor TExtAIMaster.Create(aDLLPaths: TArray<string>);
begin
  inherited Create;

  fDLLInstances := TList<TExtAI_DLL>.Create;
  fDLLs := TExtAIDLLs.Create(aDLLPaths);
  fIStates := nil; // States are interface and will be freed automatically
end;


destructor TExtAIMaster.Destroy;
begin
  // @Krom: are you 100% sure that name "Release" have not special meaning in your code? Please use ReleaseDLLs instead
  ReleaseDLLs; // Make sure that DLLs are released
  fDLLInstances.Free;
  fDLLs.Free;

  inherited;
end;


procedure TExtAIMaster.ReleaseDLLs;
var
  K: Integer;
begin
  for K := 0 to fDLLInstances.Count-1 do
    fDLLInstances[K].Free;
  fDLLInstances.Clear;
end;


// -> HandIndex
// -> IActions
// -> IStates
// <- IEvents
procedure TExtAIMaster.RigNewExtAI(aHandIndex: TKMHandIndex; aIActions: TExtAIActions; out aIEvents: IEvents;
  aOwnThread: Boolean; aDLLIndex: Integer; aLogProgress: TLogProgressEvent);
var
  Idx: Integer;
  DLL: TExtAI_DLL;
  dllPath: string;
begin
  dllPath := fDLLs[aDLLIndex].Path;

  // Check if we already have this DLL loaded
  Idx := IndexOf(dllPath);
  if Idx <> -1 then
    DLL := fDLLInstances[Idx]
  else
  begin // if not, create the DLL
    DLL := TExtAI_DLL.Create;
    DLL.LinkDLL(dllPath);
    fDLLInstances.Add(DLL);
  end;

  // Create IStates if it does not exist
  if fIStates = nil then
    fIStates := TExtAIStates.Create;

  // Create ExtAI in DLL
  DLL.CreateNewExtAI(aHandIndex, aIActions, fIStates, aOwnThread, aLogProgress, aIEvents);
end;


function TExtAIMaster.IndexOf(aDLLPath: string): Integer;
var
  K: Integer;
begin
  Result := -1;
  for K := 0 to fDLLInstances.Count-1 do
    if (fDLLInstances[K] <> nil) and (AnsiCompareStr(fDLLInstances[K].Config.Path, aDLLPath) = 0) then
      Exit(K);
end;


end.