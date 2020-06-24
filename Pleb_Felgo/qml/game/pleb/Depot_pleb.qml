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
  property bool skipped: false

  // the current turn direction
  property bool clockwise: true

  property var lastPlayerUserID: null
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
    onTriggered: {
      effectTimer.stop()
      skipped = false
      var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
      multiplayer.sendMessage(gameLogic.messageSetSkipped, {skipped: false, userId: userId})
      console.debug("<<<< Trigger new turn after effect, clockwise: " + clockwise)
      gameLogic.triggerNewTurn()
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
  function depositCards(cardIds){
//      console.debug("cardIds: " + cardIds)
      var zPos = (lastDeposit.length > 0) ? lastDeposit[lastDeposit.length - 1].z : 0
      lastDeposit = []
      for (var i = 0; i < cardIds.length; i++) {
          var card = entityManager.getEntityById(cardIds[i])
          // change the parent of the card to depot
          changeParent(card)
          // uncover card right away if the player is connected
          // used for wild and wild4 cards
          // activePlayer might be undefined here, when initially synced
//          console.debug("unhide: " + (!multiplayer.activePlayer || multiplayer.activePlayer.connected))
          if (!multiplayer.activePlayer || multiplayer.activePlayer.connected){
              card.hidden = false
          }

          // move the card to the depot and vary the position and rotation
          var rotation = randomIntFromInterval(-5, 5)
          var xOffset = randomIntFromInterval(-5, 5) + ((i - ((cardIds.length - 1)/2)) * (card.width / 2))
          var yOffset = randomIntFromInterval(-5, 5)
          card.rotation = rotation
          card.x = xOffset
          card.y = yOffset

          // the first card starts with z 0, the others get placed on top
          card.z = zPos + i

          // add the deposited card to the current reference cards
          lastDeposit.push(card)
      }

      var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
      lastPlayerUserID = userId
  }

  // change the card's parent to depot
  function changeParent(card){
//      console.debug("card: " + card + " depot: " + depot)
    card.newParent = depot
    card.state = "depot"
  }


  // check if allowed to play the selected card
  function validCard(cardId)
  {
      var activeHand = gameLogic.getHand(multiplayer.activePlayer.userId)

      // Value is ok and enough cards of this value exist in the players hand
      if (!activeHand)
          return false
      else if (!activeHand.inHand(cardId))
          return false

      var card = entityManager.getEntityById(cardId)

      // Depot is empty --> This player can play freely
      if (      !lastPlayerUserID
            ||  lastDeposit === undefined
            ||  lastDeposit === null
            ||  lastDeposit.length === 0
          )
      {
          return true
      }

      // This player played last --> He now can play freely
      // TODO hier sollten wir niemals landen, denn in dem Fall sollte schon lastPlayerUserID == null sein
      if (multiplayer.activePlayer.userId === lastPlayerUserID)
          return true


      if (card.points > lastDeposit[0].points && activeHand.countCards(card.points) >= lastDeposit.length)
          return true

      return false
  }


  function skipTurn(skipMove) {
      var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
      if (skipMove)
      {
          skipSound.play()
          skipped = true

          if (multiplayer.activePlayer && multiplayer.activePlayer.connected){
              multiplayer.leaderCode(function() {
                  effectTimer.start()
              })
          }

          console.debug("player " + userId + " MISSED TURN!")
      } else
      {
          skipped = false
      }
  }


  // reset the depot
  function reset()
  {
      skipped = false
      clockwise = true
      effectTimer.stop()
      lastDeposit = []
      lastPlayerUserID = null
//      finishedUserIDs = []
  }

  // sync the depot with the leader
  function syncDepot(depotCardIDs, lastDepositIDs, lastDepositCardColors, skipped, clockwise, effect, drawAmount, lastPlayerUserID, finishedUserIDs)
  {
    for (var i = 0; i < depotCardIDs.length; i++){
      depositCards([depotCardIDs[i]])
      deck.numberCardsInStack --
    }

    depositCards(lastDepositIDs)
    for (var j = 0; j < lastDepositIDs.length; j++) {
        lastDeposit[j].cardColor = lastDepositCardColors[j]
    }

    depot.skipped = skipped
    depot.clockwise = clockwise
    depot.lastPlayerUserID = lastPlayerUserID
//    depot.finishedUserIDs = finishedUserIDs
  }
}
