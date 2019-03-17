unit ExtAI_DLLs;
interface
uses
  IOUtils, Classes, System.SysUtils, Generics.Collections,
  ExtAI_DLL, ExtAI_SharedTypes, ExtAIUtils;

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
    function GetDLL(aIndex: Integer): TDLLMainCfg;
    function GetCount: Integer;
    procedure AddDLL(aPath: string);
  public
    constructor Create(aDLLPaths: TArray<string>);
    destructor Destroy; override;

    property Count: Integer read GetCount;
    function GetList(const aPrefix: string): string;
    property DLL[aIndex: Integer]: TDLLMainCfg read GetDLL; default;

    procedure RefreshList(aPaths: TArray<string>);
    function DLLExists(const aDLLPath: wStr): Boolean;
  end;

implementation
uses
  Log;

{ TExtAIDLLs }
constructor TExtAIDLLs.Create(aDLLPaths: TArray<string>);
begin
  inherited Create;

  fDLLs := TList<TDLLMainCfg>.Create;
  RefreshList(aDLLPaths); // Find available DLL (public method for possibility reload DLLs)
end;


destructor TExtAIDLLs.Destroy;
begin
  fDLLs.Free;

  inherited;
end;


function TExtAIDLLs.GetCount: Integer;
begin
  Result := fDLLs.Count;
end;


function TExtAIDLLs.GetDLL(aIndex: Integer): TDLLMainCfg;
begin
  Result := fDLLs[aIndex];
end;


function TExtAIDLLs.GetList(const aPrefix: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to fDLLs.Count-1 do
    Result := Result + aPrefix + fDLLs[I].ExtAIName + '|';
end;


procedure TExtAIDLLs.AddDLL(aPath: string);
var
  dllInfo: TDLLMainCfg;
  CommDLL: TExtAI_DLL;
begin
  // Init DLL and ask it about its details
  CommDLL := TExtAI_DLL.Create;
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
          gLog.Log('  TExtAIDLLs: New DLL - ' + fileDLL);
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
      Exit(True);
end;


end.