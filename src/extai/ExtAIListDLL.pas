unit ExtAIListDLL;
interface
uses
  IOUtils, Classes, System.SysUtils,
  ExtAICommDLL, ExtAIDataTypes, ExtAIUtils;

  // Expected folder structure:
  // - ext_ai
  //   - dll_delphi
  //     - dll_delphi.dll
  //   - dll_c
  //     - dll_c.dll

type
  PInfoDLL = ^TDLLMainCfg;

  TListDLL = class(TList)
  private
    function Get(aIndex: Integer): PInfoDLL;
  public
    property Items[Index: Integer]: PInfoDLL read Get; default;
    destructor Destroy(); override;
    function Add(aValue: PInfoDLL): Integer;
    procedure Clear(); override;
    function Copy(): TListDLL;
  end;

  // Check presence of all valid DLLs (in future it can also check CRC, save info etc.)
  TExtAIListDLL = class
  private
    fDLLs: TListDLL;
    fPaths: wStrArr;
    fOnLog: TLogEvent;
    procedure Log(aLog: wStr);
    function GetDLL(aIndex: Integer): PInfoDLL;
    function GetCount: Integer;
    procedure AddDLL(aPath: wStr);
  public
    property Count: Integer read GetCount;
    property DLL[aIndex: Integer]: PInfoDLL read GetDLL; default;
    property List: TListDLL read fDLLs;

    constructor Create(aLog: TLogEvent); reintroduce;
    destructor Destroy(); override;

    procedure RefreshDLLs(aLogDLLs: Boolean = False);
    function ContainDLL(const aDLLPath: wStr): boolean;
    procedure SetDLLFolderPaths(var aPaths: wStrArr);
  end;

implementation


{ TListDLL }
destructor TListDLL.Destroy();
begin
  Clear();
  inherited;
end;

function TListDLL.Add(aValue: PInfoDLL): Integer;
begin
  Result := inherited Add(aValue);
end;

function TListDLL.Get(aIndex: si32): PInfoDLL;
begin
  Result := PInfoDLL(inherited Get(aIndex));
end;

procedure TListDLL.Clear();
var
  K: si32;
begin
  for K := 0 to Count - 1 do
    Dispose( PInfoDLL(Items[K]) );
  inherited Clear();
end;

function TListDLL.Copy(): TListDLL;
var
  K: si32;
  Info: PInfoDLL;
begin
  Result := TListDLL.Create();
  for K := 0 to Count - 1 do
  begin
    New(Info);
    with Info^ do // Is move safe with strings?
    begin
      Author := Items[K]^.Author;
      Description := Items[K]^.Description;
      ExtAIName := Items[K]^.ExtAIName;
      Path := Items[K]^.Path;
      Version := Items[K]^.Version;
    end;
    Result.Add(Info);
  end;
end;


{ TExtAIListDLL }
constructor TExtAIListDLL.Create(aLog: TLogEvent);
begin
  inherited Create();
  fOnLog := aLog;
  fDLLs := TListDLL.Create();
  RefreshDLLs(True); // Find available DLL (public method for possibility reload DLLs)
end;


destructor TExtAIListDLL.Destroy();
begin
  fDLLs.Free();
  inherited;
end;


function TExtAIListDLL.GetCount: si32;
begin
  Result := fDLLs.Count;
end;


function TExtAIListDLL.GetDLL(aIndex: si32): PInfoDLL;
begin
  Result := fDLLs[aIndex];
end;


procedure TExtAIListDLL.AddDLL(aPath: wStr);
var
  Info: PInfoDLL;
  CommDLL: TExtAICommDLL;
begin
  CommDLL := TExtAICommDLL.Create(fOnLog);
  try
    if (CommDLL.LinkDLL(aPath)) then
    begin
      New(Info);
      with Info^ do
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


procedure TExtAIListDLL.RefreshDLLs(aLogDLLs: Boolean = False);
var
  K: si32;
  FolderPath, DLLPath: String;
begin
  fDLLs.Clear();
  for K := Low(fPaths) to High(fPaths) do
    if DirectoryExists(fPaths[K]) then
      for FolderPath in TDirectory.GetDirectories(fPaths[K]) do
        for DLLPath in TDirectory.GetFiles(FolderPath) do
          if (ExtractFileExt(DLLPath) = '.dll') then
          begin
            if aLogDLLs then
              Log('  TCheckDLL: New DLL - ' + DLLPath);
            AddDLL(DLLPath);
          end;
end;


function TExtAIListDLL.ContainDLL(const aDLLPath: wStr): b;
var
  K: si32;
begin
  Result := False;
  for K := 0 to fDLLs.Count-1 do
    if CompareStr(fDLLs[K]^.Path,aDLLPath) = 0 then
    begin
      Result := True;
      break
    end;
end;


procedure TExtAIListDLL.SetDLLFolderPaths(var aPaths: wStrArr);
begin
  fPaths := aPaths;
  RefreshDLLs();
end;

procedure TExtAIListDLL.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;

end.