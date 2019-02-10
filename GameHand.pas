unit GameHand;
interface
uses
  Windows, System.SysUtils,
  ExtAIHand, ExtAIUtils, ExtAIDataTypes;

type
  // Game class for Hand. It hides the ExtAI inside of it
  TGameHand = class
  private
    fHandIndex: Integer;
    fExtAIHand: TExtAIHand;
    fOnLog: TLogEvent;

    // Log
    procedure Log(aLog: wStr);
  public
    property HandIndex: Integer read fHandIndex;

    constructor Create(aHandIndex: Integer; aLog: TLogEvent; aExtAIHand: TExtAIHand); reintroduce;
    destructor Destroy; override;

    procedure UpdateState(aTick: Integer);
  end;

implementation


{ TGameHand }
constructor TGameHand.Create(aHandIndex: Integer; aLog: TLogEvent; aExtAIHand: TExtAIHand);
begin
  inherited Create();
  fHandIndex := aHandIndex;
  fOnLog := aLog;

  fExtAIHand := aExtAIHand;

  Log('  TGameHand-Create: ID = '+IntToStr(fHandIndex));
end;


destructor TGameHand.Destroy();
begin
  FreeAndNil(fExtAIHand);
  Log('  TGameHand-Destroy: ID = '+IntToStr(fHandIndex));
  inherited;
end;


procedure TGameHand.Log(aLog: wStr);
begin
  if Assigned(fOnLog) then
    fOnLog(aLog);
end;


procedure TGameHand.UpdateState(aTick: Integer);
const
  FIRST_TICK = 1;
begin
  if aTick = FIRST_TICK then
    fExtAIHand.OnMissionStart;

  fExtAIHand.OnTick(aTick);
end;

end.