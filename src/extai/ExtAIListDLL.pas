unit ExtAIListDLL;
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
    fDLLPath: string;
    fDLLs: TList<TDLLMainCfg>;
    fOnLog: TLogEvent;
    procedure Log(aLog: wStr);
    function GetDLL(aIndex: Integer): TDLLMainCfg;
    function GetCount: Integer;
    procedure AddDLL(aPath: wStr);
  public
    constructor Create(aDLLPath: string; aLog: TLogEvent); reintroduce;
    destructor Destroy(); override;

    property Count: Integer read GetCount;
    property DLL[aIndex: Integer]: TDLLMainCfg read GetDLL; default;

    procedure RefreshList;
    function DLLExists(const aDLLPath: wStr): Boolean;
  end;

implementation


{ TExtAIDLLs }
constructor TExtAIDLLs.Create(aDLLPath: string; aLog: TLogEvent);
begin
  inherited Create();

  fDLLPath := aDLLPath;
  fOnLog := aLog;

  fDLLs := TList<TDLLMainCfg>.Create;
  RefreshList; // Find available DLL (public method for possibility reload DLLs)
end;


destructor TExtAIDLLs.Destroy();
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
  Info: TDLLMainCfg;
  CommDLL: TExtAICommDLL;
begin
  CommDLL := TExtAICommDLL.Create(fOnLog);
  try
    if (CommDLL.LinkDLL(aPath)) then
    begin
      Info := default(TDLLMainCfg);
      with Info do
      begin
        Author := CommDLL.Config.Author;
        Description := CommDLL.Config.Description;
        ExtAIName := CommDLL.Config.ExtAIName;
        Version := CommDLL.Config.Version;
        Path := aPath;
      end;
      // Check CRC?
      fDLLs.Add(Info);
    end;
  finally
    CommDLL.Free;
  end;
end;


procedure TExtAIDLLs.RefreshList;
var
  subFolder, fileDLL: string;
begin
  fDLLs.Clear;
  if not DirectoryExists(fDLLPath) then Exit;

  for subFolder in TDirectory.GetDirectories(fDLLPath) do
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