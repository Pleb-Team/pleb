#include <QMessageBox>

#include "BackEnd.h"



BackEnd::BackEnd(QObject *parent) :
    QObject(parent)
{
    int n;

    m_GameState.m_nActualPlayer = 0;
    m_GameState.m_nLastPlayer = 0;
    m_GameState.m_nZustand = Jojo_SpielZustandSpielen;

    // Initial card distribution
    for (n = CARD_7; n < NUMBER_VALUE; n++)
    {
        m_GameState.PlayerBekommtKarten(TMoveSimple(2, n), 0);
        m_GameState.PlayerBekommtKarten(TMoveSimple(2, n), 1);
        m_GameState.PlayerBekommtKarten(TMoveSimple(2, n), 2);
        m_GameState.PlayerBekommtKarten(TMoveSimple(2, n), 3);
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

    // Player 0 receives a lot of cards
    for (int v = 0; v < NUMBER_VALUE; v++)
        if (m_GameState.m_CardDistribution[nPlayerID][v] > 0)
            s = s + TMoveSimple(m_GameState.m_CardDistribution[nPlayerID][v], v).GetText();

    return QString::fromStdString(s);
}



Q_INVOKABLE void BackEnd::playCards()
{
    if (m_GameState.PlayCards(m_MoveSimple, true, true) == JOJO_ERROR)
    {
        g_pKonfig->Log("Error: You cannot play this move " + m_MoveSimple.GetText());
    }

    emit lastMoveSimpleTextChanged();
    emit playerCardsTextChanged();
    emit actualPlayerIDChanged();
    emit lastPlayerIDChanged();
    emit playerCardsChanged(m_GameState.m_nLastPlayer);
}




