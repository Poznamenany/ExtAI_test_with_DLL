program TestDLLWinPrj;
{$I KM_CompilerDirectives.inc}
uses
  System.StartUpCopy,
  FMX.Forms,
  Consts in 'src\Consts.pas',
  Game in 'src\Game.pas',
  Log in 'src\Log.pas',
  Hand in 'src\Hand.pas',
  HandAI_Ext in 'src\HandAI_Ext.pas',
  TestDLLWin in 'TestDLLWin.pas' {PPLWin} ,
  ExtAI_DLL in 'src\extai\ExtAI_DLL.pas',
  ExtAI_DLLs in 'src\extai\ExtAI_DLLs.pas',
  ExtAIActions in 'src\extai\ExtAIActions.pas',
  ExtAIMaster in 'src\extai\ExtAIMaster.pas',
  //ExtAIState in 'src\extai\ExtAIState.pas',

  // Thread
  {$IFDEF ALLOW_EXT_AI_MULTITHREADING}
  ExtAIQueueActions in 'src\extai\Thread\ExtAIQueueActions.pas',
  ExtAIQueueEvents in 'src\extai\Thread\ExtAIQueueEvents.pas',
  ExtAIThread in 'src\extai\Thread\ExtAIThread.pas',
  {$ENDIF}

  ExtAI_SharedTypes in 'src\extai\ExtAI_SharedTypes.pas',
  ExtAI_SharedInterfaces in 'src\extai\ExtAI_SharedInterfaces.pas',
  ExtAIStates in 'src\extai\ExtAIStates.pas',

  ExtAIUtils in 'src\extai\ExtAIUtils.pas';

{$R *.res}

var
  PPLWin: TPPLWin;

begin
  Application.Initialize;
  Application.CreateForm(TPPLWin, PPLWin);
  Application.Run;
end.
