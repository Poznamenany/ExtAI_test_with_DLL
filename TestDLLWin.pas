unit TestDLLWin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.Layouts, FMX.ListBox, FMX.Edit,
  MainThread,
  ExtAIListDLL, ExtAIUtils, ExtAIDataTypes;

const
  MAX_AI_CNT = 12;
type
  TPPLWin = class(TForm)
    btnInitSim: TButton;
    btdRefreshDLLs: TButton;
    btnSelectFolder1: TButton;
    btnSelectFolder2: TButton;
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
    chckbMultithread: TCheckBox;
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
    edFolderDLL1: TEdit;
    edFolderDLL2: TEdit;
    edTickCnt: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
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
    ListBoxLOG: TListBox;
    pbAI1: TProgressBar;
    pbAI2: TProgressBar;
    pbAI3: TProgressBar;
    pbAI4: TProgressBar;
    pbAI5: TProgressBar;
    pbAI6: TProgressBar;
    pbAI7: TProgressBar;
    pbAI8: TProgressBar;
    pbAI9: TProgressBar;
    pbAI10: TProgressBar;
    pbAI11: TProgressBar;
    pbAI12: TProgressBar;
    pbSimulation: TProgressBar;
    tbTicks: TTrackBar;
    GroupBox4: TGroupBox;
    btnAutoFill: TButton;
    chckbClosed: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSelectFolder1Click(Sender: TObject);
    procedure btnSelectFolder2Click(Sender: TObject);
    procedure btdRefreshDLLsClick(Sender: TObject);
    procedure btnInitSimClick(Sender: TObject);
    procedure btnStartSimClick(Sender: TObject);
    procedure btnTerminateClick(Sender: TObject);
    procedure tbTicksChange(Sender: TObject);
    procedure btnAutoFillClick(Sender: TObject);
  private
    fMainThread: TMainThread;
    // DLL
    fListDLL: TListDLL;
    // Lobby
    fcbAI: array[1..MAX_AI_CNT] of TComboBox;
    fedAI: array[1..MAX_AI_CNT] of TEdit;
    fpbAI: array[1..MAX_AI_CNT] of TProgressBar;
    // DLL
    procedure InitDLL(Sender: TObject);
    procedure RefreshListDLL(Sender: TObject);
    // Lobby
    procedure InitLobby(Sender: TObject);
    procedure RefreshExtAIs(Sender: TObject);
    // Simulation
    procedure InitSimulation(Sender: TObject);
    procedure RefreshSimButtons(Sender: TObject);
    // Log
    procedure UpdateSimStatus();
    procedure Log(aLog: wStr);
    procedure ClearLog();
    procedure LogProgress(aID: ui8; aTick: ui32; aState: TExtAIThreadStates);
  public
    { Public declarations }
  end;

var
  PPLWin: TPPLWin;

implementation

{$R *.fmx}


// DLLs
procedure TPPLWin.InitDLL(Sender: TObject);
begin
  edFolderDLL1.Text := ExpandFileName( ExtractFilePath(ParamStr(0)) + '\..\..\ExtAI\DLLs' );
  edFolderDLL2.Text := ExpandFileName( ExtractFilePath(ParamStr(0)) + '\..\..\ExtAI\DLLs\DLL_Delphi\Win32' );
  RefreshListDLL(Sender);
end;

procedure TPPLWin.RefreshListDLL(Sender: TObject);
var
  Folders: wStrArr;
  K: si32;
begin
  SetLength(Folders,2);
  Folders[0] := edFolderDLL1.Text;
  Folders[1] := '';
  if (CompareStr(Folders[0],edFolderDLL2.Text) <> 0) then // Do not load the same path 2x
    Folders[1] := edFolderDLL2.Text;

  fListDLL := fMainThread.GetDLLs(Folders);

  listBoxDLLs.Items.Clear();
  for K := 0 to fListDLL.Count-1 do
    listBoxDLLs.Items.Add(fListDLL[K].Path);

  RefreshExtAIs(Sender);
end;

procedure TPPLWin.btnSelectFolder1Click(Sender: TObject);
var
  chosenDirectory : string;
begin
  if SelectDirectory('Select a directory with DLL', edFolderDLL1.Text, chosenDirectory) then
    edFolderDLL1.Text := chosenDirectory;
  RefreshListDLL(Sender);
end;

procedure TPPLWin.btnSelectFolder2Click(Sender: TObject);
var
  chosenDirectory : string;
begin
  if SelectDirectory('Select a directory with second DLL', edFolderDLL2.Text, chosenDirectory) then
    edFolderDLL2.Text := chosenDirectory;
  RefreshListDLL(Sender);
end;

procedure TPPLWin.btdRefreshDLLsClick(Sender: TObject);
begin
  RefreshListDLL(Sender);
end;



// Lobby
procedure TPPLWin.InitLobby(Sender: TObject);
begin
  fedAI[1]  := edAI1;  fpbAI[1]  := pbAI1;  fcbAI[1]  := cbAI1;
  fedAI[2]  := edAI2;  fpbAI[2]  := pbAI2;  fcbAI[2]  := cbAI2;
  fedAI[3]  := edAI3;  fpbAI[3]  := pbAI3;  fcbAI[3]  := cbAI3;
  fedAI[4]  := edAI4;  fpbAI[4]  := pbAI4;  fcbAI[4]  := cbAI4;
  fedAI[5]  := edAI5;  fpbAI[5]  := pbAI5;  fcbAI[5]  := cbAI5;
  fedAI[6]  := edAI6;  fpbAI[6]  := pbAI6;  fcbAI[6]  := cbAI6;
  fedAI[7]  := edAI7;  fpbAI[7]  := pbAI7;  fcbAI[7]  := cbAI7;
  fedAI[8]  := edAI8;  fpbAI[8]  := pbAI8;  fcbAI[8]  := cbAI8;
  fedAI[9]  := edAI9;  fpbAI[9]  := pbAI9;  fcbAI[9]  := cbAI9;
  fedAI[10] := edAI10; fpbAI[10] := pbAI10; fcbAI[10] := cbAI10;
  fedAI[11] := edAI11; fpbAI[11] := pbAI11; fcbAI[11] := cbAI11;
  fedAI[12] := edAI12; fpbAI[12] := pbAI12; fcbAI[12] := cbAI12;
end;

procedure TPPLWin.btnAutoFillClick(Sender: TObject);
var
  K,Offset,Range: si32;
begin
  Offset := si32(NOT chckbClosed.IsChecked);
  Range := fcbAI[1].Count - Offset;
  for K := Low(fcbAI) to High(fcbAI) do
    fcbAI[K].ItemIndex := Round(Offset+Random(Range));
end;

procedure TPPLWin.RefreshExtAIs(Sender: TObject);
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
    Idx := 0;
    fcbAI[K].Items.Add('Closed');
    for L := 0 to fListDLL.Count-1 do
    begin
      fcbAI[K].Items.Add(fListDLL[L].ExtAIName);
      if (CompareStr(fListDLL[L].ExtAIName,SelectedName) = 0) then
        Idx := L+1;
    end;
    fcbAI[K].ItemIndex := Idx;
  end;
end;


// Simulation
procedure TPPLWin.InitSimulation(Sender: TObject);
begin
  fMainThread := TMainThread.Create(Log,UpdateSimStatus);
  tbTicksChange(Sender);
  RefreshSimButtons(Sender);
end;

procedure TPPLWin.tbTicksChange(Sender: TObject);
begin
  edTickCnt.Text := FloatToStr(Round(tbTicks.Value));
end;

procedure TPPLWin.btnInitSimClick(Sender: TObject);
var
  K,L,cnt: si32;
  SelectedName: wStr;
  ExtAIs: wStrArr;
begin
  RefreshListDLL(Sender); // Make sure that all DLLs are available
  ClearLog();
  // Load ExtAI configuration from Lobby
  SetLength(ExtAIs,MAX_AI_CNT);
  cnt := 0;
  for K := Low(fcbAI) to High(fcbAI) do
  begin
    ExtAIs[K-1] := '';
    if (fcbAI[K].ItemIndex > 0) then
    begin
      SelectedName := fcbAI[K].Items[ fcbAI[K].ItemIndex ];
      for L := 0 to fListDLL.Count-1 do
        if (CompareStr(fListDLL[L].ExtAIName,SelectedName) = 0) then
        begin
          Inc(cnt);
          ExtAIs[K-1] := fListDLL[L].Path;
          break;
        end;
    end;
  end;
  // Init ExtAI
  if (cnt > 0) then
    fMainThread.InitSimulation(chckbMultithread.Ischecked,ExtAIs,LogProgress);
  RefreshSimButtons(Sender);
end;


procedure TPPLWin.btnStartSimClick(Sender: TObject);
begin
  if (fMainThread.SimulationState = ssInit) then
  begin
    fMainThread.MaxTick := Round(tbTicks.Value);
    fMainThread.StartSimulation(); // Start ExtAI threads
    fMainThread.Start();
  end
  else
    fMainThread.PauseSimulation();
  RefreshSimButtons(Sender);
end;

procedure TPPLWin.btnTerminateClick(Sender: TObject);
begin
  fMainThread.TerminateSimulation();
  Sleep(SLEEP_EVERY_TICK*10);
  fMainThread.Free();
  InitSimulation(Sender);
  RefreshListDLL(Sender);
  RefreshSimButtons(Sender);
end;

procedure TPPLWin.RefreshSimButtons(Sender: TObject);
begin
  // Default
  btnInitSim.Enabled := False;
  btnStartSim.Text := 'Start';
  btnStartSim.Enabled := True;
  // Special
  case fMainThread.SimulationState of
    ssCreated:
      begin
        btnInitSim.Enabled := True;
        btnStartSim.Enabled := False;
      end;
    ssInit:
      begin
      end;
    ssInProgress:
      begin
        btnStartSim.Text := 'Pause';
      end;
    ssPaused:
      begin
      end;
    ssTerminated:
      begin
        btnStartSim.Enabled := False;
      end;
  end;
end;


// Form
procedure TPPLWin.FormCreate(Sender: TObject);
begin
  fListDLL := nil;
  InitSimulation(Sender);
  InitLobby(Sender);
  InitDLL(Sender);
end;

procedure TPPLWin.FormDestroy(Sender: TObject);
begin
  fMainThread.Free();
  fListDLL.Free();
end;


// Log
procedure TPPLWin.UpdateSimStatus();
begin
  pbSimulation.Value := fMainThread.Tick/fMainThread.MaxTick;
  RefreshSimButtons(nil);
end;

procedure TPPLWin.Log(aLog: wStr);
begin
  ListBoxLog.Items.Add(aLog);
  ListBoxLog.ItemIndex := ListBoxLog.Items.Count - 1;
end;

procedure TPPLWin.ClearLog();
begin
  ListBoxLog.Items.Clear;
end;

procedure TPPLWin.LogProgress(aID: ui8; aTick: ui32; aState: TExtAIThreadStates);
begin
  case aState of
    tsInit: fedAI[aID].Text := 'Init';
    tsRun: fedAI[aID].Text := 'Run';
    tsPause: fedAI[aID].Text := 'Pause';
    tsTerminate: fedAI[aID].Text := 'Terminate';
  end;
  fpbAI[aID].Value := aTick/fMainThread.MaxTick;
end;

end.
