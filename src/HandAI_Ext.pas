unit HandAI_Ext;
interface
uses
  Windows, System.SysUtils,
  Consts,
  ExtAIMaster, ExtAI_SharedInterfaces, ExtAI_SharedTypes, ExtAIActions, ExtAIUtils;

type
  TKMHandAI = class
  protected
    fHandIndex: TKMHandIndex;
  public
    constructor Create(aHandIndex: TKMHandIndex);
    property HandIndex: TKMHandIndex read fHandIndex;
  end;

  THandAI_Ext = class(TKMHandAI)
  private
    // Create instances and pass them to DLL for use
    fIActions: TExtAIActions;
    fIEvents: IEvents;
  public
    constructor Create(aHandIndex: TKMHandIndex);
    destructor Destroy; override;

    // This is where we choose the DLL this ExtAI will use
    procedure SetIndex(aExtAIIndex: Integer; aExtAIMaster: TExtAIMaster; aMultithread: Boolean; aLogProgress: TLogProgressEvent);

    procedure OnMissionStart();
    procedure OnTick(aTick: Cardinal);
    procedure OnPlayerDefeated(aHandIndex: TKMHandIndex);
    procedure OnPlayerVictory(aHandIndex: TKMHandIndex);
  end;


implementation
uses
  Log;

{ TKMHandAI }
constructor TKMHandAI.Create(aHandIndex: TKMHandIndex);
begin
  inherited Create;

  fHandIndex := aHandIndex;
end;


{ THandAI_Ext }
constructor THandAI_Ext.Create(aHandIndex: TKMHandIndex);
begin
  inherited;

  fIActions := TExtAIActions.Create(aHandIndex);

  gLog.Log('  THandAIExt-Create: HandIndex = ' + IntToStr(fHandIndex));
end;


destructor THandAI_Ext.Destroy;
begin
  gLog.Log('  THandAIExt-Destroy: HandIndex = ' + IntToStr(fHandIndex));
  inherited;
end;


procedure THandAI_Ext.SetIndex(aExtAIIndex: Integer; aExtAIMaster: TExtAIMaster; aMultithread: Boolean; aLogProgress: TLogProgressEvent);
begin
  aExtAIMaster.RigNewExtAI(fHandIndex, fIActions, fIEvents, aMultithread, aExtAIIndex, aLogProgress);
end;


// IEvents - calling of functions in the interface (or delete this part and use directly public variable Events)
procedure THandAI_Ext.OnMissionStart();
begin
  fIEvents.OnMissionStart();
end;


procedure THandAI_Ext.OnTick(aTick: Cardinal);
begin
  fIEvents.OnTick(aTick);
end;


procedure THandAI_Ext.OnPlayerDefeated(aHandIndex: TKMHandIndex);
begin
  fIEvents.OnPlayerDefeated(aHandIndex);
end;


procedure THandAI_Ext.OnPlayerVictory(aHandIndex: TKMHandIndex);
begin
  fIEvents.OnPlayerVictory(aHandIndex);
end;


end.
