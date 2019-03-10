unit TestDLLWin;
{$I KM_CompilerDirectives.inc}
interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, StrUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListView.Types,
  FMX.ListView,
  FMX.Layouts, FMX.ListBox, FMX.Edit,
  Consts, Game,
  ExtAIUtils, ExtAIDataTypes;

type
  TPPLWin = class(TForm)
    btnInitSim: TButton;
    btdRefreshDLLs: TButton;
    btnStartSim: TButton;
    btnTerminate: TButton;
    cbAI1: TComboBox;
    cbAI2: TComboBox;
    cbAI3: TComboBox;
    cbAI4: TComboBox;
    cbAI5: TComboBox;
    cbAI6: TComboBox;
    cbAI7: TComboBox;
    cbAI8: TComboBox;
    cbAI9: TComboBox;
    cbAI10: TComboBox;
    cbAI11: TComboBox;
    cbAI12: TComboBox;
    cbMultithread: TCheckBox;
    edTickCnt: TEdit;
    gbSetup: TGroupBox;
    gbLobby: TGroupBox;
    gbSimulation: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    listBoxDLLs: TListBox;
    lbLog: TListBox;
    pbSimulation: TProgressBar;
    tbTicks: TTrackBar;
    gbMultithread: TGroupBox;
    btnAutoFill: TButton;
    chckbClosed: TCheckBox;
    edAI1: TEdit;
    edAI2: TEdit;
    edAI3: TEdit;
    edAI4: TEdit;
    edAI5: TEdit;
    edAI6: TEdit;
    edAI7: TEdit;
    edAI8: TEdit;
    edAI9: TEdit;
    edAI10: TEdit;
    edAI11: TEdit;
    edAI12: TEdit;
    pbAI12: TProgressBar;
    pbAI11: TProgressBar;
    pbAI10: TProgressBar;
    pbAI9: TProgressBar;
    pbAI8: TProgressBar;
    pbAI7: TProgressBar;
    pbAI6: TProgressBar;
    pbAI5: TProgressBar;
    pbAI4: TProgressBar;
    pbAI3: TProgressBar;
    pbAI2: TProgressBar;
    pbAI1: TProgressBar;
    edDLLPath1: TEdit;
    edDLLPath2: TEdit;
    lbProgress: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var aAction: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure btdRefreshDLLsClick(Sender: TObject);
    procedure btnInitSimClick(Sender: TObject);
    procedure btnStartSimClick(Sender: TObject);
    procedure btnTerminateClick(Sender: TObject);
    procedure tbTicksChange(Sender: TObject);
    procedure btnAutoFillClick(Sender: TObject);
  private
    fGame: TGame;
    // Lobby
    fcbAI: array[0..MAX_HANDS_COUNT-1] of TComboBox;
    fedAI: array[0..MAX_HANDS_COUNT-1] of TEdit;
    fpbAI: array[0..MAX_HANDS_COUNT-1] of TProgressBar;
    // DLL
    procedure RefreshListDLL;
    // Lobby
    procedure InitLobby;
    procedure RefreshExtAIs;
    // Simulation
    procedure InitSimulation;
    procedure RefreshSimButtons;
    // Log
    procedure UpdateSimStatus;
    procedure Log(aLog: wStr);
    procedure ClearLog;
    procedure LogProgress(aHandIndex: TKMHandIndex; aTick: ui32; aState: TExtAIThreadState);
    procedure Overview;
  end;


implementation

{$R *.fmx}


procedure TPPLWin.RefreshListDLL;
var
  K: Integer;
  a: TArray<string>;
begin
  SetLength(a, 2);
  a[0] := edDLLPath1.Text;
  a[1] := edDLLPath2.Text;

  fGame.ExtAIMaster.DLLs.RefreshList(a);

  listBoxDLLs.Items.Clear;
  for K := 0 to fGame.ExtAIMaster.DLLs.Count - 1 do
    listBoxDLLs.Items.Add(ExtractRelativePath(ExtractFilePath(ParamStr(0)), fGame.ExtAIMaster.DLLs[K].Path));

  RefreshExtAIs;
end;

procedure TPPLWin.btdRefreshDLLsClick(Sender: TObject);
begin
  RefreshListDLL;
end;


// Lobby
procedure TPPLWin.InitLobby;
begin
  fedAI[0]  := edAI1;  fpbAI[0]  := pbAI1;  fcbAI[0]  := cbAI1;
  fedAI[1]  := edAI2;  fpbAI[1]  := pbAI2;  fcbAI[1]  := cbAI2;
  fedAI[2]  := edAI3;  fpbAI[2]  := pbAI3;  fcbAI[2]  := cbAI3;
  fedAI[3]  := edAI4;  fpbAI[3]  := pbAI4;  fcbAI[3]  := cbAI4;
  fedAI[4]  := edAI5;  fpbAI[4]  := pbAI5;  fcbAI[4]  := cbAI5;
  fedAI[5]  := edAI6;  fpbAI[5]  := pbAI6;  fcbAI[5]  := cbAI6;
  fedAI[6]  := edAI7;  fpbAI[6]  := pbAI7;  fcbAI[6]  := cbAI7;
  fedAI[7]  := edAI8;  fpbAI[7]  := pbAI8;  fcbAI[7]  := cbAI8;
  fedAI[8]  := edAI9;  fpbAI[8]  := pbAI9;  fcbAI[8]  := cbAI9;
  fedAI[9]  := edAI10; fpbAI[9]  := pbAI10; fcbAI[9]  := cbAI10;
  fedAI[10] := edAI11; fpbAI[10] := pbAI11; fcbAI[10] := cbAI11;
  fedAI[11] := edAI12; fpbAI[11] := pbAI12; fcbAI[11] := cbAI12;
end;

procedure TPPLWin.btnAutoFillClick(Sender: TObject);
var
  K,Offset,Range: Integer;
begin
  Offset := Ord(not chckbClosed.IsChecked);
  Range := fcbAI[0].Count - Offset;
  for K := Low(fcbAI) to High(fcbAI) do
    fcbAI[K].ItemIndex := Round(Offset + Random(Range));
end;

procedure TPPLWin.RefreshExtAIs;
var
  Idx,K,L: si32;
  SelectedName: wStr;
begin
  for K := Low(fedAI) to High(fedAI) do
  begin
    Idx := fcbAI[K].ItemIndex; // Save selected item so it does not reset when we refresh DLL
    SelectedName := '';
    if (Idx > 0) then // -1 = Nothing, 0 = Closed
      SelectedName := fcbAI[K].Items[Idx];

    fcbAI[K].Items.Clear;
    Idx := 0; // Closed by default
    fcbAI[K].Items.Add('Closed');
    for L := 0 to fGame.ExtAIMaster.DLLs.Count-1 do
    begin
      fcbAI[K].Items.Add(fGame.ExtAIMaster.DLLs[L].ExtAIName);
      if (CompareStr(fGame.ExtAIMaster.DLLs[L].ExtAIName, SelectedName) = 0) then
        Idx := L+1;
    end;

    fcbAI[K].ItemIndex := Idx;
  end;
end;


// Simulation
procedure TPPLWin.InitSimulation;
begin
  fGame := TGame.Create(Log, UpdateSimStatus);
  tbTicksChange(nil);
  RefreshSimButtons;
end;

procedure TPPLWin.tbTicksChange(Sender: TObject);
begin
  edTickCnt.Text := IntToStr(Round(tbTicks.Value));
end;

procedure TPPLWin.btnInitSimClick(Sender: TObject);
var
  K,L,cnt: si32;
  SelectedName: wStr;
  ExtAIs: TArray<string>;
begin
  RefreshListDLL; // Make sure that all DLLs are available
  ClearLog;

  // Load ExtAI configuration from Lobby
  SetLength(ExtAIs, MAX_HANDS_COUNT);
  cnt := 0;
  for K := Low(fcbAI) to High(fcbAI) do
  begin
    ExtAIs[K] := '';
    if fcbAI[K].ItemIndex > 0 then
    begin
      SelectedName := fcbAI[K].Items[fcbAI[K].ItemIndex];
      for L := 0 to fGame.ExtAIMaster.DLLs.Count-1 do
        if CompareStr(fGame.ExtAIMaster.DLLs[L].ExtAIName, SelectedName) = 0 then
        begin
          Inc(cnt);
          ExtAIs[K] := fGame.ExtAIMaster.DLLs[L].Path;
          break;
        end;
    end;
  end;

  // Init ExtAI
  if (cnt > 0) then
    fGame.InitSimulation(cbMultithread.IsChecked, ExtAIs, LogProgress);

  RefreshSimButtons;
end;


procedure TPPLWin.btnStartSimClick(Sender: TObject);
begin
  if (fGame.SimulationState = ssInit) then
    fGame.StartSimulation(Round(StrToInt(edTickCnt.Text))) // Start ExtAI threads
  else
    fGame.PauseSimulation;

  RefreshSimButtons;
end;


procedure TPPLWin.btnTerminateClick(Sender: TObject);
begin
  fGame.TerminateSimulation;
  Sleep(SLEEP_EVERY_TICK*10);
  fGame.Free;
  InitSimulation;
  RefreshListDLL;
  RefreshSimButtons;
  Overview;
end;

procedure TPPLWin.RefreshSimButtons;
begin
  case fGame.SimulationState of
    ssCreated:    begin
                    btnInitSim.Enabled := True;
                    btnStartSim.Enabled := False;
                    btnStartSim.Text := 'Start';
                  end;
    ssInit:       begin
                    btnInitSim.Enabled := False;
                    btnStartSim.Enabled := True;
                    btnStartSim.Text := 'Start';
                  end;
    ssInProgress: begin
                    btnInitSim.Enabled := False;
                    btnStartSim.Enabled := True;
                    btnStartSim.Text := 'Pause';
                  end;
    ssPaused:     begin
                    btnInitSim.Enabled := False;
                    btnStartSim.Enabled := True;
                    btnStartSim.Text := 'Start';
                  end;
    ssTerminated: begin
                    btnInitSim.Enabled := False;
                    btnStartSim.Enabled := False;
                    btnStartSim.Text := 'Start';
                  end;
  end;
end;


// Form
procedure TPPLWin.FormCreate(Sender: TObject);
begin
  InitSimulation;
  InitLobby;
  RefreshListDLL;

  {$IFDEF ALLOW_EXT_AI_MULTITHREADING}
  cbMultithread.Enabled := True;
  cbMultithread.IsChecked := True;
  {$ELSE}
  cbMultithread.Enabled := False;
  cbMultithread.IsChecked := False;
  {$ENDIF}
end;


procedure TPPLWin.FormClose(Sender: TObject; var aAction: TCloseAction);
begin
  aAction := TCloseAction.caFree;
  if (fGame.SimulationState <> ssTerminated) then
  begin
    fGame.TerminateSimulation;
    Sleep(SLEEP_EVERY_TICK*10);
  end;
end;


procedure TPPLWin.FormDestroy(Sender: TObject);
begin
  fGame.Free;
end;


// Log
procedure TPPLWin.UpdateSimStatus;
begin
  pbSimulation.Value := fGame.Tick / fGame.MaxTick;
  lbProgress.Text := IntToStr(fGame.Tick) + '/' + IntToStr(fGame.MaxTick);
  RefreshSimButtons;
  Invalidate;
end;

procedure TPPLWin.Log(aLog: wStr);
begin
  lbLog.Items.Add(aLog);
  lbLog.ItemIndex := lbLog.Items.Count - 1;
end;

procedure TPPLWin.ClearLog;
begin
  lbLog.Items.Clear;
end;

procedure TPPLWin.LogProgress(aHandIndex: TKMHandIndex; aTick: ui32; aState: TExtAIThreadState);
begin
  case aState of
    tsInit:       fedAI[aHandIndex].Text := 'Init';
    tsRun:        fedAI[aHandIndex].Text := 'Run';
    tsPause:      fedAI[aHandIndex].Text := 'Pause';
    tsTerminate:  fedAI[aHandIndex].Text := 'Terminate';
  end;
  fpbAI[aHandIndex].Value := aTick / fGame.MaxTick;
end;

procedure TPPLWin.Overview;
type
  TOverview = record
    Init, Termin: b;
    ID: ui8;
    Name: wStr;
  end;
var
  K: si32;
  str: wStr;
  Actions, Events, Hands, Threads: array [0..MAX_HANDS_COUNT-1] of TOverview;
  Stats: TOverview;
begin
  for K := lbLog.Count-1 downto 0 do
  begin
    str := lbLog.Items[K];
    if      AnsiPos('TExtAIThread-Create: ID =', str) > 0 then        Threads[ StrToInt( AnsiMidStr(str, Length(str)-1,2) ) ].Init := True
    else if AnsiPos('TExtAIThread-Destroy: ID =', str) > 0 then       Threads[ StrToInt( AnsiMidStr(str, Length(str)-1,2) ) ].Termin := True
    else if AnsiPos('TExtAIQueueActions-Create: ID =', str) > 0 then  Actions[ StrToInt( AnsiMidStr(str, Length(str)-1,2) ) ].Init := True
    else if AnsiPos('TExtAIQueueActions-Destroy: ID =', str) > 0 then Actions[ StrToInt( AnsiMidStr(str, Length(str)-1,2) ) ].Termin := True
    else if AnsiPos('TExtAIQueueEvents-Create: ID =', str) > 0 then   Events[  StrToInt( AnsiMidStr(str, Length(str)-1,2) ) ].Init := True
    else if AnsiPos('TExtAIQueueEvents-Destroy: ID =', str) > 0 then  Events[  StrToInt( AnsiMidStr(str, Length(str)-1,2) ) ].Termin := True
    else if AnsiPos('THandAIExt-Create: ID =', str) > 0 then          Hands[   StrToInt( AnsiMidStr(str, Length(str)-1,2) ) ].Init := True
    else if AnsiPos('THandAIExt-Destroy: ID =', str) > 0 then         Hands[   StrToInt( AnsiMidStr(str, Length(str)-1,2) ) ].Termin := True
    else if AnsiPos('TExtAIQueueStates-Create', str) > 0 then         Stats.Init := True
    else if AnsiPos('TExtAIQueueStates-Destroy', str) > 0 then        Stats.Termin := True;
  end;

  for K := Low(Actions) to High(Actions) do
  begin
    if (Threads[K].Init OR Threads[K].Termin) <> (Threads[K].Init AND Threads[K].Termin) then
      Log('WARNING: Init/Termin THREAD: ' + IntToStr(K));
    if (Actions[K].Init OR Actions[K].Termin) <> (Actions[K].Init AND Actions[K].Termin) then
      Log('WARNING: Init/Termin ACTION: ' + IntToStr(K));
    if (Events[K].Init OR Events[K].Termin) <> (Events[K].Init AND Events[K].Termin) then
      Log('WARNING: Init/Termin EVENT: ' + IntToStr(K));
    if (Hands[K].Init OR Hands[K].Termin) <> (Hands[K].Init AND Hands[K].Termin) then
      Log('WARNING: Init/Termin HANS: ' + IntToStr(K));
  end;

  if (Stats.Init OR Stats.Termin) <> (Stats.Init AND Stats.Termin) then
    Log('WARNING: Init/Termin STATS');
end;

end.
