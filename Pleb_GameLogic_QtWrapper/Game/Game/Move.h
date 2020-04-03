#ifndef MOVE_H
#define MOVE_H

#include "../Global.h"
#include "MoveSimple.h"




//----------------------------------------------------------------------------------------------------
/// Zählt Karten aus einer Menge mit demselben Wert
/// Colors repräsentiert eine Menge von Kartenfarben (Karo..Kreuz), und diese Funktion gibt die
/// Anzahl der Karten zurück, also die Anzahl der Einsen in der Bitschreibweise von Colors
//----------------------------------------------------------------------------------------------------
inline int GetNumberCardsFromColors(int Colors) 
{
    return ( (Colors & 8) >> 3) + ( (Colors & 4) >> 2) + ( (Colors & 2) >> 1) + (Colors & 1);
}


//----------------------------------------------------------------------------------------------------
/// A move consists of a value, a set of colors and an ID to play
//----------------------------------------------------------------------------------------------------
class CMove 
{
public:
	/// Welcher Wert gespielt wurde, zB 0 für 7, 7 für As
	int ValueCards;

	/// Bitvektor welche Farben gespielt wurden. 1 = Karo, 8 = Kreutz
	int ColorsCards;

	/// Konstruiert einen Move vom Wert + Farben
	CMove(int Value, int Colors) 
	{ 
		ValueCards = Value; 
		ColorsCards = Colors; 
	}

	/// Leerer Konstruktor
	CMove() 
	{ 
		Clear(); 
	}

	/// Macht den Move leer
	void Clear() 
	{ 
		ValueCards = 0; 
		ColorsCards = 0; 
	}

	/// Wahr, wenn der Move "leer" ist, also PlayerID < 0 oder keine Karten
	int IsEmpty() const 
	{ 
		return (ColorsCards == 0) || (ValueCards < 0); 
	}

	/// Die Anzahl der Karten
	int GetNumberCards() 
	{ 
		return GetNumberCardsFromColors( ColorsCards ); 
	}

	/// In einen einfachen Move konvertieren
	TMoveSimple GetMoveSimple() 
	{ 
		TMoveSimple MoveSimple( GetNumberCards(), ValueCards);
		return MoveSimple;
	}

	/// Are the given cards present in this move?
	bool Contains( CMove Cards) 
	{ 
        return ((Cards.ValueCards == ValueCards) && (Cards.ColorsCards & ColorsCards)) || Cards.IsEmpty();
	}

	/// Checkt zwei Moves auf Gleichheit in Wert und Farben
	bool operator == (const CMove & Other) 
	{ 
		return ValueCards == Other.ValueCards && ColorsCards == Other.ColorsCards; 
	}

	/// Ordnungsrelation
	bool operator < (const CMove & Other) 
	{
		return 
			(ValueCards < Other.ValueCards) || 
			(ValueCards == Other.ValueCards && ColorsCards < Other.ColorsCards); 
	}
};

/*
//----------------------------------------------------------------------------------------------------
/// Die Vergleichsfunktion zum Sortieren von zwei Karten.
/// Primärer Schlüssel Wert, sekunderär Schlüssel: Farbe
//----------------------------------------------------------------------------------------------------
inline bool MoveVergleich( CMove Karte1, CMove Karte2 ) 
{
	if (Karte1.ValueCards != Karte2.ValueCards)
		return (Karte1.ValueCards < Karte2.ValueCards);
	else 
		return ( Karte1.ColorsCards < Karte2.ColorsCards);
}
*/


#endif

