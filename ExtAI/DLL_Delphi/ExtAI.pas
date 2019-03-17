unit ExtAI;
interface
uses
  Windows, System.SysUtils,
  ExtAI_SharedInterfaces, ExtAI_SharedTypes;

type
  TExtAI = class(TInterfacedObject, IEvents)
  strict private
    fGroupCountOwn: ui32;
    fGroupsOwn: TGroupInfoArray;
    fEnemyOfTheState: ui32;

    // Test
    procedure Test;
    procedure Test2(aTick: ui32);

    // Log
    procedure Log(aLog: wStr); overload;
    procedure Log(aLog: wStr; aArgs: array of const); overload;
  private
    //fMap: ui32Arr;
    // IInterface
    //procedure AfterConstruction; override;
    //procedure BeforeDestruction; override;

    // IEvents
    procedure OnMissionStart(); StdCall;
    procedure OnTick(aTick: ui32); StdCall;
    procedure OnPlayerDefeated(aPlayer: si8); StdCall;
    procedure OnPlayerVictory(aPlayer: si8); StdCall;

  public
    Actions: IActions;
    States: IStates;
    ID: ui8;

    constructor Create();
    destructor Destroy(); override;
  end;

implementation

{ TExtAI }
constructor TExtAI.Create();
begin
  inherited Create();
  ID := 0;
  Actions := nil;
end;

destructor TExtAI.Destroy();
begin
  Actions := nil;
  inherited;
end;


procedure TExtAI.OnMissionStart();
begin
  Log('    TExtAI-OnMissionStart: ID = %d', [ID]);
end;


procedure TExtAI.OnTick(aTick: ui32);
begin
  Log('    TExtAI-OnTick: ID = %d', [ID]);

  //Test;
  Test2(aTick);
end;


procedure TExtAI.OnPlayerDefeated(aPlayer: si8);
begin
  Log('    TExtAI-OnPlayerDefeated: ID = %d', [ID]);
end;


procedure TExtAI.OnPlayerVictory(aPlayer: si8);
begin
  Log('    TExtAI-OnPlayerVictory: ID = %d', [ID]);
end;


procedure TExtAI.Log(aLog: wStr);
begin
  Actions.LogDLL(Addr(aLog[1]), Length(aLog));
end;


procedure TExtAI.Log(aLog: wStr; aArgs: array of const);
begin
  Log(Format(aLog, aArgs));
end;


procedure TExtAI.Test;
type
  ab = array of b;
var
  feedback: ui8;
  Len, K: si32;
  pFirstElem: pui32;
  res: b;
  tx, ty: ui16;
  tp: pb;
begin
  //Log('    TExtAI-OnTick: ID = ' + IntToStr(ID));
  // Test actions
  res := Actions.GroupOrderAttackUnit(11,22);
  res := Actions.GroupOrderWalk(1,50,50,1);

  // Test states
  feedback := States.State1(11);
  if (feedback <> 11) then
    Log('    TExtAI-OnTick: wrong States.State1 feedback = %d', [feedback]);

  feedback := States.UnitAt(5,5);
  if (feedback <> 11) then
    Log('    TExtAI-OnTick: wrong States.UnitAt feedback = %d', [feedback]);

  States.TerrainSize(tx, ty);
  Log('    TExtAI-OnTick: States.TerrainSize is %dx%d', [tx, ty]);

  GetMem(tp, tx*ty);
  States.TerrainPassability(tp);
  Log('    TExtAI-OnTick: States.TerrainPassability[24] is %d', [Ord(ab(tp)[24])]);
  Log('    TExtAI-OnTick: States.TerrainPassability[12] is %d', [Ord(ab(tp)[12])]);
  FreeMem(tp);

  {if States.MapTerrain(ID,pFirstElem,Len) then
  begin
    if (Len <> Length(fMap)) then
      SetLength(fMap,Len);
    Move(pFirstElem^, fMap[0], SizeOf(fMap[0]) * Length(fMap));
    for K := Low(fMap) to High(fMap)-1 do
      if (fMap[K] >= fMap[K+1]) then
      begin
        Log('    TExtAI-OnTick: problem in testing map, val: ' + IntToSTr(fMap[K]) + ' vs ' + IntToSTr(fMap[K+1]));
        break;
      end;
  end;}
end;


procedure TExtAI.Test2(aTick: ui32);
var
  I, K: Integer;
  unitCountEnemy: ui32;
  unitsEnemy: TUnitInfoArray;
begin
  // This is KISS version, very inefficient. Just proof the concept

  // Update own units state once every 10 seconds
  if aTick mod 100 = 1 then
  begin
    fGroupCountOwn := States.GetGroupCount(ID);
    SetLength(fGroupsOwn, fGroupCountOwn);
    if fGroupCountOwn > 0 then
      States.GetGroups(ID, @fGroupsOwn[0], fGroupCountOwn);

    Log('Got %d own Units', [fGroupCountOwn]);
  end;

  // check we have an enemy
  if (aTick mod 10 = 1) then
    if not States.UnitIsAlive(fEnemyOfTheState) then
      fEnemyOfTheState := 0;

  // Look for opportunities to attack once a sec
  if (aTick mod 10 = 1) and (fGroupCountOwn > 0) and (fEnemyOfTheState = 0) then
  begin
    // Find enemy units
    for I := 0 to 4{MAX_HANDS} - 1 do
    if I <> ID then
    begin
      unitCountEnemy := States.GetUnitCount(I);
      SetLength(unitsEnemy, unitCountEnemy);
      if unitCountEnemy > 0 then
        States.GetUnits(I, @unitsEnemy[0], unitCountEnemy);
      Log('Got %d Units belonging to %d enemy', [unitCountEnemy, I]);

      // Act
      if unitCountEnemy > 0 then
      begin
        fEnemyOfTheState := unitsEnemy[0].UID;
        Log('Going go attack %d', [fEnemyOfTheState]);

        // Order attack
        for K := 0 to fGroupCountOwn - 1 do
          if not Actions.GroupOrderAttackUnit(fGroupsOwn[K].UID, fEnemyOfTheState) then
            Log('Failed to attack');
      end;

      Break;
    end;
  end;
end;


end.
