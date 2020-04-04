#ifndef GAMESTATISTICS_H
#define GAMESTATISTICS_H

#include "../GlobalConstants.h"

//--------------------------------------------------------------------------------------------------
/// Diese Klasse Zählt mit, wie oft ein bestimmter Player schon welchen Spielstand 
/// Präsi, ..., Arschloch) erreicht hat
//--------------------------------------------------------------------------------------------------
class CGameStatistics
{
private:
	int GameResults[NUMBER_RESULTS];
	int TotalNumberGames;


public:
	CGameStatistics(void);
	~CGameStatistics(void);

	/// Increment counter for Result and TotalNumberGames;
	void GameFinished(int Result);

	/// Get the total number of played games
	int GetTotalNumberGames() { return TotalNumberGames; }

	/// gibt an, wie oft man ein bestimmtes Ergebnis erzielt hat
	int GetNumberResults( int Result );

	/// In wieviel Prozent aller Spiele man z.B. Präsi war
	float GetPercentResults( int Result) 
	{ 
		if ( TotalNumberGames <= 0 ) 
		{
			return 0;
		} 
		else 
		{
			// okay, theese are no % but more exact
			return (float) 100 * GetNumberResults( Result ) / TotalNumberGames; 
		}
	}

	/// Wieviel % aller Spiele man Präsi oder Vizepräsi war
	float GetWinPercent() 
	{ 
		return (float) 100 * (GetNumberResults(3) + GetNumberResults(2)) / TotalNumberGames; 
	}

	/// Wieviele Punkte man insg schon erwirtschaftet hat, wenn Präsi = 2P, Arschloch = -2P
	int GetPoints() 
	{
		return	  3 * GameResults[RESULT_PRAESI]	+ 2 * GameResults[RESULT_VIZEPRAESI] 
				+ 1 * GameResults[RESULT_VIZENEGER] + 0 * GameResults[RESULT_NEGER];
	}

	/// Reset all counters
	void Reset();
};


#endif // GAMESTATISTICS_H
