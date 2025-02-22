//*
#include "DataTypes.h"
#include <windows.h>

#ifndef DLL_Library_H
#define DLL_Library_H

#define ADDCALL __stdcall

// Events interface (it is called from Delphi to Delphi)
// 8E77167C-CC59-4917-BE0B-BCF311B3CEEE
static const GUID IID_IEvents =
{0x8E77167C, 0xCC59, 0x4917, { 0xBE, 0x0B, 0xBC, 0xF3, 0x11, 0xB3, 0xCE, 0xEE} };

interface IEvents: IUnknown
{
public:
    virtual void ADDCALL OnMissionStart() = 0; 
    virtual void ADDCALL OnTick(ui32 aTick) = 0; 
    virtual void ADDCALL OnPlayerDefeated(si8 aPlayer) = 0; 
    virtual void ADDCALL OnPlayerVictory(si8 aPlayer) = 0; 
};
typedef IEvents * pIEvents;


// Actions interface (it is called from C to Delphi)
// 66FDB631-E3DC-4B8E-A745-4337C487ED69
static const GUID IID_IActions =
{0x66FDB631, 0xE3DC, 0x4B8E, { 0xA7, 0x45, 0x43, 0x37, 0xC4, 0x87, 0xED, 0x69} };

interface IActions: IUnknown
{
public:
    virtual void ADDCALL GroupOrderAttackUnit(ui32 aGroupID, ui32 aUnitID) = 0;
    virtual void ADDCALL GroupOrderWalk(ui32 aGroupID, ui16 aX, ui16 aY, ui16 aDirection) = 0;
	virtual void ADDCALL LogDLL(wStr const* apLog, ui32 aLen) = 0;
};
typedef IActions * pIActions;


// States interface (it is called from C to Delphi)
// 2A228001-8FE0-4A01-8B5D-5D7D8394B1DD
static const GUID IID_IStates =
{0x2A228001, 0x8FE0, 0x4A01, { 0x8B, 0x5D, 0x5D, 0x7D, 0x83, 0x94, 0xB1, 0xDD} };

interface IStates: IUnknown
{
public:
    virtual ui8 ADDCALL State1(ui32 aID) = 0;
    virtual b ADDCALL MapTerrain(ui8 aID, pui32 & aFirstElem, si32 & aLength) = 0;
};
typedef IStates * pIStates;


#ifdef __cplusplus
extern "C" {
#endif

// Communication interface
void ADDCALL InitDLL(TDLLpConfig *aConfig);
void ADDCALL TerminDLL(void);
void ADDCALL InitNewExtAI(ui8 aID, pIActions aActions, pIStates aStates);
HRESULT ADDCALL NewExtAI(pIEvents *aEvents);

// Callback for communication interface
typedef b (ADDCALL *pCallback1) (ui8) ADDCALL;
void ADDCALL RegisterCallback1(pCallback1 aCallback1);

#ifdef __cplusplus
}
#endif

#endif  // DLL_Library_H