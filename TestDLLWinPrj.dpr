program TestDLLWinPrj;
{$I KM_CompilerDirectives.inc}
uses
  System.StartUpCopy,
  FMX.Forms,
  Consts in 'src\Consts.pas',
  Game in 'src\Game.pas',
  Hand in 'src\Hand.pas',
  HandAI_Ext in 'src\HandAI_Ext.pas',
  TestDLLWin in 'TestDLLWin.pas' {PPLWin} ,
  ExtAIDataTypes in 'src\extai\ExtAIDataTypes.pas',
  ExtAIInterfaceDelphi in 'src\extai\ExtAIInterfaceDelphi.pas',
  ExtAI_DLL in 'src\extai\ExtAI_DLL.pas',
  ExtAI_DLLs in 'src\extai\ExtAI_DLLs.pas',
  ExtAIMaster in 'src\extai\ExtAIMaster.pas',
  //ExtAIStates in 'src\extai\ExtAIStates.pas',

  // Thread
  {$IFDEF ALLOW_EXT_AI_MULTITHREADING}
  ExtAIQueueActions in 'src\extai\Thread\ExtAIQueueActions.pas',
  ExtAIQueueEvents in 'src\extai\Thread\ExtAIQueueEvents.pas',
  ExtAIThread in 'src\extai\Thread\ExtAIThread.pas',
  {$ENDIF}
  ExtAIQueueStates in 'src\extai\Thread\ExtAIQueueStates.pas',

  ExtAIUtils in 'src\extai\ExtAIUtils.pas';

{$R *.res}

var
  PPLWin: TPPLWin;

begin
  Application.Initialize;
  Application.CreateForm(TPPLWin, PPLWin);
  Application.Run;
end.
