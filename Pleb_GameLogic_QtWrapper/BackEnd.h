#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QString>

#include "Game/GlobalConstants.h"
#include "Game/Game/MoveSimple.h"
#include "Game/Game/MoveSimpleResults.h"
#include "Game/Game/Move.h"
#include "Game/Game/GameResult.h"
#include "Game/Game/GameStatistics.h"
#include "Game/Game/GameState.h"


class BackEnd : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int moveSimpleValue READ getMoveSimpleValue WRITE setMoveSimpleValue NOTIFY moveSimpleValueChanged)
    Q_PROPERTY(int moveSimpleNumber READ getMoveSimpleNumber WRITE setMoveSimpleNumber NOTIFY moveSimpleNumberChanged)
    Q_PROPERTY(int actualPlayerID READ getActualPlayerID NOTIFY actualPlayerIDChanged)
    Q_PROPERTY(int lastPlayerID READ getLastPlayerID NOTIFY lastPlayerIDChanged)

    Q_PROPERTY(QString moveSimpleText READ getMoveSimpleText NOTIFY moveSimpleTextChanged)
    Q_PROPERTY(QString playerCardsText READ getPlayerCardsText NOTIFY playerCardsTextChanged)
    Q_PROPERTY(QString lastMoveSimpleText READ getLastMoveSimpleText NOTIFY lastMoveSimpleTextChanged)




public:
    explicit BackEnd(QObject *parent = nullptr);

    int getMoveSimpleValue() { return m_MoveSimple.ValueCards; }
    void setMoveSimpleValue(const int MoveSimpleValue);

    int getMoveSimpleNumber() { return m_MoveSimple.NumberCards; }
    void setMoveSimpleNumber(const int MoveSimpleNumber);

    int getActualPlayerID() { return m_GameState.m_nActualPlayer; }
    int getLastPlayerID() { return m_GameState.m_nLastPlayer; }


    QString getMoveSimpleText() { return QString::fromStdString(m_MoveSimple.GetText() );  }
    QString getLastMoveSimpleText() { return QString::fromStdString(m_GameState.m_LastMoveSimple.GetText() );  }

    QString getPlayerCardsText();

    Q_INVOKABLE void playCards();

signals:
    void moveSimpleValueChanged();
    void moveSimpleNumberChanged();
    void moveSimpleTextChanged();
    void lastMoveSimpleTextChanged();
    void playerCardsTextChanged();
    void actualPlayerIDChanged();
    void lastPlayerIDChanged();

private:
    QString m_userName;

    TMoveSimple m_MoveSimple = TMoveSimple(3, CARD_BUBE);
    CMoveResults m_MoveSimpleResults();
    CMove m_Move = CMove(CARD_DAME, COLOR_PIK);
    CGameState m_GameState;
    CGameStatistics m_GameStatistics;
};

#endif // BACKEND_H
