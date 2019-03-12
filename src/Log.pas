unit Log;
interface
uses
  Windows, Classes,
  System.Threading, System.Diagnostics, System.SysUtils;

type
  TLogEvent = procedure (const aText: string) of object;


  // The main thread of application (= KP, it contain access to DLL and also Hands and it react to the basic events)
  TLog = class
  private
    fOnLog: TLogEvent;
  public
    constructor Create(aOnLog: TLogEvent);
    destructor Destroy; override;
    procedure Log(const aText: string);
  end;
  
 var
   gLog: TLog;

implementation


{ TLog }
constructor TLog.Create(aOnLog: TLogEvent);
begin
  inherited Create;

  fOnLog := aOnLog;

  Log('TLog-Create');
end;


destructor TLog.Destroy;
begin
  Log('TLog-Destroy');

  inherited;
end;


procedure TLog.Log(const aText: string);
begin
  if Assigned(fOnLog) then
    TThread.Synchronize(nil,
      procedure
      begin
        fOnLog(aText);
      end
    );
end;


end.
