#include "PlayerAI.h"

#include <algorithm>

//------------------------------------------------------------------------------------------------------------
/// Diese Prozedur berechnet den Mittelwert der gegnerischen Karten
/// Eingabe: Die eigene PlayerID
/// Ausgabe: Mittelwert
//------------------------------------------------------------------------------------------------------------
float CPlayerAI::CalculateMittelwertGegner(int PlayerID) {

	int Summe = 0;
	int Anzahl = 0;

	// Summe aller Kartenwerte (außer den eigenen) berechnen
	for (int i = 0; i < NUMBER_VALUE; i++) {
		Summe+= i * (m_GameState.m_CardDistributionTotal[i] - m_GameState.m_CardDistribution[PlayerID][i]);
		Anzahl+= m_GameState.m_CardDistributionTotal[i] - m_GameState.m_CardDistribution[PlayerID][i];
	}

	if (Anzahl == 0)
		return 0;
	else
		return (float) Summe / Anzahl;
}


//------------------------------------------------------------------------------------------------------------
// Diese Prozedur berechnet den Mittelwert der eigenen Karten
// Eingabe: Die eigene PlayerID
// Ausgabe: Mittelwert
//------------------------------------------------------------------------------------------------------------
float CPlayerAI::CalculateMittelwert(int PlayerID) {

	int Summe = 0;

	//Summe aller Kartenwerte (außer den eigenen) berechnen
	for (int i = 0; i < NUMBER_VALUE; i++)
		Summe+= i * m_GameState.m_CardDistribution[PlayerID][i];

	return (float) Summe / m_GameState.m_CardNumberDistribution[PlayerID];
}


//------------------------------------------------------------------------------------------------------------
/// Checkt, welches Tupel man am häufigsten hat, also zB Einzelne oder Päärchen
//------------------------------------------------------------------------------------------------------------
int CPlayerAI::CalculateHaeufigstesTupel()
{
	int nBestesTupel = 0; 
	int nAnzahlMeisterPaaerchen = 0;
	int nAnzahlPaare[NUMBER_COLOR+1] = {0,0,0,0,0 } ;

	for (int n = 0; n < NUMBER_VALUE; n++ )
	{
		nAnzahlPaare[ MYCARDS[n] ]++;
		if (	( MYCARDS[n] != 0)
			&&	( nAnzahlPaare[ MYCARDS[n] ] > nAnzahlMeisterPaaerchen ) 
			)
		{
			nBestesTupel = MYCARDS[n];
			nAnzahlMeisterPaaerchen = nAnzahlPaare[ nBestesTupel ];
		}
	}

	return nBestesTupel;
}


//------------------------------------------------------------------------------------------------------------
/// Diese Prozedur findet heraus, wieviele Karten der gegnerischen Player mit den wenigsten Karten hat
/// Dabei zählen nur Player, die noch im Spiel sind
/// \todo Hier sollte noch irgendwas vernünftiges herauskommen, wenn ALLE Player schon fertig sind!
///
/// Eingabe: Die eigene PlayerID
/// Ausgabe: Anzahl Karten des gegnerischen Players mit den wenigsten Karten
//------------------------------------------------------------------------------------------------------------
int CPlayerAI::CalculateMinimaleAnzahlKartenGegner(int PlayerID) {

	int Ergebnis = NUMBER_CARD;

	//Summe aller Kartenwerte (außer den eigenen) berechnen
	for (int i = 0; i < NUMBER_PLAYER; i++)
		if (( i != PlayerID) && (0 < m_GameState.m_CardNumberDistribution[i]) && (m_GameState.m_CardNumberDistribution[i] < Ergebnis))
			Ergebnis = m_GameState.m_CardNumberDistribution[i];

	return Ergebnis;
}


//------------------------------------------------------------------------------------------------------------
/// Diese Prozedur findet die höchste gegnerische Karte heraus, die noch im Spiel ist
/// Dabei zählen nur Player, die noch im Spiel sind
/// \todo Hier sollte noch irgendwas vernünftiges herauskommen, wenn ALLE Player schon fertig sind!
///
/// Eingabe: Die eigene PlayerID
/// Ausgabe: Anzahl Karten des gegnerischen Players mit den wenigsten Karten
//------------------------------------------------------------------------------------------------------------
int CPlayerAI::CalculateHoechsteKarteGegner(int PlayerID) {

	//Summe aller Kartenwerte (außer den eigenen) berechnen
	for (int i = NUMBER_VALUE-1; i >= 0; i--)
		if (m_GameState.m_CardDistributionTotal[i] - m_GameState.m_CardDistribution[PlayerID][i] > 0)
			return i;

	return 0;
}


//------------------------------------------------------------------------------------------------------------
/// berechnet, wieviele Karten man hat, deren Wert zwischen Min und Max (einschließlich) liegt
///
/// \todo ist genauso in CExample2 definiert - irgendwie zusammenlegen!
//------------------------------------------------------------------------------------------------------------
int CPlayerAI::SumNumberCards(int Min, int Max) {

	int n, Result = 0;

	for( n = Min; n <= Max; n++)
		Result+= MYCARDS[n];

	return Result;
}


//------------------------------------------------------------------------------------------------------------
/// wie oben: berechnet, wieviele Karten (pro Farbe EINFACH gezählt) man hat, deren Wert zwischen 
/// Min und Max (einschließlich) liegt
//------------------------------------------------------------------------------------------------------------
int CPlayerAI::SumValuePresent(int Min, int Max) {

	int n, Result = 0;

	for( n = Min; n <= Max; n++) 
		if (MYCARDS[n] )
            Result+= 1;

	return Result;
}


//---------------------------------------------------------------------------------------------------------------	
/// Veranlaßt den Player, Karten zu tauschen. 
/// Ausgabe: Die von der KI selektierte Karte zum Tauschen 
//---------------------------------------------------------------------------------------------------------------	
TMoveSimple CPlayerAI::ThinkKartenTauschen() 
{
	// Abhängig von der Situation die höchste / niedrigste Karte wählen
    if (MYCARDEXCHANGENUMBER > 0)
														return SuchBesteKarte();
    else if (MYCARDEXCHANGENUMBER < 0)
														return SuchSchlechtesteKarte();
	else
														return c_MoveSimpleSchieben;
}


//------------------------------------------------------------------------------------------------------------
/// Ausgabe: Schlechteste Karte
//------------------------------------------------------------------------------------------------------------
TMoveSimple CPlayerAI::SuchSchlechtesteKarte() 
{
	int n, nMittelwert = (int) CalculateMittelwert( m_GameState.m_nActualPlayer );

	// Erstmal checken, ob man einen Wert blank drücken kann
	for (n = 0; n < nMittelwert-1; n++)

//        if ( MYCARDS[n] == -MYCARDEXCHANGENUMBER )			return TMoveSimple( 1, n );
        if ( MYCARDS[n] == 1 )			return TMoveSimple( 1, n );

    // Hier angekommen heißt: Alle niedrigen Karten sind wenn dann als mind. als Päärchen vorhanden!
    // Dann halt einfach die schlechteste Karte rausrücken
	for (n = 0; n < NUMBER_VALUE-1; n++)

		if ( MYCARDS[n] > 0 )							return TMoveSimple( 1, n );


	return c_MoveSimpleSchieben;
}
	

//------------------------------------------------------------------------------------------------------------
/// Ausgabe: Beste Karte
//------------------------------------------------------------------------------------------------------------
TMoveSimple CPlayerAI::SuchBesteKarte() 
{
	// Zu spielende Karten im Stapel suchen
	for (int n = NUMBER_VALUE-1; n >= 0; n--)

		if ( MYCARDS[n] )								return TMoveSimple( 1, n );

	return c_MoveSimpleSchieben;
}


//------------------------------------------------------------------------------------------------------------
/// Sucht anhand m_MoveResults den besten möglichen Move
//------------------------------------------------------------------------------------------------------------
TMoveSimple CPlayerAI::GetBestMoveFromMoveResults()
{
	TMoveSimple Move, BestMove = c_MoveSimpleSchieben;
	int nBest = m_MoveResults.GetResult( c_MoveSimpleSchieben );

	for (Move.NumberCards = 1; Move.NumberCards <= NUMBER_COLOR; Move.NumberCards++)
		for (Move.ValueCards = 0; Move.ValueCards < NUMBER_VALUE; Move.ValueCards++)

			// !!! >=, damit Spielen dem Schieben bevorzugt wird
			if ( m_MoveResults.GetResult( Move ) > nBest )
			{
				nBest = m_MoveResults.GetResult( Move );
				BestMove = Move;
			}

	assert( BestMove.IsEmpty() || MYCARDS[BestMove.ValueCards] >= m_GameState.m_LastMoveSimple.NumberCards );
	assert( m_GameState.IsMoveLegal( BestMove ) );

	return BestMove;
}

