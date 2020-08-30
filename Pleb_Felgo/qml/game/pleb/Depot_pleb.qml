import QtQuick 2.0
import Felgo 3.0

Item {
  id: depotPleb
  width: 82
  height: 134

  // current cards on top of the depot (the cards played in the previous turn)
  property var lastDeposit: []

  // block the player for a short period of time when he gets skipped
  property alias effectTimer: effectTimer

  // whether the active player is skipped or not
//  property bool skipped: false

  // the current turn direction
//  property bool clockwise: true

//  property var lastPlayerUserID: null
//  property var finishedUserIDs: []


  // sound effect plays when a player gets skipped
  SoundEffect {
    volume: 0.5
    id: skipSound
    source: "../../../assets/snd/skip.wav"
  }


  // blocks the player for a short period of time and trigger a new turn when he gets skipped
  Timer {
      id: effectTimer
      repeat: false
      interval: 1500
      onTriggered:
      {
          effectTimer.stop()
//          skipped = false
          var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
          multiplayer.sendMessage(gameLogic.messageSetSkipped, {skipped: false, userId: userId})
          console.debug("<<<< Trigger new turn after effect")
          multiplayer.triggerNextTurn()
      }
  }

  // create the depot by placing a single stack card
  function createDepot(){
      // first player creates depot by playing first card
  }


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
//      lastPlayerUserID = userId
  }


  // check if allowed to play the selected card
  function validCard(cardId)
  {
      // Make sure this card is (still) in the palyers hand.
      var activeHand = gameLogic.getHand(multiplayer.activePlayer.userId)
      if (!activeHand)
          return false
      else if (!activeHand.inHand(cardId))
          return false

      // Check if card VALUE is legal, i.e. assume correct number of cards
      var card = entityManager.getEntityById(cardId)
      return (     (gameLogic.arschlochGameLogic.getLastPlayerID() < 0) )
               ||  (gameLogic.arschlochGameLogic.isMoveLegal(gameLogic.arschlochGameLogic.getLastMoveSimpleNumber(), card.points - 7) )
  }


//  function skipTurn(skipMove)
//  {
//      var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
//      if (skipMove)
//      {
//          skipSound.play()
//          skipped = true

//          if (multiplayer.activePlayer && multiplayer.activePlayer.connected){
//              multiplayer.leaderCode(function() {
//                  effectTimer.start()
//              })
//          }

//          console.debug("[skipTurn] player " + userId + " was skipped!")
//      } else
//      {
//          skipped = false
//      }
//  }


  // reset the depot
  function reset()
  {
//      skipped = false
      effectTimer.stop()
      lastDeposit = []
  }


}
