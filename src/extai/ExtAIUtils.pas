unit ExtAIUtils;
interface
uses
  ExtAIDataTypes;

type
  TLogEvent = procedure(aStr: wStr) of Object;
  TExtAIThreadStates = (tsInit, tsRun, tsPause, tsTerminate);
  TLogProgressEvent = procedure(aID: ui8; aTick: ui32; aState: TExtAIThreadStates) of Object;

implementation

end.
