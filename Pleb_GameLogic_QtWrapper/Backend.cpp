#include <QMessageBox>

#include "BackEnd.h"



BackEnd::BackEnd(QObject *parent) :
    QObject(parent)
{
    m_GameState.m_nActualPlayer = 0;
    m_GameState.m_nLastPlayer = 0;
    m_GameState.m_nZustand = Jojo_SpielZustandSpielen;

    // Player 0 receives a lot of cards
    for (int n = CARD_9; n < NUMBER_VALUE; n++)
    {
        m_GameState.PlayerBekommtKarten(TMoveSimple(2, n), 0);
        m_GameState.PlayerBekommtKarten(TMoveSimple(4, n), 1);
    }

    emit playerCardsTextChanged();
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


QString BackEnd::getPlayerCardsText()
{
    std::string s;

    // Player 0 receives a lot of cards
    for (int v = 0; v < NUMBER_VALUE; v++)
        if (m_GameState.m_CardDistribution[m_GameState.m_nActualPlayer][v] > 0)
            s = s + TMoveSimple(m_GameState.m_CardDistribution[m_GameState.m_nActualPlayer][v], v).GetText();

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
}




