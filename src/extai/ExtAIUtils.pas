unit ExtAIUtils;
interface
uses
  Consts, ExtAI_SharedTypes;

type
  TExtAIThreadState = (tsInit, tsRun, tsPause, tsTerminate);

  TLogProgressEvent = procedure(aHandIndex: TKMHandIndex; aTick: ui32; aState: TExtAIThreadState) of Object;

implementation

end.
