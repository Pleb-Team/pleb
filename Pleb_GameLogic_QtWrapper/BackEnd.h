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
#include "Game/AI/PlayerAI.h"
#include "Game/AI/PlayerSimpleAI2.h"


class BackEnd : public QObject
{
    Q_OBJECT

    // Declare everything as property that might be accessed Don't know why, but otherwise the function getPlayerCardsText()
    // cannot be accesses from QML / JS
    Q_PROPERTY(int moveSimpleValue READ getMoveSimpleValue WRITE setMoveSimpleValue NOTIFY moveSimpleValueChanged)
    Q_PROPERTY(int moveSimpleNumber READ getMoveSimpleNumber WRITE setMoveSimpleNumber NOTIFY moveSimpleNumberChanged)
    Q_PROPERTY(QString moveSimpleText READ getMoveSimpleText NOTIFY moveSimpleTextChanged)
    Q_PROPERTY(QString moveSimpleAI READ getMoveSimpleAIText)

    Q_PROPERTY(int actualPlayerID READ getActualPlayerID WRITE setActualPlayerID NOTIFY actualPlayerIDChanged)
    Q_PROPERTY(int lastPlayerID READ getLastPlayerID WRITE setLastPlayerID NOTIFY lastPlayerIDChanged)
//    Q_PROPERTY(int numberPlayersMax READ getNumberPlayersMax)
    Q_PROPERTY(int numberPlayersInGame READ getNumberPlayersInGame)

    Q_PROPERTY(QString playerCardsText READ getPlayerCardsText NOTIFY playerCardsTextChanged)
    Q_PROPERTY(QString lastMoveSimpleText READ getLastMoveSimpleText NOTIFY lastMoveSimpleTextChanged)


private:
    TMoveSimple m_MoveSimple = c_MoveSimpleSchieben;
    TMoveSimple m_MoveSimpleAI = c_MoveSimpleSchieben;
    CGameState m_GameState;
    CGame m_Game;


public:
    explicit BackEnd(QObject *parent = nullptr);


    // Manipulate internal MoveSimple just as GUI helper
    Q_INVOKABLE QString getMoveSimpleText() { return QString::fromStdString(m_MoveSimple.GetText() );  }
    Q_INVOKABLE int getMoveSimpleValue() { return m_MoveSimple.ValueCards; }
    Q_INVOKABLE void setMoveSimpleValue(const int MoveSimpleValue);
    Q_INVOKABLE int getMoveSimpleNumber() { return m_MoveSimple.NumberCards; }
    Q_INVOKABLE void setMoveSimpleNumber(const int MoveSimpleNumber);

    // How many players still have > 0 cards
    Q_INVOKABLE int getNumberPlayersInGame() { return m_GameState.GetNumberPlayers(); }

    // Maximum number of players possible, e.g. at beginning of game
    Q_INVOKABLE int getNumberPlayersMax() { return NUMBER_PLAYER; }

    Q_INVOKABLE QString getPlayerCardsText() { return QString::fromStdString(m_GameState.GetDescription()); }
    Q_INVOKABLE QString getPlayerCardsText(int nPlayerID);

    // Access to LastPlayerID, i.e. thte player who played the last move which is currently
    // visible in the center of the table (deck)
    Q_INVOKABLE int getLastPlayerID() { return m_GameState.m_nLastPlayer; }
    Q_INVOKABLE void setLastPlayerID(int n) { m_GameState.m_nLastPlayer = n; }


    Q_INVOKABLE void playCards();

    // --------------------------------------------------------------------------------------------


    // Resets Lastmove, LastPlayer, NumberPlayer, ActualPLayer all to initial invalid (-1)
    // and clears all cards, i.e. all players have empty hands
    Q_INVOKABLE void resetGameState() {
        m_MoveSimpleAI = c_MoveSimpleSchieben;
        m_GameState.Reset(); }

    // Adds the given card number and value to the mentioned players cards in his hand
    Q_INVOKABLE void addPlayerCards(int nPlayerID, int nNumberCards, int nValueCards)    {
        m_GameState.PlayerBekommtKarten(TMoveSimple(nNumberCards, nValueCards), nPlayerID);  }

    // Set the last move, i.e. what cards are currently visible in the centre of the table.
    // For the game rules, it is also important who played these cards thus nLastPlayerID must be given
    Q_INVOKABLE QString getLastMoveSimpleText() { return QString::fromStdString(m_GameState.m_LastMoveSimple.GetText() );  }
    Q_INVOKABLE void setLastMoveSimple(int nLastPlayerID, int nNumberCards, int nValueCards) {
        m_GameState.m_nLastPlayer = nLastPlayerID;
        m_GameState.m_LastMoveSimple = TMoveSimple(nNumberCards, nValueCards); }

    // Access to the current Player, i.e. the one who is next to play
    // \todo Integrate as a parameter into the rountine think()
    Q_INVOKABLE int getActualPlayerID() { return m_GameState.m_nActualPlayer; }
    Q_INVOKABLE void setActualPlayerID(int n) { m_GameState.m_nActualPlayer = n; }

    // Start the AI think routine and let the AI compute a smart move for the current player, which
    // will be stored in m_MoveSimpleAI. It can be read through getMoveSimpleAI(Value|Number)
    Q_INVOKABLE void think() {
        CPlayerSimpleAI2 PlayerSimpleAI2;
        m_MoveSimpleAI = PlayerSimpleAI2.ThinkInGameState(&m_GameState);   }

    // Read the AI move as computed before via think()
    // \todo would be nicer to return this tuple directly as function result of think(), but how to return 2 integers?
    Q_INVOKABLE int getMoveSimpleAIValue() { return m_MoveSimpleAI.ValueCards; }
    Q_INVOKABLE int getMoveSimpleAINumber() { return m_MoveSimpleAI.NumberCards; }
    Q_INVOKABLE QString getMoveSimpleAIText() { return QString::fromStdString(m_MoveSimpleAI.GetText()); }



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
