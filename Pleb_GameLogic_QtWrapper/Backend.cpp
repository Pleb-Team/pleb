#include <QMessageBox>
#include <iostream>

#include "BackEnd.h"



BackEnd::BackEnd(QObject *parent) :
    QObject(parent)
{
    int n;
    int nActualPlayer = 0;
    CMove Move;

    // Direkt loslegen
    m_GameState.m_nActualPlayer = 0;
    m_GameState.m_nLastPlayer = 0;
    m_GameState.m_nZustand = Jojo_SpielZustandSpielen;


    // Initial card distribution
    m_Game.ShuffleCards();
    while (m_Game.GetNumberCards())
    {
        Move = m_Game.TakeOneCard(nActualPlayer);
        m_GameState.PlayerBekommtKarten(Move.GetMoveSimple(), nActualPlayer);
        nActualPlayer = (nActualPlayer + 1) % NUMBER_PLAYER;
    }

    // Notify observers
    emit playerCardsTextChanged();
    for (n = 0; n < NUMBER_PLAYER; n++)
    {
        emit playerCardsChanged(n);
    }
}



void BackEnd::setMoveSimpleValue(const int MoveSimpleValue)
{
    if (m_MoveSimple.ValueCards == MoveSimpleValue)
        return;

    m_MoveSimple.ValueCards = MoveSimpleValue;

    emit moveSimpleValueChanged();
    emit moveSimpleTextChanged();
}


void BackEnd::setMoveSimpleNumber(const int MoveSimpleNumber)
{
    if (m_MoveSimple.NumberCards == MoveSimpleNumber)
        return;

    m_MoveSimple.NumberCards = MoveSimpleNumber;

    emit moveSimpleNumberChanged();
    emit moveSimpleTextChanged();
}


QString BackEnd::getPlayerCardsText(int nPlayerID)
{
    std::string s;
    CPlayerSimpleAI2 PlayerSimpleAI2;
    TMoveSimple MoveSimpleAI;

    for (int v = 0; v < NUMBER_VALUE; v++)
        if (m_GameState.m_CardDistribution[nPlayerID][v] > 0)
            s = s + TMoveSimple(m_GameState.m_CardDistribution[nPlayerID][v], v).GetText();

    return QString::fromStdString(s);
}



Q_INVOKABLE void BackEnd::playCards()
{
    if (m_GameState.PlayCards(m_MoveSimple, true, true) == JOJO_ERROR)
    {
        g_pKonfig->Log("[BackEnd::playCards] Error: You cannot play this move " + m_MoveSimple.GetText());
    }

    std::string s = m_GameState.GetDescription();
    std::cout << m_GameState.GetDescription() << std::endl;

    emit lastMoveSimpleTextChanged();
    emit playerCardsTextChanged();
    emit actualPlayerIDChanged();
    emit lastPlayerIDChanged();
    emit playerCardsChanged(m_GameState.m_nLastPlayer);
}




