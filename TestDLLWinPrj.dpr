program TestDLLWinPrj;

uses
  System.StartUpCopy,
  FMX.Forms,
  GameHand in               'src\GameHand.pas',
  GameThread in 			'src\GameThread.pas',
  HandAI_Ext in 			'src\HandAI_Ext.pas',
  TestDLLWin in 			'TestDLLWin.pas' {PPLWin},
  ExtAICommDLL in 			'src\extai\ExtAICommDLL.pas',
  ExtAIDataTypes in 		'src\extai\ExtAIDataTypes.pas',
  ExtAIInterfaceDelphi in	'src\extai\ExtAIInterfaceDelphi.pas',
  ExtAIListDLL in 			'src\extai\ExtAIListDLL.pas',
  ExtAIMain in 				'src\extai\ExtAIMain.pas',
  ExtAIQueueActions in 		'src\extai\Thread\ExtAIQueueActions.pas',
  ExtAIQueueEvents in 		'src\extai\Thread\ExtAIQueueEvents.pas',
  ExtAIQueueStates in 		'src\extai\Thread\ExtAIQueueStates.pas',
  ExtAIStates in 			'src\extai\ExtAIStates.pas',
  ExtAIThread in 			'src\extai\Thread\ExtAIThread.pas',
  ExtAIUtils in 			'src\extai\ExtAIUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TPPLWin, PPLWin);
  Application.Run;
end.
