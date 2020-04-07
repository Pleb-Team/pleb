#include "Game.h"


//--------------------------------------------------------------------------------------------------
/// Reset cards and mix them
//--------------------------------------------------------------------------------------------------
void CGame::ShuffleCards() 
{
	int n, m;
	CMove Karte;

	// Alle Karten liegen schön geordnet auf dem Stapel
	m_vecKarten.clear();
	for (n = 0; n < NUMBER_VALUE; n++) {
		for (m = COLOR_KARO; m <= COLOR_KREUZ; m <<= 1) 
		{
			Karte = CMove( n, m );
			m_vecKarten.push_back( Karte );
		}
	}

	// Karten mischen
	for (n = 0; n < NUMBER_CARD - 1; n++) 
	{
		// m ist gleichverteilt mit m <= n <= 31
		m = n + (rand() % (NUMBER_CARD - n) );

		// Karten n und m tauschen
		Karte = m_vecKarten[n]; m_vecKarten[n] = m_vecKarten[m]; m_vecKarten[m] = Karte;
	}

	//// Observer benachrichtigen, damit zB CKarte3D-Objekte angelegt werden können
	//if (m_pGuiObserver)
	//	m_pGuiObserver->Update( Jojo_EventKartenGemischt, this );
}


//--------------------------------------------------------------------------------------------------
/// Die oberste Karte vom Stapel ziehen
//--------------------------------------------------------------------------------------------------
CMove CGame::TakeOneCard( int PlayerID ) 
{
	CMove Ergebnis;
	
	// Check ob noch Karten da sind
	if (m_vecKarten.size() > 0) {

		// oberste Karte austeilen
		Ergebnis = m_vecKarten.back();
		m_vecKarten.pop_back();
	}

	return Ergebnis;
}



//--------------------------------------------------------------------------------------------------
/// Reset cards and mix them
//--------------------------------------------------------------------------------------------------
void CGameDebug::ShuffleCards()
{
	// Hier werden die Werte der Karten definiert, die die Player am Anfang bekommen. Farben werden nicht 
	// angegeben. Für jeden Player maximal 8 Karten, Werte < 0 gelten als keine Karte
	const int CardsInBeginning[NUMBER_PLAYER][NUMBER_VALUE] = { 
            {0,   1,  1,  2,  3, -1, -1, -1},
            {1,   2,  3,  4, -1, -1, -1, -1},
			{-1, -1, -1, -1, -1, -1, -1, -1},
			{-1, -1, -1, -1, -1, -1, -1, -1}
	};	

	int n, m;
	int Farbe = COLOR_KARO;
	CMove Karte;

	// Erstmal: Inherited-Call
	m_vecKarten.clear();
	
	// vordefinierte Karten in der Reihenfolge auf den Stapel legen. Farbe wechselt dabei immer
	// Jeder Spieler bekommt die ihm zuzuteilenden Karten, wenn reihum Spieler 0, 1, 2, 3 je eine Karte zieht
	for(m = 0; m < NUMBER_VALUE; m++) {
		for (n = NUMBER_PLAYER - 1; n >= 0; n--) {

			Karte = CMove( CardsInBeginning[n][m], Farbe );
			m_vecKarten.push_back( Karte );
		}

        // Farben einfach abwechseln
		Farbe <<= 1;
        if (Farbe > COLOR_KREUZ) {
            Farbe = COLOR_KARO;
        }
	}
}




CMove CGameTwoPlayer::TakeOneCard( int PlayerID ) {

	CMove Ergebnis;

	// Nur die ersten 2 Player bekommen Karten
	if (PlayerID < 2)
		Ergebnis = CGame::TakeOneCard( PlayerID );

	// Absichern, daß nur die ersten 10 Karten ausgeteilt werden
	if ( m_vecKarten.size() <= NUMBER_CARD - (2 * 5) )
		m_vecKarten.clear();

	return Ergebnis;
}

