import QtQuick 2.0
import io.qt.examples.backend 1.0

Item {
    id: legacyPlebCodeBridge

//    property var idMap: []
//    property alias arschlochGameLogicLocal: arschlochGameLogicLocal

    // A local Backend thats used only for computing the AI move. Note that this one is regularly reset in order to update the cards
    // from the QML logic, whereas the "global" arschlochGameLogicLocal acts like a continuous state throughout all the game
    BackEnd  {
        id: arschlochGameLogicLocal
    }


    // Important: Completele resets arschlochGameLogicLocal!
    function syncStateQML2Legacy(nActualPlayerLegacy)
    {
        arschlochGameLogicLocal.resetGameState()
        arschlochGameLogicLocal.resetGameResult()

        // Set players cards
        for (var nPlayer = 0; nPlayer < playerHands.children.length; nPlayer++)
        {
            // Sync every single card
            for (var nCard = 0; nCard < playerHands.children[nPlayer].hand.length; nCard++)
            {
              // PlayerID: 0...3
              // nNumberCards: Anzahl (0...3 Anzahl der Karten) sollte erstmal 1 sein
              // Wert (0...7 entspricht 7...As) der Zug Empfehlung
              // arschlochGameLogicLocal.addPlayerCards(nPlayerID, nNumberCards,  nValueCards);
              arschlochGameLogicLocal.addPlayerCards(nPlayer, 1, playerHands.children[nPlayer].hand[nCard].points - 7)
            }

            // Sync card exchange info
            arschlochGameLogicLocal.setCardExchangeNumber(nPlayer, gameLogicPleb.arschlochGameLogic.getCardExchangeNumber(nPlayer))
            arschlochGameLogicLocal.setCardExchangePartner(nPlayer, gameLogicPleb.arschlochGameLogic.getCardExchangePartner(nPlayer))
        }

        // Last player move, i.e. what do we see in the middle of the table right now?
        // arschlochGameLogicLocal.setLastMoveSimple(int nLastPlayerID, nNumberCards,  nValueCards);
        // Example: Player 3 has played one card of value 8
        if (depot.lastPlayerUserID && depot.lastDeposit && depot.lastDeposit.length > 0)
        {
            var lastPlayerIndex = gameLogic.getHandIndex(depot.lastPlayerUserID)
            arschlochGameLogicLocal.setLastMoveSimple(lastPlayerIndex, depot.lastDeposit.length, depot.lastDeposit[0].points - 7)
        }
        else
        {
            // do nothing: last Move is empty, i.e. this player can play freely
        }

        // Whos turn is it? AI will compute a move for this playerS
        arschlochGameLogicLocal.setActualPlayerID(nActualPlayerLegacy)
        arschlochGameLogicLocal.setState(gameLogicPleb.arschlochGameLogic.getState())

        // Verify correct transport of card information via console text output
        var s = arschlochGameLogicLocal.getPlayerCardsText()
        console.debug("[thinkAIWrapper] GameState: \n" +  s)
    }


    // \out Array of card IDs
    function calcMove(userId, nActualPlayerLegacy)
    {
        var playerHand = getHand(userId)

        syncStateQML2Legacy(nActualPlayerLegacy)

		// Now let the AI think
        arschlochGameLogicLocal.think()
        console.debug("[calcMove] userId: " + userId + ", retrieveLegacyPlayerId: " + arschlochGameLogicLocal.getActualPlayerID() + ", nActualPlayerLegacy: " + nActualPlayerLegacy)
        console.debug("[calcMove] AI computed move for Player " + arschlochGameLogicLocal.getActualPlayerID() + ": " + arschlochGameLogicLocal.getMoveSimpleAIText())

        // Decode legacy card meanings (Number, Value) to Pleb coding
        var nValueCardsLegacy = arschlochGameLogicLocal.getMoveSimpleAIValue()
        var nNumberCardsLegacy = arschlochGameLogicLocal.getMoveSimpleAINumber()

        // Note: Card_7 in legacy has value = 0, but points = 7 in QML
        return playerHand.findCardIDs(nNumberCardsLegacy, nValueCardsLegacy + 7)
    }


    // \out Array of card IDs
    function calcMoveCardExchange(userId, nActualPlayerLegacy)
    {
        var playerHand = getHand(userId)

        syncStateQML2Legacy(nActualPlayerLegacy)

        // Now let the AI think
        arschlochGameLogicLocal.thinkCardExchange(nActualPlayerLegacy)
        console.debug("[calcMoveCardExchange] userId: " + userId + ", retrieveLegacyPlayerId: " + arschlochGameLogicLocal.getActualPlayerID() + ", nActualPlayerLegacy: " + nActualPlayerLegacy)
        console.debug("[calcMoveCardExchange] AI computed move for Player " + nActualPlayerLegacy + ": " + arschlochGameLogicLocal.getMoveSimpleAIText())

        // Decode legacy card meanings (Number, Value) to Pleb coding
        var nValueCardsLegacy = arschlochGameLogicLocal.getMoveSimpleAIValue()
        var nNumberCardsLegacy = arschlochGameLogicLocal.getMoveSimpleAINumber()

        // Note: Card_7 in legacy has value = 0, but points = 7 in QML
        return playerHand.findCardIDs(nNumberCardsLegacy, nValueCardsLegacy + 7)
    }
}
