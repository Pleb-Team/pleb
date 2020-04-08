import QtQuick 2.12
import io.qt.examples.backend 1.0

Item {
  id: gameLogicInterface


  BackEnd {
      id: arschlochGameLogic
  }


  function thinkAIWrapper()
  {

      arschlochGameLogic.resetGameState()

      // for all Cards in any player's hand
      // PlayerID: 0...3
      // nNumberCards: Anzahl (0...3 Anzahl der Karten) sollte erstmal 1 sein
      // Wert (0...7 entspricht 7...As) der Zug Empfehlung
      // arschlochGameLogic.addPlayerCards(nPlayerID, nNumberCards,  nValueCards);

      // Example: Every player has one card of every value
      for (var n = 0; n < 7; n++)
      {
          arschlochGameLogic.addPlayerCards(0, 1, n)
          arschlochGameLogic.addPlayerCards(1, 1, n)
          arschlochGameLogic.addPlayerCards(2, 1, n)
          arschlochGameLogic.addPlayerCards(3, 1, n)
      }


      // Last player move, i.e. what do we see in the middle of the table right now?
      // arschlochGameLogic.setLastMoveSimple(int nLastPlayerID, nNumberCards,  nValueCards);
      // Example: Player 3 has played one card of value 8
      arschlochGameLogic.setLastMoveSimple(3, 1, 1);

      // Whos turn is it? AI will compute a move for this playerS
      // arschlochGameLogic.setActualPlayer(nActualPlayerID)
      arschlochGameLogic.setActualPlayerID(0)

      console.debug("[thinkAIWrapper] GameState: " )
      console.debug(arschlochGameLogic.getPlayerCardsText() )

      // Now let the AI think
      arschlochGameLogic.think()

      var nValueCards = arschlochGameLogic.getMoveSimpleAIValue();
      var nNumberCards = arschlochGameLogic.getMoveSimpleAINumber();

      console.debug("[thinkAIWrapper] AI computed move for Player " + arschlochGameLogic.getActualPlayerID() + ": ")
      console.debug(arschlochGameLogic.getMoveSimpleAIText())
      console.debug("Number cards: " + nNumberCards + ", Value: " + nValueCards)
  }
}



