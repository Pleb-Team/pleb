#include <assert.h>

#include "GameStatistics.h"

CGameStatistics::CGameStatistics(void)
{
	Reset();
}

CGameStatistics::~CGameStatistics(void)
{
}

//--------------------------------------------------------------------------------------------------
// Reset all counters
//--------------------------------------------------------------------------------------------------
void CGameStatistics::Reset() 
{
	for (int n = 0; n < NUMBER_RESULTS; n++) 
	{
		GameResults[n] = 0;
	}

	TotalNumberGames = 0;
}

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
void CGameStatistics::GameFinished(int Result) {

	if ( (Result >= 0) && (Result < NUMBER_RESULTS) ) 
	{
		GameResults[Result]++;
		TotalNumberGames++;
	}
}


//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
int CGameStatistics::GetNumberResults( int Result )
{
	assert( Result >= 0 && Result < NUMBER_RESULTS );

	return GameResults[Result];
}
