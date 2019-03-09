#include <stdio.h>
#include "DLL_ExtAI.h"

// Constants
const ui8 MAX_EXT_AI_CNT = 12;

const TDLLConfig CONFIG =
{
	L"Jesus of Nazareth", // Author
	L"Test example for DLL with External AI (C DLL)", // Description
	L"TestingExtAI C", // Name of the ExtAI
	20190129 // Version
};

// Variables
ui8 ExtAICnt; // ExtAI cnt
pTExtAI ExtAI [MAX_EXT_AI_CNT]; // pointers to possible ExtAI

// Events
void ADDCALL InitDLL(TDLLpConfig *aConfig)
{
	ExtAICnt = 0;
	for (ui8 K = 0; K < MAX_EXT_AI_CNT; K++)
	{
		ExtAI[K] = NULL;
	}
	aConfig->Author = CONFIG.Author;
	aConfig->AuthorLen = wcslen(CONFIG.Author);
	aConfig->Description = CONFIG.Description;
	aConfig->DescriptionLen = wcslen(CONFIG.Description);
	aConfig->ExtAIName = CONFIG.ExtAIName;
	aConfig->ExtAINameLen = wcslen(CONFIG.ExtAIName);
	aConfig->Version = CONFIG.Version;
}

void ADDCALL TerminDLL(void) 
{
	for (ui8 K = 0; K < MAX_EXT_AI_CNT; K++)
	{
		if (ExtAI[K] != NULL)
		{
			ExtAI[K]->States->Release();
			ExtAI[K]->Actions->Release(); // Release TExtAI via actions (it will start the release chain -> command to release also TExtAI)
			//ExtAI[K]->Release(); // This is not required (memory is already empty)
			ExtAI[K] = NULL;
		}
	}
}


HRESULT ADDCALL NewExtAI(pIEvents *aEvents)
{
	ExtAI[ExtAICnt] = new TExtAI();
    *aEvents = ExtAI[ExtAICnt];
    if (*aEvents)
    {
		ExtAICnt++;
        (*aEvents)->AddRef();
        return S_OK;
    }
    else
    {
        return E_NOINTERFACE;
    }
}


void ADDCALL InitNewExtAI(ui8 aID, pIActions aActions, pIStates aStates)
{
	ExtAI[ExtAICnt-1]->ID = aID;
	ExtAI[ExtAICnt-1]->Actions = aActions;
	ExtAI[ExtAICnt-1]->Actions->AddRef(); // Mark reference
	ExtAI[ExtAICnt-1]->States = aStates;
	ExtAI[ExtAICnt-1]->States->AddRef(); // Mark reference
}


int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void* lpReserved)
{
    return 1;
}