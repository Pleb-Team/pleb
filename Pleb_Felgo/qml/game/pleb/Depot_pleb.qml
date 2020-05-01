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
  // the current depot card effect for the next player
  property bool effect: false
  // whether the active player is skipped or not
  property bool skipped: false
  // the current turn direction
  property bool clockwise: true

  // the amount of cards to draw, can be increased by draw2 and wild4 cards
//  property int drawAmount: 1

  property var lastPlayer: null
  property var finishedPlayers: []


  // sound effect plays when a player gets skipped
  SoundEffect {
    volume: 0.5
    id: skipSound
    source: "../../../assets/snd/skip.wav"
  }

  // sound effect plays when a player gets skipped
  SoundEffect {
    volume: 0.5
    id: reverseSound
    source: "../../../assets/snd/reverse.wav"
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
      lastPlayer = userId

      // signal if the placed cards has an effect on the next player
      if(hasEffect()){
          effect = true
          multiplayer.sendMessage(gameLogic.messageSetEffect, {effect: true, userId: userId})
      } else {
          effect = false
          multiplayer.sendMessage(gameLogic.messageSetEffect, {effect: false, userId: userId})
      }
  }

  // change the card's parent to depot
  function changeParent(card){
//      console.debug("card: " + card + " depot: " + depot)
    card.newParent = depot
    card.state = "depot"
  }

  // check if the card has an effect for the next player
  function hasEffect(){
    return false
  }

  // check if the selected card matches with the current reference card
  function validCard(cardId){
      var activeHand
    // only continue if the selected card is in the hand of the active player
    for (var i = 0; i < playerHands.children.length; i++) {
      if (playerHands.children[i].player === multiplayer.activePlayer){
          activeHand = playerHands.children[i]
        if (!activeHand.inHand(cardId)) return false
      }
    }
    var card = entityManager.getEntityById(cardId)

    // rules
    if (lastDeposit === undefined || lastDeposit === null || lastDeposit.length === 0) return true
    if (multiplayer.activePlayer.userId === lastPlayer) return true
    if (card.points > lastDeposit[0].points && activeHand.countCards(card.points) >= lastDeposit.length) return true

    // TODO LASTCARD the last card of a player may still be beaten, thus this is commented; otherwise, the next player would immediately be able to play
    // if (finishedPlayers.includes(lastPlayer)) return true

    return false
  }

  // play a card effect depending on the card type
  function cardEffect(){
    if (effect){
      if (lastDeposit.length > 0 && lastDeposit[0].variationType === "skip") {
        skip()
      }
    } else {
      // reset the card effects if they are not active
      skipped = false
//      depot.drawAmount = 1
//      var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
//      multiplayer.sendMessage(gameLogic.messageSetDrawAmount, {amount: 1, userId: userId})
    }
  }

  function skipTurn(skipMove) {
      var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
      if (skipMove) {
          effect = true
          skip()
          console.debug("player " + userId + " MISSED TURN!")
      } else {
          skipped = false
//          depot.drawAmount = 1
//          multiplayer.sendMessage(gameLogic.messageSetDrawAmount, {amount: 1, userId: userId})
      }
  }

  // skip the current player by playing a sound, setting the skipped variable and starting the skip timer
  function skip(){
    skipSound.play()
    effect = false
    var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
    multiplayer.sendMessage(gameLogic.messageSetEffect, {effect: false, userId: userId})
    skipped = true

    if (multiplayer.activePlayer && multiplayer.activePlayer.connected){
      multiplayer.leaderCode(function() {
        effectTimer.start()
      })
    }
  }

  // reverse the current turn direction
  function reverse(){
    reverseSound.play()
    // change direction
    clockwise ^= true
    // send current direction to other players
    var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
    multiplayer.sendMessage(gameLogic.messageSetReverse, {clockwise: clockwise, userId: userId})
  }

  // increase the drawAmount when a draw2 or wild4 effect is active
//  function draw(amount){
//    if (drawAmount == 1) {
//      drawAmount = amount
//    } else {
//      drawAmount += amount
//    }
//    var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
//    multiplayer.sendMessage(gameLogic.messageSetDrawAmount, {amount: depot.drawAmount, userId: userId})
//  }

  // reset the depot
  function reset(){
      skipped = false
      clockwise = true
      //    drawAmount = 1
      effect = false
      effectTimer.stop()
      lastDeposit = []
      finishedPlayers = []
  }

  // sync the depot with the leader
  function syncDepot(depotCardIDs, lastDepositIDs, lastDepositCardColors, skipped, clockwise, effect, drawAmount, lastPlayer, finishedPlayers){
    for (var i = 0; i < depotCardIDs.length; i++){
      depositCards([depotCardIDs[i]])
      deck.cardsInStack --
    }

    depositCards(lastDepositIDs)
    for (var j = 0; j < lastDepositIDs.length; j++) {
        lastDeposit[j].cardColor = lastDepositCardColors[j]
    }

    depot.skipped = skipped
    depot.clockwise = clockwise
    depot.effect = effect
//    depot.drawAmount = drawAmount

    depot.lastPlayer = lastPlayer
    depot.finishedPlayers = finishedPlayers
  }
}
