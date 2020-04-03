#ifndef MOVESIMPLE_H
#define MOVESIMPLE_H

#include "../Global.h"
#include <string>


//----------------------------------------------------------------------------------------------------
/// Abstrahierte Form eines Moves: Es werden nur Wert und Anzahl Karten gespeichert. Wird zB von der 
/// KI benutzt, da Farben im gesamten Spiel irrelevant sind
//----------------------------------------------------------------------------------------------------
struct TMoveSimple 
{
public:
	int NumberCards;
	int ValueCards;

	/// Gibt an, ob dies der "Schieben"-Move ist
    inline bool IsEmpty() const { return NumberCards == 0; }
    
	/// Konstuktor, setzt die Werte
	TMoveSimple() 
        : NumberCards(0), ValueCards(0) {}

	TMoveSimple( int nNumberCards, int nValueCards) 
        : NumberCards(nNumberCards), ValueCards( nValueCards ) {}


	std::string GetText() const
	{
		std::string s;

		if (IsEmpty())
		{
			s = "x";
		}
		else
			for(int n = 0; n<NumberCards;n++)
            {
//                s = s + " " + inttostr(ValueCards);
                if ((0 <= ValueCards) && (ValueCards <= MAX_VALUE))
                    s = s + " " + c_sTextOnCards[ValueCards];
                else
                    s = s + " ?";
            }



		return s;
	}

};

const TMoveSimple c_MoveSimpleSchieben(0, 0);



#endif

