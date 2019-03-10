unit ExtAIUtils;
interface
uses
  Consts, ExtAIDataTypes;

type
  TLogEvent = procedure(aStr: wStr) of Object;

  TExtAIThreadState = (tsInit, tsRun, tsPause, tsTerminate);

  TLogProgressEvent = procedure(aHandIndex: TKMHandIndex; aTick: ui32; aState: TExtAIThreadState) of Object;

implementation

end.
