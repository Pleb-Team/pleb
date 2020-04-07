#ifndef PLAYERAI_H
#define PLAYERAI_H

#include "../Global.h"
#include "../Game/GameState.h"
#include "../Game/MoveSimpleResults.h"
//#include "../Game/GameHistory.h"

// Einige hilfreiche Abkürzungen
#define MYPLAYER m_GameState.m_nActualPlayer
#define MYCARDS m_GameState.m_CardDistribution[ MYPLAYER ]
#define MYCARDNUMBERS m_GameState.m_CardNumberDistribution[ MYPLAYER ]


//------------------------------------------------------------------------------------------------
/// Verwaltet einen internen Spielstand, einige Statistiken, und die AI-Prozeduren
/// zum Spielen und zum KartenTauschen
//------------------------------------------------------------------------------------------------
class CPlayerAI 
{
protected:

	/// Das globale GameHistory-Objekt
//	CGameHistory* m_pGlobalGameHistory;

    /// Der LOKALE Zustand des Spiels, enthält insb. Kartenverteilung und LastMove
    /// Lokal erlaubt es, CPlayerAI::Think() auf jedem beliebigen Spielstand aufzurufen und somit als Library-Function zu nutzen
	CGameState m_GameState;

	/// Speichert die Güte jedes direkt möglichen Zug
	CMoveResults m_MoveResults;	

	/// Der Mittelwert aller gegnerischen Karten
	float m_fMittelwertGegnerKarten;    

    /// Will be filled by KI and displayed in order to faciliate debugging and improvements
    std::string m_sDebugMessages;


	//------------------------------------------------------------------------------------------------

	/// Diese Prozedur berechnet den mittelwert der gegnerischen Karten
	float CalculateMittelwertGegner(int PlayerID);

	/// Diese Prozedur berechnet den Mittelwert der eigenen Karten
	float CalculateMittelwert(int PlayerID);

	/// Diese Prozedur findet heraus, wieviele Karten der gegnerischen Player mit den wenigsten Karten hat
	int CalculateMinimaleAnzahlKartenGegner(int PlayerID);

	/// Diese Prozedur findet die hächste Karte heraus, die noch im Spiel ist
	int CalculateHoechsteKarteGegner(int PlayerID);

	/// Checkt, welches Tupel man am häufigsten hat, also zB Einzelne oder Päärchen
	int CalculateHaeufigstesTupel();

	/// berechnet, wieviele Karten man hat, deren Wert zwischen Min und Max (einschließlich) liegt
	int SumNumberCards(int Min, int Max);

	/// s.o., aber pro Farbe nur einmal zählen
	int SumValuePresent(int Min, int Max);

    /// Sucht die beste(n) Karte(n), das Ergebnis ist eindeutig, deshalb muss die Funktion nicht virtuell sein
    TMoveSimple SuchBesteKarte();

    /// Sucht die schlechteste(n) Karte(n), versucht dabei aber auch, einzelne zu drücken
	/// muß virtuell sein, weil die KI je nach Strategie nicht wirklich die beiden schlechtesten karten abgibt, 
	/// sondern zB zwei 7er behält und stattdessen eine einzelne 8 + 9 abgibt
	virtual TMoveSimple SuchSchlechtesteKarte();
	
	/// This is the CORE of the AI...
	/// wird von Think(GameState) aufgerufen.
	virtual TMoveSimple Think() = 0;// { return c_MoveSimpleSchieben; };

	/// Kartentauschen. 
	virtual TMoveSimple ThinkKartenTauschen();

	/// Sucht anhand m_MoveResults den besten möglichen Move
	TMoveSimple GetBestMoveFromMoveResults();

public:

	/// Gibt an, wieviele Karten der Player abgeben muß (zu Beginn des spiels). Wenn > 0, müssen so viele
	/// hohe Karten abgegeben werden - wenn < 0 müssen niedrige Karten abgegeben werden
    // \todo protected machen und als Prameter in ThinkKartenTauschen() einbauen
    int m_nKartenAbgeben;

    /// Show the last debug messages that were created during Thinking etc.
    virtual std::string GetDebugMessages() { return m_sDebugMessages; }


	//------------------------------------------------------------------------------------------------

	/// Konstruktor
//    CPlayerAI( CGameHistory* pGlobalGameHistory )
    CPlayerAI()
    {
		m_sDebugMessages = "";
//		m_pGlobalGameHistory = pGlobalGameHistory;
		m_fMittelwertGegnerKarten = -1;
		m_nKartenAbgeben = 0;
    }


	/// This is the CORE of the AI...
    TMoveSimple ThinkInGameState(const CGameState* pGameState)
	{ 
		m_GameState = *pGameState;

        // Play ALL cards of value 7 if in the beginning of the game; no need for virtual implementation of specific strategy, as
        // this is the only I can think of - but admitted, this "Strategy" should of course also be iplemented in the derived AI classes
		if (m_GameState.m_bMustStartWith7Diamond)
		{
			assert( MYCARDS[ CARD_7 ] && L"Spieler muß mit Karo7 beginnen, hat aber gar keine 7!");
			return TMoveSimple( MYCARDS[ CARD_7 ], CARD_7 );
		}
		return Think();	
    }


	/// Rahmenroutine zum Kartentauschen. PlayerID muß übergeben werden, weil der Kartentausch
	/// in beliebiger Reihenfolge sein kann
	TMoveSimple ThinkKartenTauschen(CGameState* pGameState, int nPlayerID) 
	{ 
		m_GameState = *pGameState;
		m_GameState.m_nActualPlayer = nPlayerID; // Vereinfacht allgemeine Berechnungen, zB Mittelwert...
		return ThinkKartenTauschen();
    }

	/// Virtuelle Prozedur, gibt ne Kurzbeschreibung des AI-Types wieder zum auswählen in der GUI
    virtual std::string GetDescription() = 0;
};





class CPlayerHuman : public CPlayerAI
{
protected:
	
    // This function should NEVER be called, as for Human players, "Thinking" is done by the humam :-)
    virtual TMoveSimple Think() { assert(0); return c_MoveSimpleSchieben; }

public:
    virtual std::string GetDescription() { return "Description for Human Player: Smart, intuitively, no deep search, drunk"; }
};





#endif // #ifndet PLAYERAI_H
