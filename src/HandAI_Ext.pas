unit HandAI_Ext;
interface
uses
  Windows, System.SysUtils,
  Consts, ExtAI_SharedInterfaces, ExtAI_SharedTypes, ExtAIActions, ExtAIUtils;

type
  // ExtAI class for Hands - process flow of events and actions
  THandAI_Ext = class
  private
    fHandIndex: TKMHandIndex;

    // Create instances and pass them to DLL for use
    fIActions: TExtAIActions;
    fIEvents: IEvents;
  public
    constructor Create(aHandIndex: TKMHandIndex);
    destructor Destroy; override;

    property HandIndex: TKMHandIndex read fHandIndex;
    property IActions: TExtAIActions read fIActions;
    procedure AssignEvents(aIEvents: IEvents); // ExtAI DLL gives IEvents to us

    procedure OnMissionStart();
    procedure OnTick(aTick: Cardinal);
    procedure OnPlayerDefeated(aHandIndex: TKMHandIndex);
    procedure OnPlayerVictory(aHandIndex: TKMHandIndex);
  end;


implementation
uses
  Log;

{ THandAI_Ext }
constructor THandAI_Ext.Create(aHandIndex: TKMHandIndex);
begin
  inherited Create;

  fHandIndex := aHandIndex;

  fIActions := TExtAIActions.Create(aHandIndex);

  gLog.Log('  THandAIExt-Create: HandIndex = ' + IntToStr(fHandIndex));
end;


destructor THandAI_Ext.Destroy;
begin
  gLog.Log('  THandAIExt-Destroy: HandIndex = ' + IntToStr(fHandIndex));

  inherited;
end;


procedure THandAI_Ext.AssignEvents(aIEvents: IEvents);
begin
  fIEvents := aIEvents;
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
