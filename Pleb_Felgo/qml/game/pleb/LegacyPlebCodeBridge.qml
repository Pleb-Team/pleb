import QtQuick 2.0
//import io.qt.examples.backend 1.0

Item {
    id: legacyPlebCodeBridge

    property var idMap

    /* BackEnd */ Item {
        id: legacyPlebCode
    }


    function getMove(userId) {
        var result = []
        var userHand
        var legacyPlayerId
        legacyPlebCode.resetGameState()
        for (var i = 0; i < playerHands.children.length; i++) {
            legacyPlayerId = retrieveLegacyPlayerId(playerHands.children[i].player.userId)
            for (var j = 0; j < playerHands.children[i].hand.length; j++) {
                legacyPlebCode.addPlayerCards(legacyPlayerId, 1, playerHands.children[i].hand[j].points - 7)
            }
            if (playerHands.children[i].player.userId === userId) {
                userHand = playerHands.children[i].hand
            }
        }
        if (depot.lastDeposit && depot.lastDeposit.length > 0) {
            legacyPlebCode.setLastMoveSimple(retrieveLegacyPlayerId(depot.lastPlayer), depot.lastDeposit.length, depot.lastDeposit[0].points - 7)
        } else {
            // what TODO here? if no cards have been played yet, at the beginning of a game?
        }
        legacyPlebCode.setActualPlayer(retrieveLegacyPlayerId(userId))
        legacyPlebCode.Think()
        var movePoints = legacyPlebCode.getMoveSimpleAIValue() + 7
        var groupSize = legacyPlebCode.getMoveSimpleAINumber()
        for (var k = 0; k < groupSize && k < userHand.length; k++) {
            if (userHand[k].points === movePoints) {
                result.push(userHand[k].entityId)
            }
        }
        return result
    }

    function retrieveLegacyPlayerId(userId) {
        if (!idMap) {
            idMap = {}
        }
        var legacyId = idMap[userId]
        if (!legacyId) {
            legacyId = idMap.length
            idMap[userId] = legacyId
        }
        return legacyId
    }

}
