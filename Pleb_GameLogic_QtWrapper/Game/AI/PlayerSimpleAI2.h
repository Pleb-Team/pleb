#pragma once

#include "PlayerAI.h"

//----------------------------------------------------------------------------------------------------------------
/// Klasse CPlayerSimpleAI2, eine nicht allzu doofe KI, die das Prinzip von CPlayerSimpleAI noch etwas verfeinert
//----------------------------------------------------------------------------------------------------------------
class CPlayerSimpleAI2 : public CPlayerAI
{
protected:

	/// Fängt an zu denken anhand des übermittelten Zustands
	TMoveSimple Think();

	/// Berechnet eine Heuristik für den aktuellen Zustand
	int DoHeuristic();

	/// Checkt,ob man beim spielen dieses Moves nicht mit total besch***** Karten hinterher dasitzt. 
	bool MoveIstEinigermassenVernuenftig( const TMoveSimple &Move );

public:

	/// Kurze Beschreibung, wofür weiß ich noch nicht
    std::string GetDescription() { return "SimpleAI2: Like SimpleAI, but is able to see whether it can finish within one move."; }
};
