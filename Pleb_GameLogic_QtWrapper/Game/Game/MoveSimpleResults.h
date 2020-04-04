#ifndef MOVESIMPLERESULTS_H
#define MOVESIMPLERESULTS_H


#include "MoveSimple.h"



//-------------------------------------------------------------------------------------------------
/// Klasse CMoveResult
/// Stores for each possible move ( Number of Moves <= Cards in Hand + 1 !!! ) the expected Result
/// This class represents heuristic for gamestates in alphabeta, eg
//-------------------------------------------------------------------------------------------------
class CMoveResults
{
private:
    int m_ExpectedResult[NUMBER_VALUE][NUMBER_COLOR];
    int m_ExpectedResultForNoMove;

public:
    CMoveResults()
    {
        Reset();
    }

    /// Retrieve the expected game result for a move
    int GetResult( TMoveSimple Move )
    {
        if ( !Move.IsEmpty() )
            return m_ExpectedResult[Move.ValueCards][Move.NumberCards-1];
        else
            return m_ExpectedResultForNoMove;
    }

    /// Store the expected game result for a move
    void SetResult( TMoveSimple Move, int Result )
    {
        if ( !Move.IsEmpty() )
            m_ExpectedResult[Move.ValueCards][Move.NumberCards-1] = Result;
        else
            m_ExpectedResultForNoMove = Result;
    }

    /// resets all results to RESULT_UNDEFINED
    void Reset()
    {
        // Initialisierung: Matrix vorbelegen
        for(int n = 0; n < NUMBER_VALUE; n++)
            for(int m = 0; m < NUMBER_COLOR; m++)
                m_ExpectedResult[n][m] = RESULT_UNDEFINED;

        m_ExpectedResultForNoMove = RESULT_UNDEFINED;
    }
};



#endif // MOVESIMPLERESULTS_H
