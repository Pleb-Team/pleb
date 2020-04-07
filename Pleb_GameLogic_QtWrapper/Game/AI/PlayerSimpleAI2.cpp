#include "playersimpleai2.h"


//--------------------------------------------------------------------------------------------------------
/// Berechnet einen Wert, der die Güte des aktuellen Spielstandes wiedergibt: Je höher, desto besser
/// wird v.a. in MoveIstEinigermassenVernuenftig() verwendet
//--------------------------------------------------------------------------------------------------------
int CPlayerSimpleAI2::DoHeuristic() 
{
	if ( MYCARDNUMBERS == 0 )

		// Spieler, die schon fertig sind, bekommen entsprechend ihre Punkte, zur Sicherheit + 1000,
		// weil es immer besser ist, schon fertig zu sein, als noch 1000 Asse auf der Hand zu haben
		return 1000;

	else

		return SumValuePresent(CARD_BUBE, CARD_DAME) + SumNumberCards(CARD_KOENIG, CARD_As)
			-SumValuePresent(CARD_7, CARD_10);
}




//--------------------------------------------------------------------------------------------------------
/// Checkt,ob man beim Spielen dieses Moves nicht mit total besch***** Karten hinterher dasitzt. 
/// Der Move wird als vernünftig befunden, wenn
/// - man damit beendet bzw schon fertig ist
/// - oder die Heuristik (siehe DoHeuristic() ) DANACH > 0 ist
/// - oder die Heuristik sich um höchstens 1 verschlechtert
//--------------------------------------------------------------------------------------------------------
bool CPlayerSimpleAI2::MoveIstEinigermassenVernuenftig( const TMoveSimple &Move )
{
	int nWertVorher, nWertNachher;
	bool bGewonnen;

	// Move simulieren, Heuristiken vorher und nachher berechnen und Move wieder rückgängig machen
	nWertVorher = DoHeuristic();

	m_GameState.PlayerVerliertKarten(Move,m_GameState.m_nActualPlayer); 
	bGewonnen = MYCARDNUMBERS == 0;

	if ( !m_GameState.HigherCardsInGame( m_GameState.m_nActualPlayer, Move ) )
		nWertNachher = DoHeuristic() + 1; // weil man ja neu rauskommen darf
	else
		nWertNachher = DoHeuristic();
	
	m_GameState.PlayerBekommtKarten(Move,m_GameState.m_nActualPlayer); 

	return 
		( nWertNachher > 0 ) || 
		bGewonnen ||
		( nWertVorher - nWertNachher <= 2 );
}




//----------------------------------------------------------------------------------------------------------
/// Die Haupt-Denkroutine des einfachen KI-Spielers
/// Eingabe: Spielstand (wer dran ist, was liegt)
///			 Kartenverteilung (insb. das Blatt des Spielers an der Reihe)
///			 Statistische Variablen aus CPlayerAI
/// Ausgabe: Ergebnis des "Denkens", also was gespielt werden soll
//----------------------------------------------------------------------------------------------------------
TMoveSimple CPlayerSimpleAI2::Think() 
{
	//int n;//, m;
	int n, m;
	int nNumberBadValues, nBadValue;
	int nMittelWertGegner;

	// Init
	nMittelWertGegner = (int) CalculateMittelwertGegner( m_GameState.m_nActualPlayer );
	TMoveSimple Move = c_MoveSimpleSchieben;
	m_sDebugMessages = "";


	// Schaun ob man schon fertig ist: Entweder keine Karten mehr auf der Hand oder alle anderen Mitspieler
	// sind schon fertig
	if ( MYCARDNUMBERS == 0 ) 
	{
		// do nothing loop create 250Mb-Swapfile (Auszug aus dem Original Windows95 Quellcode)


	// -----------------------------------Man kann neu rauskommen----------------------------------------------

	} else if( m_GameState.m_LastMoveSimple.IsEmpty() ) 
	{
		// Von UNTEN anfangend guckt man, ob maximal ein Tupel von Karten überboten werden kann, DH
		// wenn man ne 7 hat und ansonsten nur Karten, über die keiner drüber gehen kann, hat man gewonnen
		// Die Anzahl der Werte, die übertroffen werden können, wird in der Variable NumerBadValues gespeichert
		nNumberBadValues = 0;
		nBadValue = -1;
		for( n = 0; (n < NUMBER_VALUE) && (nNumberBadValues < 2); n++) 
		{
			// Schaun, ob man von den Gegnern überboten werden kann, wenn man mit ALLEN Karten dieses Wertes 
			// herauskommt.
			if (MYCARDS[n] && m_GameState.HigherCardsInGame( MYPLAYER, TMoveSimple( MYCARDS[n], n) ) )
			{
				nBadValue = n;
				nNumberBadValues++;
			}
		}

		// Wenn maximal ein auf der Hand vorhandener Wert überboten werden kann, kann man von OBEN anfangen, alle
		// Karten abwerfen. Wenn NUR NOCH Karten mit dem Wert BadValue vorhanden sind, passiert in dieser
		// Schleife nix, dafür werden die Karten dann im nächsten Block abgeschmissen
		if (nNumberBadValues <= 1)
			for( n = NUMBER_VALUE-1; n >= 0; n-- )
				if ( MYCARDS[n] && n != nBadValue ) 
				{
												m_sDebugMessages = "I will finish";
												return TMoveSimple( MYCARDS[n], n );
				}


		// Wenn man nen niedrigen 3er oder 4er hat, damit rauskommen
		for( n = 0; n <= nMittelWertGegner; n++ )

			if( MYCARDS[n] >= 3 )				return TMoveSimple( MYCARDS[n], n );


		// Gilt nur für niedrige Karten: wenn man mehr Päärchen hat als einzelne, mit einem Päärchen 
		// rauskommen, ansonsten mit einem einzelnen
		int nBestesTupel = CalculateHaeufigstesTupel();
		for( n = 0; n <= nMittelWertGegner; n++ )

			if( MYCARDS[n] == nBestesTupel )	return TMoveSimple( MYCARDS[n], n );

		
		// Ansonsten mit der niedrigsten rauskommen
		for( n = 0; n < NUMBER_VALUE; n++ )

			if( MYCARDS[n] )					return TMoveSimple( MYCARDS[n], n );


	// -------------Es liegt mindestens eine Karte: Schaun ob man passend drüber gehen kann---------------------------

	} else {

		// Bombensichere Gewinnstrategie:
		//
		// Von oben anfangend guckt man, ob maximal ein Tupel von Karten überboten werden kann, DH
		// wenn man ne 7 hat und ansonsten nur Karten, über die keiner drüber gehen kann, hat man gewonnen
		// Die Anzahl der Werte, die übertroffen werden können, wird in der Variable NumerBadValues gespeichert
		for( n = NUMBER_VALUE-1; n > m_GameState.m_LastMoveSimple.ValueCards; n-- ) {

			// Checken, ob man überhaupt mit diesem Wert spielen kann
			if (MYCARDS[n] < m_GameState.m_LastMoveSimple.NumberCards)
				continue;

			// Der erste Zug darf schonmal nicht überboten werden können. Hier kommt direkt ein break, denn
			// im weiteren Verlauf der Schleife werden eh nur niedriger werdende Karten getestet, die dann ja
			// auch überboten werden können
			if (m_GameState.HigherCardsInGame( MYPLAYER, TMoveSimple(m_GameState.m_LastMoveSimple.NumberCards, n) ) )
				break;

			m_GameState.PlayerVerliertKarten( TMoveSimple(m_GameState.m_LastMoveSimple.NumberCards, n), MYPLAYER );
			{
				nNumberBadValues = 0;
				for( m = 0; m < NUMBER_VALUE && nNumberBadValues < 2; m++) 
				{
					// Schaun, ob man von den Gegnern überboten werden kann, wenn man mit ALLEN Karten dieses Wertes 
					// herauskommt.
					if ( MYCARDS[m] && m_GameState.HigherCardsInGame( MYPLAYER, TMoveSimple( MYCARDS[m], m) ) )
						nNumberBadValues++;
				}
			}
			m_GameState.PlayerBekommtKarten( TMoveSimple(m_GameState.m_LastMoveSimple.NumberCards, n), MYPLAYER );

			// Wenn maximal ein auf der Hand vorhandener Wert überboten werden kann, kann man von oben anfangen, alle
			// Karten abwerfen
			if (nNumberBadValues <= 1) {
				m_sDebugMessages = "I will win";
				return TMoveSimple( m_GameState.m_LastMoveSimple.NumberCards, n );
			}
		}

		// Karten sparen
		// 
		// Wenn von den anderen keiner drüber gehen kann, und der letzte Move von einem Player
		// unmittelbar VOR diesem Player gemacht wurde, der aufgehört hat, wird eine Runde lang geschoben, 
		// und DIESER Player darf neurauskommen. Er kann also Karten sparen :-)

		CGameState GameStateTest = m_GameState;

		// Simuliert schieben
		if (	GameStateTest.PlayCards( c_MoveSimpleSchieben, false ) == JOJO_OK
			&&	GameStateTest.m_nActualPlayer == MYPLAYER	)

												return c_MoveSimpleSchieben;


        // Es gibt keine triviale Gewinnstrategie - erstmal schaun, ob man PASSEND mit niedrigen Karten
		// rüberkommt, dh. keine Päärchen auseinanderreißen
		for( n = m_GameState.m_LastMoveSimple.ValueCards+1; n <= nMittelWertGegner + 1; n++ )

			if( MYCARDS[n] == m_GameState.m_LastMoveSimple.NumberCards )
									
												return TMoveSimple( m_GameState.m_LastMoveSimple.NumberCards, n );


		// wenn nicht, drübergehen wenn möglich bis zur 2.-höchsten Karte und dabei Sachen auseinanderreißen
		// wichtig: Hier lieber HÖHERE Päärchen auseinanderreißen als tiefere, d.h.
		// Pc: (9, 9, B, B) soll mit B über 8 gehen
		for( n = SuchBesteKarte().ValueCards - 2; n >= m_GameState.m_LastMoveSimple.ValueCards+1; n-- ) 
	//	int nHoechsteKarte = CalculateHoechsteKarteGegner( MYPLAYER );
	//	int m = max( m_GameState.m_LastMoveSimple.ValueCards+1, nMittelWertGegner );
	//	for( n = m; n <= nHoechsteKarte-2; n-- ) 

			if( MYCARDS[n] >= m_GameState.m_LastMoveSimple.NumberCards )

												return TMoveSimple(m_GameState.m_LastMoveSimple.NumberCards, n);


		// Hier angekommen bedeutet, daß man keine Buben oder niedriger hat mit denen man drüber gehen
		// KANN

		// Wenn nix billiges zum Abwerfen da war, werden hohe Karten gespielt. Das aber nur, wenn man nicht
		// mehr so viele billige Karten hat. Wichtig: hier nur zählen, ob der WERT vorhanden ist,
		// nicht wieviele Karten man davon hat. Man geht also davon aus, daß man die billigen Karten nur
		// durch abwerfen nach einem Ass auf einen Schlag loswird. Im Spiel billige Paare auseinanderreißen
		// bringt eh nichts

		for( n = m_GameState.m_LastMoveSimple.ValueCards+1; n < NUMBER_VALUE; n++ )
			if (MYCARDS[n] >= m_GameState.m_LastMoveSimple.NumberCards) 
			{
				Move.NumberCards = m_GameState.m_LastMoveSimple.NumberCards;
				Move.ValueCards = n;
				if (MoveIstEinigermassenVernuenftig(Move))
					return Move;
			}
	}

	// schieben
	return c_MoveSimpleSchieben;
}
