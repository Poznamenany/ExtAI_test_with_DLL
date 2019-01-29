#include <stdio.h>
#include <string>
#include <sstream>
#include "DLL_Library.h"

class TExtAI: public IEvents
{
	private:
		// IEvents
		void ADDCALL OnMissionStart(); 
		void ADDCALL OnTick(ui32 aTick); 
		void ADDCALL OnPlayerDefeated(si8 aPlayer); 
		void ADDCALL OnPlayerVictory(si8 aPlayer); 
		// Log
		void Log(wStr const* aLog);
	protected:
		ULONG m_cRef;
	public:
		ui8 ID;
		pIActions Actions;
		pIStates States;
		// Constructor / Destructor
		TExtAI(void);
		~TExtAI(void);
		// IUnknown
		ULONG ADDCALL AddRef(void);
		ULONG ADDCALL Release(void);
		HRESULT ADDCALL QueryInterface(REFIID riid,void **ppv);
};

typedef TExtAI * pTExtAI;


TExtAI::TExtAI(void)
{
	ID = 0;
	m_cRef = 0;
	Actions = NULL;
	States = NULL;
}

TExtAI::~TExtAI(void)
{
	//...
}


// IEvents
void TExtAI::OnMissionStart()
{
	std::wstringstream wss;
	wss << L"    TExtAI-OnMissionStart: ID = " << std::to_wstring(ID);
	std::wstring txt = wss.str();
	Log(txt.c_str());
}

void TExtAI::OnTick(ui32 aTick)
{
	//Log(L"    TExtAI-OnTick");
}

void TExtAI::OnPlayerDefeated(si8 aPlayer)
{
	Log(L"    TExtAI-OnPlayerDefeated");
}

void TExtAI::OnPlayerVictory(si8 aPlayer)
{
	Log(L"    TExtAI-OnPlayerDefeated");
}

// Log
void TExtAI::Log(wStr const* aLog)
{
	Actions->LogDLL(aLog, wcslen(aLog));
}


// Methods of IUnknown
ULONG TExtAI::AddRef()
{
	ULONG Cnt = InterlockedIncrement(&m_cRef);
	return Cnt;
}

ULONG TExtAI::Release()
{
	ULONG result = InterlockedDecrement(&m_cRef);
	if (!result)
		delete this;
	return result;
}

HRESULT TExtAI::QueryInterface(REFIID riid, void **ppvObject)
{
	HRESULT rc = S_OK;
	*ppvObject = NULL;

	//  Multiple inheritance requires an explicit cast
	if (riid == IID_IEvents)
		*ppvObject = (IEvents*)this; 
	else
		rc = E_NOINTERFACE;    

	//Return a pointer to the new interface and thus call AddRef() for the new index
	if (rc == S_OK)
		this->AddRef(); 
	return rc;
}