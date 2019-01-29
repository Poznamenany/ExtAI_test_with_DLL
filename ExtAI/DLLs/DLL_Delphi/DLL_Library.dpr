library DLL_Library;
{$DEFINE DLL_Library}
uses
  SysUtils, Classes,
  ExtAI, ExtAIInterfaceDelphi, ExtAIDataTypes;

{$R *.res}

type
  TLog = procedure(aLog: pwStr; aLen: ui32) of object; StdCall;

const
  CONFIG: TDLLConfig = (
    Author: 'Jesus of Nazareth';
    Description: 'Test example for DLL with External AI (Delphi DLL)';
    ExtAIName: 'TestingExtAI Delphi';
    Version: 20190127
  );
  ALLOW_LOG = FALSE; // Only for debug and 1 thread

var
  gExtAI: TList;
  gLogFile: TextFile;


procedure Log(aStr: wStr);
begin
  if ALLOW_LOG then
    Writeln(gLogFile,aStr);
end;

procedure InitDLL(var aConfig: TDLLpConfig); StdCall;
begin
  if ALLOW_LOG then
  begin
    AssignFile(gLogFile, 'LogDLL.txt');
    ReWrite(gLogFile);
  end;
  Log('  DLL: InitDLL - Delphi');
  gExtAI := TList.Create();
  with aConfig do
  begin
    Author := Addr(CONFIG.Author[1]);
    AuthorLen := Length(CONFIG.Author);
    Description := Addr(CONFIG.Description[1]);
    DescriptionLen := Length(CONFIG.Description);
    ExtAIName := Addr(CONFIG.ExtAIName[1]);
    ExtAINameLen := Length(CONFIG.ExtAIName);
    Version := CONFIG.Version;
  end;
end;

procedure TerminDLL(); StdCall;
var
  K: si32;
begin
  Log('  DLL: TerminDLL - Delphi');
  if ALLOW_LOG then
    CloseFile(gLogFile);
  for K := 0 to gExtAI.Count-1 do
    if (gExtAI[K] <> nil) then
    begin
      TExtAI(gExtAI[K]).Actions := nil; // = decrement Interface Actions
      TExtAI(gExtAI[K]).States := nil; // = decrement Interface States
      gExtAI[K] := nil; // = decrement Interface Events
    end;
  gExtAI.Free();
end;

function NewExtAI(): IEvents; SafeCall;
var
  ExtAI: TExtAI;
begin
  Log('  DLL: NewExtAI - Delphi');
  ExtAI := TExtAI.Create(); // = increment Interface Events
  gExtAI.Add(ExtAI);
  Result := ExtAI; // Return pointer to this class (ExtAI is derived from event interface)
end;

procedure InitNewExtAI(aID: ui8; aActions: IActions; aStates: IStates); StdCall;
begin
  Log('  DLL: InitNewExtAI - Delphi');
  with TExtAI(gExtAI[gExtAI.Count-1]) do
  begin
    ID := aID;
    Actions := aActions; // = increment Interface Actions
    States := aStates; // = increment Interface States
  end;
end;


// Exports
exports
  InitDLL,
  TerminDLL,
  NewExtAI,
  InitNewExtAI;

begin
end.
