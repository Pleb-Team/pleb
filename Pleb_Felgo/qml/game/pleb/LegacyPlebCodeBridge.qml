import QtQuick 2.0
import io.qt.examples.backend 1.0

Item {
    id: legacyPlebCodeBridge

    property var idMap: []
    property alias arschlochGameLogic: arschlochGameLogic

    BackEnd  {
        id: arschlochGameLogic
    }


    function getMove(userId)
    {
        var result = []
        var userHand
        var legacyPlayerId
        var s = ""
		
        arschlochGameLogic.resetGameState()
		
		// Set players cards
        for (var nPlayer = 0; nPlayer < playerHands.children.length; nPlayer++) {
            legacyPlayerId = retrieveLegacyPlayerId(playerHands.children[nPlayer].player.userId)
            for (var nCard = 0; nCard < playerHands.children[nPlayer].hand.length; nCard++) {
			
			  // PlayerID: 0...3
              // nNumberCards: Anzahl (0...3 Anzahl der Karten) sollte erstmal 1 sein
              // Wert (0...7 entspricht 7...As) der Zug Empfehlung
              // arschlochGameLogic.addPlayerCards(nPlayerID, nNumberCards,  nValueCards);
              arschlochGameLogic.addPlayerCards(legacyPlayerId, 1, playerHands.children[nPlayer].hand[nCard].points - 7)
            }
			
			// \todo Joachim: What's this for?
            if (playerHands.children[nPlayer].player.userId === userId) {
                userHand = playerHands.children[nPlayer].hand
            }
        }
		
        // Last player move, i.e. what do we see in the middle of the table right now?
        // arschlochGameLogic.setLastMoveSimple(int nLastPlayerID, nNumberCards,  nValueCards);
        // Example: Player 3 has played one card of value 8
        if (depot.lastPlayerUserID && depot.lastDeposit && depot.lastDeposit.length > 0)
        {
            arschlochGameLogic.setLastMoveSimple(retrieveLegacyPlayerId(depot.lastPlayerUserID), depot.lastDeposit.length, depot.lastDeposit[0].points - 7)
        }
        else
        {
            // do nothing: last Move is empty, i.e. this player can play freely
        }
		
        // Whos turn is it? AI will compute a move for this playerS
        // arschlochGameLogic.setActualPlayer(nActualPlayerID)
        arschlochGameLogic.setActualPlayerID(retrieveLegacyPlayerId(userId))
		
        // Verify correct transport of card information via console text output
        s = arschlochGameLogic.getPlayerCardsText()
        console.debug("[thinkAIWrapper] GameState: \n" +  s)


		// Now let the AI think
        arschlochGameLogic.think()
        console.debug("[thinkAIWrapper] AI computed move for Player " + arschlochGameLogic.getActualPlayerID() + ": " + arschlochGameLogic.getMoveSimpleAIText())

        // Decode legacy card meanings (Number, Value) to Pleb coding
        var movePoints = arschlochGameLogic.getMoveSimpleAIValue() + 7
        var groupSize = arschlochGameLogic.getMoveSimpleAINumber()
        for (var k = 0; (result.length < groupSize) && (k < userHand.length); k++) {
            if (userHand[k].points === movePoints) {
                result.push(userHand[k].entityId)
            }
        }
		
        return result
    }

    // Creates a legacy player ID (0..3) from the player hashs as used by the Felgo Framework
	// \todo make sure the legacy player IDs correspond to the order of the game! i.e. the players
	// should play in this order 0 -> 1 -> 2 -> 3 -> 0 -> ... 
    function retrieveLegacyPlayerId(userId) {

        if (!idMap.includes(userId))
            idMap.push(userId)

        var legacyId = idMap.indexOf(userId)
        return legacyId
    }

}
