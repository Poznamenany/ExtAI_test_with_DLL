unit ExtAIDLLs;
interface
uses
  IOUtils, Classes, System.SysUtils, Generics.Collections,
  ExtAICommDLL, ExtAIDataTypes, ExtAIUtils;

  // Expected folder structure:
  // - ExtAI
  //   - dll_delphi
  //     - dll_delphi.dll
  //   - dll_c
  //     - dll_c.dll

type
  // List available DLLs
  // Check presence of all valid DLLs (in future it can also check CRC, save info etc.)
  TExtAIDLLs = class
  private
    fDLLs: TList<TDLLMainCfg>;
    fOnLog: TLogEvent;
    procedure Log(aLog: wStr);
    function GetDLL(aIndex: Integer): TDLLMainCfg;
    function GetCount: Integer;
    procedure AddDLL(aPath: wStr);
  public
    constructor Create(aDLLPaths: TArray<string>; aLog: TLogEvent); reintroduce;
    destructor Destroy; override;

    property Count: Integer read GetCount;
    property DLL[aIndex: Integer]: TDLLMainCfg read GetDLL; default;

    procedure RefreshList(aPaths: TArray<string>);
    function DLLExists(const aDLLPath: wStr): Boolean;
  end;

implementation


{ TExtAIDLLs }
constructor TExtAIDLLs.Create(aDLLPaths: TArray<string>; aLog: TLogEvent);
begin
  inherited Create();

  fOnLog := aLog;

  fDLLs := TList<TDLLMainCfg>.Create;
  RefreshList(aDLLPaths); // Find available DLL (public method for possibility reload DLLs)
end;


destructor TExtAIDLLs.Destroy;
begin
  fDLLs.Free;

  inherited;
end;


function TExtAIDLLs.GetCount: si32;
begin
  Result := fDLLs.Count;
end;


function TExtAIDLLs.GetDLL(aIndex: Integer): TDLLMainCfg;
begin
  Result := fDLLs[aIndex];
end;


procedure TExtAIDLLs.AddDLL(aPath: wStr);
var
  dllInfo: TDLLMainCfg;
  CommDLL: TExtAICommDLL;
begin
  // Init DLL and ask it about its details
  CommDLL := TExtAICommDLL.Create(fOnLog);
  try
    if CommDLL.LinkDLL(aPath) then
    begin
      // Copy data
      dllInfo := default(TDLLMainCfg);
      dllInfo.Author := CommDLL.Config.Author;
      dllInfo.Description := CommDLL.Config.Description;
      dllInfo.ExtAIName := CommDLL.Config.ExtAIName;
      dllInfo.Version := CommDLL.Config.Version;
      dllInfo.Path := aPath;
      // Check CRC?

      fDLLs.Add(dllInfo);
    end;
  finally
    CommDLL.Free;
  end;
end;


procedure TExtAIDLLs.RefreshList(aPaths: TArray<string>);
var
  I: Integer;
  subFolder, fileDLL: string;
begin
  fDLLs.Clear;

  for I := Low(aPaths) to High(aPaths) do
    if DirectoryExists(aPaths[I]) then
    for subFolder in TDirectory.GetDirectories(aPaths[I]) do
      for fileDLL in TDirectory.GetFiles(subFolder) do
        if ExtractFileExt(fileDLL) = '.dll' then
        begin
          Log('  TExtAIDLLs: New DLL - ' + fileDLL);
          AddDLL(fileDLL);
        end;
end;


function TExtAIDLLs.DLLExists(const aDLLPath: wStr): Boolean;
var
  K: Integer;
begin
  Result := False;
  for K := 0 to fDLLs.Count-1 do
    if CompareStr(fDLLs[K].Path, aDLLPath) = 0 then
    begin
      Result := True;
      break;
    end;
end;

procedure TExtAIDLLs.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;


end.