#ifndef GAME_H
#define GAME_H

#include "../Global.h"

#include "Move.h"
// #include "CardOwner.h"

//--------------------------------------------------------------------------------------------------
/// Klasse CGame speichert einen Kartenstapel zum Mischen und Aufteilen von Karten.
//--------------------------------------------------------------------------------------------------
class CGame
{
protected:
	std::vector <CMove> m_vecKarten;


public:

	/// Konstruktor
	/// Different types of card mixing-strategies
	enum Jojo_GameType
	{
		JGT_Normal,
		JGT_Debug,
		JGT_TwoPlayers
	};

	/// Reset cards and mix them
	virtual void ShuffleCards();

	/// Read the type of the game
    virtual Jojo_GameType GetType() { return JGT_Normal; }

	/// Nur Player 0 und 1 bekommen Karten
	virtual CMove TakeOneCard( int PlayerID );

	// Get a small description shown in the Player/Game-select dialog
    virtual std::string GetDescription() { return "Standard-Game: Cards are mixed fairly, start player changes clockwise"; }

	/// Access cards
    CMove GetCard( int Index) { return m_vecKarten[Index]; }
    int GetNumberCards() { return (int) m_vecKarten.size(); }

};



//--------------------------------------------------------------------------------------------------
/// Debug-Game: Die Kartenverteilung steht vorher fest (steht im Quellcode unter Reset()  )
//--------------------------------------------------------------------------------------------------
class CGameDebug: public CGame
{
public:

	/// Reset cards and mix them
	virtual void ShuffleCards();

	/// Read the type of the game
    virtual Jojo_GameType GetType() { return JGT_Debug; }

	/// Get a small description shown in the Player/Game-select dialog
    virtual std::string GetDescription() { return "Debug-Game: Cards for each player are predefined in c++-source"; }
};


//--------------------------------------------------------------------------------------------------
/// 2-Player-Spiel: Bei TakeOneCard bekommen nur die ersten beiden Player Karten
//--------------------------------------------------------------------------------------------------
class CGameTwoPlayer: public CGame
{
public:

	/// Nur Player 0 und 1 bekommen Karten
	virtual CMove TakeOneCard( int PlayerID );

	/// Read the type of the game
    virtual Jojo_GameType GetType() { return JGT_TwoPlayers; }

	/// Get a small description shown in the Player/Game-select dialog
    virtual std::string GetDescription() { return "2-Player-Game: Only Player 0 and Player 1 get cards"; }
};


#endif 

