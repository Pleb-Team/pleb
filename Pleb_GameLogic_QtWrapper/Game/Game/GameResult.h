#ifndef GAMERESULT_H
#define GAMERESULT_H

#include <assert.h>

#include "../GlobalConstants.h"


//----------------------------------------------------------------------------------------------------
/// Store the Result of the game for each player. If kind of average is calculated from more than 1 Result,
/// NumberResults is incremented in order to count the Number of accumulated Results and divide by this
/// value later
//----------------------------------------------------------------------------------------------------
struct TGameResult 
{
	float Value[NUMBER_PLAYER];
	int NumberResults;

	/// Checkt, ob jedes Spielergebnis, also {0,1,2,3} genau EINMAL im Vektor Value[] auftaucht
	bool IsResultFromCorrectlyFinishedGame() const
	{
		int i;
		int PointsCount[NUMBER_PLAYER] = {0,0,0,0};

		// Zählen, wie oft jedes Ergebnis kam
		for (i=0;i < NUMBER_PLAYER; i++) 
		{
			if ( ((int) Value[i] < 0) || ((int) Value[i] >= NUMBER_PLAYER) )
				return false;
			else
				PointsCount[ (int) Value[i] ]++;
		}

		// Check, ob jedes Ergebnis genau einmal kam
		for (i=0;i<NUMBER_PLAYER;i++)
			if (PointsCount[i] != 1)
				return false;

		return true;
	}

	
	/// Vernünftiges Init
	TGameResult() 
	{ 
		Reset(); 
	}


	/// Setzt alle Ergebnisse auf nicht initialisiert
	void Reset() 
	{ 
		for (int n=0;n<NUMBER_PLAYER;n++) 
			Value[n] = RESULT_UNDEFINED; 

		NumberResults = 0;
	}


	/// true, wenn dieses ergebnis für den angegebenen Player besser als ein anderes ist
	bool IsPreferable(const TGameResult & other, int nRefPlayerID)
	{
		assert(NumberResults > 0);
		//assert(NumberResults > 0);

		return other.NumberResults == 0 || Value[nRefPlayerID] * other.NumberResults > other.Value[nRefPlayerID] * NumberResults;
	}


	/// Normalisiert, indem alle Ergebnisse arithmetisch gemittelt werden
	void Normalize()
	{
		assert(NumberResults >= 1);

		if ( NumberResults == 0 )
			return;

		if ( NumberResults == 1)
			return;

		for (int n=0; n < NUMBER_PLAYER; n++)
			Value[n] /= NumberResults;

		NumberResults = 1;
	}


	/// Vergleicht. Beide Results sollten normalisiert sein, denn das wird nicht abgefangen!
	bool operator == (const TGameResult & other)
	{
		assert(NumberResults == other.NumberResults);
		assert(NumberResults == 1);

	//	if ( NumberResults != other.NumberResults )
	//		return false;

		for (int n=0; n < NUMBER_PLAYER; n++)
			if (Value[n] != other.Value[n])
				return false;

		return true;
	}
};


#endif
