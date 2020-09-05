import QtQuick 2.0
import Felgo 3.0

Item {
  id: depotPleb
  width: 82
  height: 134

  // current cards on top of the depot (the cards played in the previous turn)
  property var lastDeposit: []


  // return a random number between two values
  function randomIntFromInterval(min,max)
  {
      return Math.floor(Math.random() * (max - min + 1) + min)
  }


  // add the selected cards to the depot
  function depositCards(cardEntities)
  {
      var zPos = (lastDeposit.length > 0) ? lastDeposit[lastDeposit.length - 1].z : 0
//      lastDeposit = []
      for (var i = 0; i < cardEntities.length; i++)
      {
          var card = cardEntities[i]

          card.newParent = depot
          card.state = "depot"
          card.hidden = false

          // move the card to the depot and vary the position and rotation
          var rotation = randomIntFromInterval(-5, 5)
          var xOffset = randomIntFromInterval(-5, 5) + ((i - ((cardEntities.length - 1)/2)) * (card.width / 2))
          var yOffset = randomIntFromInterval(-5, 5)
          card.rotation = rotation
          card.x = xOffset
          card.y = yOffset

          // the first card starts with z = zPos, the others get placed on top
          card.z = zPos + i

          // add the deposited card to the current reference cards
          lastDeposit.push(card)
      }

      var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
  }


  // check if allowed to play the selected card
  function validCardID(cardId)
  {
      // Make sure this card is (still) in the palyers hand.
      var activeHand = gameLogic.getHand(multiplayer.activePlayer.userId)
      if (!activeHand)
          return false
      else if (!activeHand.inHand(cardId))
          return false

      // Check if card value is legal, and whether we have enough cards
      var card = entityManager.getEntityById(cardId)
      var numberCardsSameValue = activeHand.countCards(card.points)
      var numberCardsToPlay = Math.min(gameLogic.arschlochGameLogic.getLastMoveSimpleNumber(), numberCardsSameValue)
      return (     (gameLogic.arschlochGameLogic.getLastPlayerID() < 0) )
                || (gameLogic.arschlochGameLogic.getLastMoveSimpleNumber() === 0)
                || (gameLogic.arschlochGameLogic.isMoveLegal(numberCardsToPlay, card.points - 7) )
  }


  // reset the depot
  function reset()
  {
      lastDeposit = []
  }


}
