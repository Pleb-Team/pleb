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
        if (arschlochGameLogic.getLastPlayerID() >= 0)
            arschlochGameLogicLocal.setLastMoveSimple(arschlochGameLogic.getLastPlayerID(), arschlochGameLogic.getLastMoveSimpleNumber(), arschlochGameLogic.getLastMoveSimpleValue())

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
        console.debug("[calcMove] AI computed move for userId: " + userId + ", LegacyPlayerId: " + nActualPlayerLegacy +  ": " + arschlochGameLogicLocal.getMoveSimpleAIText())

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
        console.debug("[calcMoveCardExchange] AI computed move for userId: " + userId
                      + ", LegacyPlayerId " + nActualPlayerLegacy
                      + ", CardExchangenNumber: " + arschlochGameLogicLocal.getCardExchangeNumber(nActualPlayerLegacy)
                      + ", CardExchangePartner: " + arschlochGameLogicLocal.getCardExchangePartner(nActualPlayerLegacy)
                      + " --> Card exchange computed: " + arschlochGameLogicLocal.getMoveSimpleAIText() )

        // Decode legacy card meanings (Number, Value) to Pleb coding
        var nValueCardsLegacy = arschlochGameLogicLocal.getMoveSimpleAIValue()
        var nNumberCardsLegacy = arschlochGameLogicLocal.getMoveSimpleAINumber()

        console.assert( (nNumberCardsLegacy > 0) && (nValueCardsLegacy >= 0), "Error: Card exchange computed is invalid!")
        if ((nNumberCardsLegacy <= 0) || (nValueCardsLegacy < 0))
        {
            var s = arschlochGameLogicLocal.getPlayerCardsText()
            console.error("Error: Card exchange computed is invalid! Cards: \n " + s)

            // Nochmal neu starten zum Debuggen
            arschlochGameLogicLocal.thinkCardExchange(nActualPlayerLegacy)
        }

        // Note: Card_7 in legacy has value = 0, but points = 7 in QML
        return playerHand.findCardIDs(nNumberCardsLegacy, nValueCardsLegacy + 7)
    }
}
