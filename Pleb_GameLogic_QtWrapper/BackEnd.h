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
#include "Game/Game/Game.h"


class BackEnd : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int moveSimpleValue READ getMoveSimpleValue WRITE setMoveSimpleValue NOTIFY moveSimpleValueChanged)
    Q_PROPERTY(int moveSimpleNumber READ getMoveSimpleNumber WRITE setMoveSimpleNumber NOTIFY moveSimpleNumberChanged)
    Q_PROPERTY(int actualPlayerID READ getActualPlayerID NOTIFY actualPlayerIDChanged)
    Q_PROPERTY(int lastPlayerID READ getLastPlayerID NOTIFY lastPlayerIDChanged)
    Q_PROPERTY(int numberPlayersMax READ getNumberPlayersMax)
    Q_PROPERTY(int numberPlayersInGame READ getNumberPlayersInGame)

    Q_PROPERTY(QString moveSimpleText READ getMoveSimpleText NOTIFY moveSimpleTextChanged)
    Q_PROPERTY(QString playerCardsText READ getPlayerCardsText NOTIFY playerCardsTextChanged)
    Q_PROPERTY(QString lastMoveSimpleText READ getLastMoveSimpleText NOTIFY lastMoveSimpleTextChanged)


private:
    QString m_userName;

    TMoveSimple m_MoveSimple = TMoveSimple(3, CARD_BUBE);
    CMoveResults m_MoveSimpleResults();
    CMove m_Move = CMove(CARD_DAME, COLOR_PIK);
    CGameState m_GameState;
    CGameStatistics m_GameStatistics;
    CGame m_Game;


public:
    explicit BackEnd(QObject *parent = nullptr);

    Q_INVOKABLE int getMoveSimpleValue() { return m_MoveSimple.ValueCards; }
    Q_INVOKABLE void setMoveSimpleValue(const int MoveSimpleValue);

    Q_INVOKABLE int getMoveSimpleNumber() { return m_MoveSimple.NumberCards; }
    Q_INVOKABLE void setMoveSimpleNumber(const int MoveSimpleNumber);

    Q_INVOKABLE int getActualPlayerID() { return m_GameState.m_nActualPlayer; }
    Q_INVOKABLE int getLastPlayerID() { return m_GameState.m_nLastPlayer; }

    // How many players still have > 0 cards
    Q_INVOKABLE int getNumberPlayersInGame() { return m_GameState.GetNumberPlayers(); }

    // Maximum number of players possible, e.g. at beginning of game
    Q_INVOKABLE int getNumberPlayersMax() { return NUMBER_PLAYER; }

    Q_INVOKABLE QString getMoveSimpleText() { return QString::fromStdString(m_MoveSimple.GetText() );  }
    Q_INVOKABLE QString getLastMoveSimpleText() { return QString::fromStdString(m_GameState.m_LastMoveSimple.GetText() );  }

    Q_INVOKABLE QString getPlayerCardsText() { return getPlayerCardsText(m_GameState.m_nActualPlayer); }
    Q_INVOKABLE QString getPlayerCardsText(int nPlayerID);

    Q_INVOKABLE void playCards();

signals:
    void moveSimpleValueChanged();
    void moveSimpleNumberChanged();
    void moveSimpleTextChanged();
    void lastMoveSimpleTextChanged();

    void playerCardsTextChanged();
    void playerCardsChanged(int nPlayerID);

    void actualPlayerIDChanged();
    void lastPlayerIDChanged();
};

#endif // BACKEND_H
