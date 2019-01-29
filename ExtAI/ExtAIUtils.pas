unit ExtAIUtils;
interface
uses
  ExtAIDataTypes;

type
  TLog = procedure(aStr: wStr) of Object;
  TExtAIThreadStates = (tsInit, tsRun, tsPause, tsTerminate);
  TLogProgress = procedure(aID: ui8; aTick: ui32; aState: TExtAIThreadStates) of Object;

implementation

end.
