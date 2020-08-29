#ifndef GAMESTATE_H
#define GAMESTATE_H

#include <assert.h>
#include <string>
#include <cstring> // for memset

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

    /// Who has to give cards to whom at the beginning of each game
    int m_nCardExchangePartner[NUMBER_PLAYER];

    /// How many best (positive numbers) or arbitrary (negative numbers) cards every player has to give
    /// to his exchange partner
    int m_nCardExchangeNumber[NUMBER_PLAYER];


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

    /// Resets Lastmove, LastPlayer, NumberPlayer, ActualPLayer all to initial invalid (-1)
    /// and clears all cards, i.e. all players have empty hands
    inline void Reset();

	/// Adds the cards to m_CardDistribution, m_CardNumberDistribution and m_CardDistributionTotal
	inline void PlayerBekommtKarten( const TMoveSimple & Move, int nPlayerID );

	/// updatet CardDistribution, CardNumberDistribution und m_CardDistributionTotal
	inline int PlayerVerliertKarten( const TMoveSimple & Move, int nPlayerID, bool bCheck = true );

	/// Puts cards on the stack if Move is legal (According to State->LastMove->IsLegal)
	/// and calls NaechsterSpieler()
	inline int PlayCards( const TMoveSimple & MoveSimple, bool bSofortNeuNurBeiAs, bool bCheck = false);

    /// As the name says, this function is called during the first phase of ard exchange.
    /// Note that it is called once for every single card exchanged.
    inline int GiveCardToExchangePartner(int nPlayerIDGive, int nPlayerIDReceive, int nValueCards);

    /// Startet neues Spiel: bestimmt den Anfangsspieler und wer mit wem tauschen muss
    inline void SpielBeginnen();

	/// Es wird bestimmt, welcher Spieler als nächstes dran ist (s. Eingabe), 
    /// wenn man neu herauskommen darf, wird auch m_LastMoveSimple gelöscht !
	inline void NaechsterSpieler( bool bSofortNeuNurBeiAs );

	/// \todo saulahmer <-operator, aber dient ja erstmal nur testzwecken um zu schaun, ob bei
	/// Backtracking Zustände mehrmals vorkommen
    inline bool operator < (const CGameState & other) const;
	
	/// Wahr, wenn der Move nach Precedent gespielt werden darf
	inline int IsMoveLegal( const TMoveSimple & MoveSimple ) const;

	/// \return true if some opponent != Player is able to play higher than Move
    inline bool HigherCardsInGame( int Player, const TMoveSimple & Move);

	/// \return Total number of players who are still holding cards
    inline int GetNumberPlayers() const { return m_nNumberPlayers; }

    /// \todo Nur für Testzwecke, m_nNumberPlayers sollte ausschließlich über PlayCards() manipuliert werden
    inline void SetNumberPlayers(int n) { m_nNumberPlayers = n; }

    /// Returns a textual description of the game state for debugging
    inline std::string GetDescription();
};



//---------------------------------------------------------------------------------------------------
/// Returns a textual description of the game state for debugging
//---------------------------------------------------------------------------------------------------
inline std::string CGameState::GetDescription()
{
    std::string s;

    for (int nPlayerID = 0; nPlayerID < NUMBER_PLAYER; nPlayerID++)
    {
        if (nPlayerID == m_nActualPlayer)
            s = s + "--> Player " + inttostr(nPlayerID) + ": ";
        else
            s = s + "    Player " + inttostr(nPlayerID) + ": ";

        for (int v = 0; v < NUMBER_VALUE; v++)
            if (m_CardDistribution[nPlayerID][v] > 0)
                s = s + TMoveSimple(m_CardDistribution[nPlayerID][v], v).GetText();

        s = s + "\n";
    }

    s = s + "\n";
    s = s + "Actual player: " + inttostr(m_nActualPlayer) + "\n";
    s = s + "Last player: " + inttostr(m_nLastPlayer) + ", LastMove: " + m_LastMoveSimple.GetText() + "\n";

    return s;
}



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
            g_pKonfig->Log("[CGameState::PlayCards] IsMoveLegal() returned false for move: " + MoveSimple.GetText());
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


inline int CGameState::GiveCardToExchangePartner(int nPlayerIDGive, int nPlayerIDReceive, int nValueCards)
{
    TMoveSimple MoveSimple(1, nValueCards);

    assert(m_nCardExchangePartner[nPlayerIDGive] == nPlayerIDReceive);
    assert(m_nCardExchangeNumber[nPlayerIDGive] != 0);

    // Gamestate updaten
    if (PlayerVerliertKarten( MoveSimple, nPlayerIDGive ) == JOJO_ERROR)
        return JOJO_ERROR;

    PlayerBekommtKarten( MoveSimple, nPlayerIDReceive );

    // Den Counter, wieviele Karten abgegeben werden muessen, updaten
    if (m_nCardExchangeNumber[nPlayerIDGive] > 0)
        m_nCardExchangeNumber[nPlayerIDGive]--;
    else if (m_nCardExchangeNumber[nPlayerIDGive] < 0)
        m_nCardExchangeNumber[nPlayerIDGive]++;


    // SpielerZumTauschen resetten, wenn fertig getauscht
    if (m_nCardExchangeNumber[nPlayerIDGive] == 0)
        m_nCardExchangePartner[nPlayerIDGive] = -1;

    // Check if some card echange is still left
    bool bCardExchangeStillOngoing = false;
    for (int n = 0; n < NUMBER_PLAYER; n++)
        if ( m_nCardExchangeNumber[n] != 0 )
            bCardExchangeStillOngoing = true;

    if (!bCardExchangeStillOngoing)
        m_nZustand = Jojo_SpielZustandSpielen;

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
/// Es wird festgelegt, welcher Spieler ganz am Anfang beginnt (der mit der Karo7) und welcher
/// Spieler mit wem wie viele Karten tauschen soll nach einem Spiel
///
/// Zustand => Jojo_SpielZustandKartenTauschen oder
///	        => Jojo_SpielZustandSpielen
///
/// Moved here from CGameControlView keeping original function name and comments
//---------------------------------------------------------------------------------------------------
inline void CGameState::SpielBeginnen()
{
    int n;
    int Neger = -1, VizeNeger = -1, Master = -1, VizeMaster = -1;

    // In dieser Schleife checken, ob bereits ein Spiel war, und wer auf welchem Platz sitzt
    for (n = 0; n < NUMBER_PLAYER; n++)
        switch ( (int) m_GameResult.Value[n] )
        {
            case RESULT_NEGER:		Neger = n;		break;
            case RESULT_VIZENEGER:	VizeNeger = n;	break;
            case RESULT_VIZEPRAESI: VizeMaster = n; break;
            case RESULT_PRAESI:		Master = n;		break;
        }


    // Nach einem Spiel jedem Spieler mitteilen, mit wem er Karten tauschen soll
    if ( (Neger >= 0) && (VizeNeger >= 0) && (VizeMaster >= 0) && (Master >= 0) )
    {
        m_nActualPlayer = Neger;
        m_nZustand = Jojo_SpielZustandKartenTauschen;

        /// Who has to give cards to whom at the beginning of each game
        m_nCardExchangePartner[Neger] = Master;
        m_nCardExchangePartner[VizeNeger] = VizeMaster;
        m_nCardExchangePartner[VizeMaster] = VizeNeger;
        m_nCardExchangePartner[Master] = Neger;

        /// How many best (positive numbers) or arbitrary (negative numbers) cards every player has to give
        /// to his exchange partner
        m_nCardExchangeNumber[Neger] = +2;
        m_nCardExchangeNumber[VizeNeger] = +1;
        m_nCardExchangeNumber[VizeMaster] = -1;
        m_nCardExchangeNumber[Master] = -2;
    }
    else
    {
//        // Ansonsten faengt der Player mit der Karo 7 an
//        for (n = 0; n < NUMBER_PLAYER; n++)
//        {
//            for (m = 0; m < m_pPlayerViews[n]->GetNumberCards3D(); m++)
//                if ( m_pPlayerViews[n]->GetCard3D(m)->GetMove() == CMove(CARD_7, COLOR_KARO) )
//                {
//                    GetGameState()->m_bMustStartWith7Diamond = true;
//                    GetGameState()->m_nActualPlayer = n;
//                    break;
//                }
//        }

        // Sonst faengt halt der erste Spieler an (passiert egtl nur im Debug-Spiel, wenn es evtl keine Karo7 gibt)
//        if (m_nActualPlayer < 0)
            m_nActualPlayer = 0;

        // Jetzt noch den Zustand setzen
        m_nZustand = Jojo_SpielZustandSpielen;
    }
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
	m_nActualPlayer = -1; 
	m_nZustand = Jojo_Zustand_Nix;	

//	m_GameResult.Reset();

	// das mitgezählte Blatt aller anderen Spieler auf 0 setzen
    std::memset(m_CardDistributionTotal, 0, sizeof(m_CardDistributionTotal));
    std::memset(m_CardNumberDistribution, 0, sizeof(m_CardNumberDistribution));
    std::memset(m_CardDistribution, 0, sizeof(m_CardDistribution));

    std::memset(m_nCardExchangeNumber, 0, sizeof(m_nCardExchangeNumber));
    std::memset(m_nCardExchangePartner, -1, sizeof(m_nCardExchangePartner));
};



#endif 

