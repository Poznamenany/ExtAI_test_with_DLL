program TestDLLWinPrj;

uses
  System.StartUpCopy,
  FMX.Forms,
  GameHand in               'src\GameHand.pas',
  GameThread in 			'src\GameThread.pas',
  HandAI_Ext in 			'src\HandAI_Ext.pas',
  TestDLLWin in 			'TestDLLWin.pas' {PPLWin},
  ExtAICommDLL in 			'ExtAI\ExtAICommDLL.pas',
  ExtAIDataTypes in 		'ExtAI\ExtAIDataTypes.pas',
  ExtAIInterfaceDelphi in	'ExtAI\ExtAIInterfaceDelphi.pas',
  ExtAIListDLL in 			'ExtAI\ExtAIListDLL.pas',
  ExtAIMain in 				'ExtAI\ExtAIMain.pas',
  ExtAIQueueActions in 		'ExtAI\Thread\ExtAIQueueActions.pas',
  ExtAIQueueEvents in 		'ExtAI\Thread\ExtAIQueueEvents.pas',
  ExtAIQueueStates in 		'ExtAI\Thread\ExtAIQueueStates.pas',
  ExtAIStates in 			'ExtAI\ExtAIStates.pas',
  ExtAIThread in 			'ExtAI\Thread\ExtAIThread.pas',
  ExtAIUtils in 			'ExtAI\ExtAIUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TPPLWin, PPLWin);
  Application.Run;
end.
