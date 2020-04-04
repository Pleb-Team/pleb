#ifndef GAMESTATE_H
#define GAMESTATE_H

#include <assert.h>
#include <cstring>

#include "../Global.h"
#include "../Konfiguration.h"

#include "GameResult.h"
#include "MoveSimple.h"


/// Stores the number of cards present of each value
typedef int TCards[NUMBER_VALUE];


//--------------------------------------------------------------------------------------------------
/// Stores the state of a game: Last Move (including last player !!!), Number of Players, Actual player 
/// and some functions to manipulate state
//--------------------------------------------------------------------------------------------------
class CGameState 
{
private:

	/// Wieviele Spieler überhaupt noch mitspielen
	int m_nNumberPlayers;

public:

	/// Muß man mit der Karo7 herauskommen?
	bool m_bMustStartWith7Diamond;

	/// Der zuletzt gespielte Move, der auf dem Tisch liegt. Also der letzte Move, bei dem nicht geschoben wurde
	/// bzw. ein Schieben-Move zu Beginn des Spieles und nachdem eine Runde lang geschoben wurde
	TMoveSimple m_LastMoveSimple;

	/// Wieviele Punkte jeder Player (schon) hat
	TGameResult m_GameResult;

	/// Der Zustand des Spiels
	Jojo_Zustand m_nZustand;

	/// Die Karten ALLER Mitspieler, wird für die KI benötigt
	TCards m_CardDistribution[NUMBER_PLAYER];

	/// Gibt zu jedem Wert an, an wieviele Karten insgesamt noch im Spiel sind
	TCards m_CardDistributionTotal;

	/// Wieviele Karten jeder einzelne Mitspieler hat
	int m_CardNumberDistribution[NUMBER_PLAYER];

	/// Wer zuletzt irgendwelche Karten abgelegt hat
	int m_nLastPlayer;

	/// Wer grad dran ist
	int m_nActualPlayer;

	/// Konstruktor
    CGameState() { Reset(); }

	/// Resets Lastmove, LastPlayer, NumberPlayer and cards of all players to initial state
	inline void Reset() ;	

	/// Adds the cards to m_CardDistribution, m_CardNumberDistribution and m_CardDistributionTotal
	inline void PlayerBekommtKarten( const TMoveSimple & Move, int nPlayerID );

	/// updatet CardDistribution, CardNumberDistribution und m_CardDistributionTotal
	inline int PlayerVerliertKarten( const TMoveSimple & Move, int nPlayerID, bool bCheck = true );

	/// Puts cards on the stack if Move is legal (According to State->LastMove->IsLegal)
	/// and calls NaechsterSpieler()
	inline int PlayCards( const TMoveSimple & MoveSimple, bool bSofortNeuNurBeiAs, bool bCheck = false);

	/// Es wird bestimmt, welcher Spieler als nächstes dran ist (s. Eingabe), 
    /// wenn man neu herauskommen darf, wird auch m_LastMoveSimple gelöscht !
	inline void NaechsterSpieler( bool bSofortNeuNurBeiAs );

	/// \todo saulahmer <-operator, aber dient ja erstmal nur testzwecken um zu schaun, ob bei
	/// Backtracking Zustände mehrmals vorkommen
    inline bool operator < (const CGameState & other) const;
	
	/// Wahr, wenn der Move nach Precedent gespielt werden darf
	inline int IsMoveLegal( const TMoveSimple & MoveSimple ) const;

	/// \return true if some opponent != Player is able to play higher than Move
	inline bool HigherCardsInGame( int Player, const TMoveSimple & Move) ;

	/// \return Total number of players who are still holding cards
    inline int GetNumberPlayers() const { return m_nNumberPlayers; }
};






//---------------------------------------------------------------------------------------------------
/// updatet CardDistribution, CardNumberDistribution und m_CardDistributionTotal
//---------------------------------------------------------------------------------------------------
inline void CGameState::PlayerBekommtKarten( const TMoveSimple & Move, int nPlayerID )
{
	assert( Move.ValueCards >= 0 && "[CGameState::PlayerBekommtKarten] Erh, Player bekommt gerade ungültige Karten");

	m_CardDistribution[ nPlayerID ][Move.ValueCards]+= Move.NumberCards;
	m_CardDistributionTotal[ Move.ValueCards ]+= Move.NumberCards;
	m_CardNumberDistribution[ nPlayerID ]+= Move.NumberCards;
}


//---------------------------------------------------------------------------------------------------
/// updatet CardDistribution, CardNumberDistribution und m_CardDistributionTotal
/// \param bCheck wen im Debug-Modus, wird eine Ausnahme ausgelöst, wenn der Player diese Karten nicht hatte.
/// Normally, we assume this never happens in order to speed up Alpha-Beta Backtracking
//---------------------------------------------------------------------------------------------------
inline int CGameState::PlayerVerliertKarten( const TMoveSimple & Move, int nPlayerID, bool bCheck /*= true*/ )
{
	if (bCheck)
	{
		std::string s;

		if (m_CardDistribution[ nPlayerID ][Move.ValueCards] < Move.NumberCards)
		{
			s = "[CGameState::PlayerVerliertKarten] Erh, Player verliert gerade Karten, die er gar nicht hat";
			g_pKonfig->Log(s);
			return JOJO_ERROR;
		}

		if (Move.ValueCards < 0)
		{
			g_pKonfig->Log("[CGameState::PlayerVerliertKarten] Value < 0");
			return JOJO_ERROR;
		}
	}
	
    assert(Move.ValueCards >= 0);
    assert(Move.NumberCards <= m_CardDistribution[ nPlayerID ][Move.ValueCards]);

	m_CardDistribution[ nPlayerID ][Move.ValueCards]-= Move.NumberCards;
	m_CardDistributionTotal[ Move.ValueCards ]-= Move.NumberCards;
	m_CardNumberDistribution[ nPlayerID ]-= Move.NumberCards;

	return JOJO_OK;
}


//---------------------------------------------------------------------------------------------------
/// Puts cards on the stack if Move is legal (According to State->LastMove->IsLegal)
/// and calls NaechsterSpieler()
///
/// \param bSofortNeuNurBeiAs see NaechsterSpieler()
//---------------------------------------------------------------------------------------------------
inline int CGameState::PlayCards( const TMoveSimple & MoveSimple, bool bSofortNeuNurBeiAs, bool bCheck/* = false*/)
{
	if (bCheck)
	{
		if (!IsMoveLegal(MoveSimple))
		{
            g_pKonfig->Log("[CGameState::PlayCards]: IsMoveLegal returned false");
			return JOJO_ERROR;
		}
	}

    // Assert stellt sicher, dass nach einer Runde schieben die karten gelöscht wurden
	assert( m_nLastPlayer != m_nActualPlayer || m_LastMoveSimple.IsEmpty() );

    // Letzten nicht-leeren Move speichern. Wichtig: In NächsterSpieler() wird gecheckt, ob der
    // Spieler neu herauskommen draf, und dann m_LastMoveSimple geleert
    if ( !MoveSimple.IsEmpty()  )
	{
        if (PlayerVerliertKarten( MoveSimple, m_nActualPlayer, bCheck )== JOJO_ERROR)
            return JOJO_ERROR;

		m_LastMoveSimple = MoveSimple;
		m_nLastPlayer = m_nActualPlayer;
	}

	// Wenn Player grad seine letzten Karten gespielt hat, seinen Spielausgang festhalten
	if ( m_CardNumberDistribution[m_nActualPlayer] == 0 )
	{
		assert( m_GameResult.Value[m_nActualPlayer] == RESULT_UNDEFINED );

		m_GameResult.Value[m_nActualPlayer] = (float) m_nNumberPlayers-1;
		m_nNumberPlayers--;
	}

	// Wenn nur noch ein Spieler übrig ist, ist das Spiel auch für diesen aus
	// => Jojo_SpielZustandSpielZuEnde
	if ( m_nNumberPlayers <= 1)
	{
		for (int n = 0; n < NUMBER_PLAYER; n++)
			if (m_GameResult.Value[n] == RESULT_UNDEFINED )
                m_GameResult.Value[n] = RESULT_NEGER;

		m_nZustand = Jojo_SpielZustandSpielZuEnde;
	}
	else
		// Nächsten Spieler bestimmen
		NaechsterSpieler( bSofortNeuNurBeiAs );

	return JOJO_OK;
}


//---------------------------------------------------------------------------------------------------
/// Hierdrin werden die Spielregeln "verkörpert": Nach jedem Spielzug wird
/// diese Routine aufgerufen. Es wird bestimmt, welcher Spieler als nächstes dran ist (s. Eingabe)
/// Wenn man neu herauskommen dart, wird auch m_LastMoveSimple gelöscht !
///
/// \param  bSofortNeuNurBeiAs					Wenn man ein As spielt, darf man nochmal. 
///				Wenn dieses Flag false ist, darf man nochmal, falls klar ist, daß kein anderer
///				Mitspieler überbieten kann. Dies ist sinnvoll als SpeedUp für den Alphabeta-Player, im richtigen
///				Spiel ist dies jedoch Cheaten, da man den anderen Spielern in die Karten guckt
//---------------------------------------------------------------------------------------------------
inline void CGameState::NaechsterSpieler( bool bSofortNeuNurBeiAs )
{
	// Erstmal dafür sorgen, daß neu ausgespielt wird, wenn man grad gespielt hat (also nicht geschoben) und 
	// keine höheren Karten mehr bei den Gegnern vorhanden...
	if (	m_nActualPlayer == m_nLastPlayer &&
		(		(bSofortNeuNurBeiAs && m_LastMoveSimple.ValueCards == CARD_As)
			||	(!bSofortNeuNurBeiAs && !HigherCardsInGame(m_nActualPlayer, m_LastMoveSimple) )
		)	)
	{
		m_LastMoveSimple = c_MoveSimpleSchieben;
		m_nLastPlayer = -1;
	}

	// ... ansonsten ist der nächste dran 
	else
	{
		m_nActualPlayer++; 
		if (m_nActualPlayer >= NUMBER_PLAYER) 
			m_nActualPlayer = 0;

        // Falls eine Runde lang nur geschoben wurde, darf der nächste neu rauskommen
		if (m_nActualPlayer == m_nLastPlayer) 
		{
			m_LastMoveSimple = c_MoveSimpleSchieben;
			m_nLastPlayer = -1;
		}	
	}

	// Nächsten Spieler mit Karten suchen
    // Anzahl der Schleifendurchläufe beschränken, um Endlosschleifen zu vermeiden, falls niemand mehr Karten haben sollte
	int n = 0;
	while ( m_CardNumberDistribution[m_nActualPlayer] == 0 && n < NUMBER_PLAYER )
	{
		m_nActualPlayer++; 
		if (m_nActualPlayer >= NUMBER_PLAYER) 
			m_nActualPlayer = 0;

		// Karten umdrehen, wenn eine Runde lang geschoben wurde
		if ( m_nActualPlayer == m_nLastPlayer/* && !m_LastMoveSimple.IsEmpty()*/ )	
		{
			m_LastMoveSimple = c_MoveSimpleSchieben;
			m_nLastPlayer = -1;
		}
		n++;
    }

	// Keiner hat mehr Karten - sollte egtl in PlayCards abgefangen werden
	assert (n != NUMBER_PLAYER && L"[CGAmeState::NaechsterSpieler] Fehler: Endlosschleife");
	if (n == NUMBER_PLAYER)
		m_nZustand = Jojo_SpielZustandSpielZuEnde;
}



//---------------------------------------------------------------------------------------------------
/// \todo saulahmer < operator, aber dient ja erstmal nur testzwecken
//---------------------------------------------------------------------------------------------------
bool CGameState::operator < (const CGameState & other) const
{
	if ( m_nActualPlayer != other.m_nActualPlayer )
		return m_nActualPlayer < other.m_nActualPlayer;

	if (m_nLastPlayer != other.m_nLastPlayer)
		return m_nLastPlayer < other.m_nLastPlayer;

	if (m_LastMoveSimple.NumberCards != other.m_LastMoveSimple.NumberCards)
		return m_LastMoveSimple.NumberCards < other.m_LastMoveSimple.NumberCards;

	if (m_LastMoveSimple.ValueCards != other.m_LastMoveSimple.ValueCards)
		return m_LastMoveSimple.ValueCards < other.m_LastMoveSimple.ValueCards;

	if (m_nNumberPlayers != other.m_nNumberPlayers)
		return m_nNumberPlayers < other.m_nNumberPlayers;


	for (int n = 0; n < NUMBER_PLAYER; n++)
		for (int v = 0; v < NUMBER_VALUE; v++)
			if (m_CardDistribution[n][v] != other.m_CardDistribution[n][v])
				return m_CardDistribution[n][v] < other.m_CardDistribution[n][v];


	return false;
}


//---------------------------------------------------------------------------------------------------
/// Wahr, wenn der Move nach Precedent gespielt werden darf
//---------------------------------------------------------------------------------------------------
inline int CGameState::IsMoveLegal( const TMoveSimple & MoveSimple ) const
{ 
	return 
		MoveSimple.IsEmpty() || m_LastMoveSimple.IsEmpty() || m_nLastPlayer == m_nActualPlayer || 
		(	MoveSimple.NumberCards == m_LastMoveSimple.NumberCards && 
			MoveSimple.ValueCards > m_LastMoveSimple.ValueCards
		); 
}


//---------------------------------------------------------------------------------------------------
/// \return true if some opponent != Player is able to play higher than Move.
/// Warning: This function can be used for cheating
//---------------------------------------------------------------------------------------------------
inline bool CGameState::HigherCardsInGame( int Player, const TMoveSimple & Move) 
{
	for( int n = NUMBER_VALUE-1; n > Move.ValueCards; n-- )
		if ( (m_CardDistributionTotal[n] - m_CardDistribution[Player][n]) >= Move.NumberCards)
			return true;

	return false;
}


///-------------------------------------------------------------------------------------------
/// Resettet alles auf sinnvolle Standards
///---------------------------------------------------------------------------------------------
void CGameState::Reset() 
{ 	
	m_nLastPlayer = -1; 
	m_LastMoveSimple = c_MoveSimpleSchieben; 
	m_bMustStartWith7Diamond = false;

	m_nNumberPlayers = NUMBER_PLAYER; 

	// Der Einfachheit halber auf 0 setzen, dann kann das Kartenverteilen direkt loslegen
	m_nActualPlayer = -1; 
	m_nZustand = Jojo_Zustand_Nix;	
	m_GameResult.Reset();

	// das mitgezählte Blatt aller anderen Spieler auf 0 setzen
    std::memset(m_CardDistributionTotal, 0, sizeof(m_CardDistributionTotal));
    std::memset(m_CardNumberDistribution, 0, sizeof(m_CardNumberDistribution));
    std::memset(m_CardDistribution, 0, sizeof(m_CardDistribution));
};



#endif 
