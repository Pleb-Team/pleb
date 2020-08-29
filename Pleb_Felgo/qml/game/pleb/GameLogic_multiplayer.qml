
  // timer decreases the remaining turn time for the active player
//  Timer {
//      id: timerPlayerThinking
//      repeat: true
//      running: !gameOver
//      interval: 1000
//      onTriggered: {
//          remainingTime -= 1
//          // let the AI play for the connected player after 10 seconds
//          if (remainingTime === 0)
//              gameLogic.turnTimedOut()
//          // mark the valid card options for the active player
//          if (multiplayer.myTurn){
//              markValid()
//              scaleHand()
//          }
//          // repaint the timer circle on the playerTag every second
//          for (var i = 0; i < playerTags.children.length; i++)
//              playerTags.children[i].canvas.requestPaint()
//      }
//  }



//  // connect to the FelgoMultiplayer object and handle all messages
//  Connections {
//    // this is important! only handle the messages when we are currently in the game scene
//    // otherwise, we would handle the playerJoined signal when the player is still in matchmaking view!
//    // do not use the visible property here! as visible only gets triggered with the opacity animation in SceneBase
//    target: multiplayer
//    enabled: activeScene === gameScene


//    onAmLeaderChanged: {
//        if (multiplayer.leaderPlayer)
//            console.debug("Current Leader is: " + multiplayer.leaderPlayer.userId)

//        if(multiplayer.amLeader)
//        {
//            console.debug("this player just became the new leader")
//            if(arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())
////                if(!timerPlayerThinking.running && !gameOver)
//            {
//                console.debug("New leader selected, but the timer is currently not running, thus trigger a new turn now")
//                // even when we comment this, the game does not stall 100%, thus it is likely that we would skip a player here. but better to skip a player once and make sure the game is continued than stalling the game. hard to reproduce, as it does not happen every time the leader changes!
//                multiplayer.triggerNextTurn()
//            }
//        }
//    }

//    // Is not called in offline single player mode, only in online multiplayer mode
//    onMessageReceived: {
//      console.debug("onMessageReceived with code", code, "initialized:", initialized)
//      // not relevant for google analytics, causes to exceed the free limit

//      if(!initialized && code !== messageSyncGameState) {
//        console.debug("ERROR: received message before gameState was synced and user is not initialized:", code, message)

//        if (message.receiverPlayerId === multiplayer.localPlayer.userId && !compareGameStateWithLeader(message.playerHands)) {
//          receivedMessageBeforeGameStateInSync = true
//        }
//        return
//      }

////      // sync the game state for existing and newly joined players
////      if (code == messageSyncGameState)
////      {
////        if (!message.receiverPlayerId || message.receiverPlayerId === multiplayer.localPlayer.userId || !compareGameStateWithLeader(message.playerHands)) {
////          console.debug("Sync Game State now")
////          console.debug("Received Message: " + JSON.stringify(message))
////          // NOTE: the activePlayer can be undefined here, when the player makes a late-join! thus add a check in syncDepot() -> depositCard() and handle the case that it is undefined!
////          console.debug("multiplayer.activePlayer when syncing game state:", multiplayer.activePlayer)

////          syncPlayers()
////          initTags()
////          syncDeck(message.deck)
////          depot.syncDepot(message.depot, message.lastDepositIDs, message.lastDepositCardColors, message.skipped, message.effect, message.drawAmount, message.lastPlayerUserID, message.finishedUserIDs)
////          syncHands(message.playerHands)

////          // join a game which is already over
////          gameOver = message.gameOver
////          gameScene.gameOverWindow.visible = gameOver
////          timerPlayerThinking.running = !gameOver

////          console.debug("finished syncGameState, setting initialized to true now")
////          initialized = true

////          // if we before received a message before game state was in sync, do request a new game state from the leader now
////          if(receivedMessageBeforeGameStateInSync) {
////            console.debug("requesting a new game state from server now, as receivedMessageBeforeGameStateInSync was true")
////            multiplayer.sendMessage(messageRequestGameState, multiplayer.localPlayer.userId)
////            receivedMessageBeforeGameStateInSync = false
////          }

////          // request the detailed playerTag info from the other players (highscore, level and badge)
////          // if the message was specifically sent to the local user (for example when he or she joins)
////          if (message.receiverPlayerId){
////            multiplayer.sendMessage(messageRequestPlayerTags, multiplayer.localPlayer.userId)
////          }
////        }
////      }

//      // send a new game state to the requesting user
//      else if (code == messageRequestGameState)
//      {
//        multiplayer.leaderCode(function() {
//          sendGameStateToPlayer(message)
//        })
//      }

//      // move card to hand
//      else if (code == messageMoveCardsHand){
//        // if there is an active player with a different userId, the message is invalid
//        // the message was probably sent after the leader triggered the next turn
//        if (multiplayer.activePlayer && multiplayer.activePlayer.userId != message.userId){
//          multiplayer.leaderCode(function() {
//            sendGameStateToPlayer(message.userId)
//          })
//          return
//        }

//        getCards(message.cards, message.userId)
//      }

//      // move card to depot
//      else if (code == messageMoveCardsDepot)
//      {
//        // if there is an active player with a different userId, the message is invalid
//        // the message was probably sent after the leader triggered the next turn
//        if (multiplayer.activePlayer && multiplayer.activePlayer.userId != message.userId){
//          multiplayer.leaderCode(function() {
//            sendGameStateToPlayer(message.userId)
//          })
//          return
//        }

//        depositCards(message.cardIds, message.userId)
//      }

////      // lasting card effect
////      else if (code == messageSetEffect){
////        // if the message wasn't sent by the leader and
////        // if it wasn't sent by the active player, the message is invalid
////        // the message was probably sent after the leader triggered the next turn
////        if (multiplayer.leaderPlayer.userId != message.userId &&
////            multiplayer.activePlayer && multiplayer.activePlayer.userId != message.userId){
////          return
////        }

////        depot.effect = message.effect
////      }

//      // sync skipped state
//      else if (code == messageSetSkipped)
//      {
//        // if the message wasn't sent by the leader and
//        // if it wasn't sent by the active player, the message is invalid
//        // the message was probably sent after the leader triggered the next turn
//        if (multiplayer.leaderPlayer.userId != message.userId &&
//            multiplayer.activePlayer && multiplayer.activePlayer.userId != message.userId){
//          return
//        }

//        depot.skipped = message.skipped
//      }
////      // sync turn direction
////      else if (code == messageSetReverse){
////        // if the message wasn't sent by the leader and
////        // if it wasn't sent by the active player, the message is invalid
////        // the message was probably sent after the leader triggered the next turn
////        if (multiplayer.leaderPlayer.userId != message.userId &&
////            multiplayer.activePlayer && multiplayer.activePlayer.userId != message.userId){
////          return
////        }

////        depot.clockwise = message.clockwise
////      }


//      // game ends
//      else if (code == messageEndGame)
//      {
//        // if the message wasn't sent by the leader and
//        // if it wasn't a desktop test and
//        // if it wasn't sent by the active player, the message is invalid
//        // the message was probably sent after the leader triggered the next turn
//        if (multiplayer.leaderPlayer.userId != message.userId &&
//            multiplayer.activePlayer && multiplayer.activePlayer.userId != message.userId && !message.test){
//          return
//        }

//        endGame(message.userId)
//      }

//      // chat message
//      else if (code == messagePrintChat)
//      {
//        if (!chat.gConsole.visible){
//          chat.chatButton.buttonImage.source = "../../../assets/img/Chat2.png"
//        }
//        chat.gConsole.printLn(message)
//      }

//      // set highscore and level from other players
//      else if (code == messageSetPlayerInfo)
//      {
//          updateTag(message.userId, message.level, message.highscore, message.rank)
//      }

//      // let the leader trigger a new turn
//      else if (code == messageTriggerTurn)
//      {
//          multiplayer.leaderCode(function()
//          {
//              // the leader only triggers the turn if the requesting user is still the active player
//              if (multiplayer.activePlayer && multiplayer.activePlayer.userId == message){
//                  multiplayer.triggerNextTurn()
//              }

//              // if the requesting user is no longer active, it means that he timed out according to the leader
//              // his last action happened after his turn and is therefore invalid
//              // the leader has to send the user a new game state
//              else {
//                  sendGameStateToPlayer(message)
//              }
//          })
//      }

//      // reset player tag info and send it to other player because it was requested
//      /*
//         Only the local user can access their highscore and rank from the leaderboard.
//         This is the reason why we sync this information with messageSetPlayerInfo messages.
//         Late join users have to request this information again after they initialize the game with a messageSyncGameState message.
//         Another option would be to let the leader send highscore, rank and level of each user via messageSyncGameState.
//      */
//      else if (code == messageRequestPlayerTags){
//        initTags()
//      }
//    }
//  }


//  // sync deck with leader and set up the game
//  function syncDeck(cardInfo)
//  {
//      console.debug("GameLogic::syncDeck()")
//      deck.syncDeck(cardInfo)
//      depot.createDepot()

//      // reset all values at the start of the game
//      gameOver = false
////      timerPlayerThinking.start()
//      scaleHand()
//      markValid()
//      gameScene.gameOverWindow.visible = false
//      gameScene.leaveGameWindow.visible = false
//      gameScene.switchNameWindow.visible = false
//      playerInfoPopup.visible = false
//      chat.reset()
//  }


  // schedule AI to take over after 10 seconds if the connected player is inactive
//  function turnTimedOut()
//  {
//      var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
//      console.debug("[turnTimedOut] called. Active player UserID: " + userId)

//      if (multiplayer.myTurn && !acted)
//      {
//          acted = true
//          scaleHand(1.0)
//      }

//      // clean up our UI
//      timerPlayerThinking.running = false

//      // player timed out, so leader should take over
//      multiplayer.leaderCode(function () {
//          // play an AI bone if this player never played anything (this happens in the case where the player left some time during his turn, and so the early 3 second AI move didn't get scheduled
//          executeAIMove()
//          endTurn()
//      })
//  }


  /*
    Is only called if leader. The leader does not receive the messageSyncGameState message anyway, because messages are not sent to self.
    Used to sync the game in the beginning and for every newly joined player.
    Is called from leader initially when starting a game and when a new player joins.
    If playerId is undefined, it is handled by all players. Use this for initial syncing with players already in the matchmaking room.
  */
  function sendGameStateToPlayer(playerId) {
    console.debug("sendGameStateToPlayer() with playerId", playerId)
    // save all needed game sync data
    var message = {}

    // save all current hands of the other players
    var currentPlayerHands = []
    for (var i = 0; i < playerHands.children.length; i++) {
      // the hand of a single player
      var currentPlayerHand = {}
      // save the userId to assign the information to the correct player
      currentPlayerHand.userId = playerHands.children[i].player.userId
      // save the ids of player's cards
      currentPlayerHand.handIds = []
      for (var j = 0; j < playerHands.children[i].hand.length; j++){
        currentPlayerHand.handIds[j] = playerHands.children[i].hand[j].entityId
      }
      // add the hand information of a single player
      currentPlayerHands.push(currentPlayerHand)
    }
    // save the hand information of all players
    message.playerHands = currentPlayerHands
    // save the deck information to create an identical one
    message.deck = deck.cardInfo

    // sync the depot variables
    message.lastDepositIDs = []
//    message.lastDepositCardColors = []

    for (var l = 0; l < depot.lastDeposit.length; l++) {
        message.lastDepositIDs.push(depot.lastDeposit[l].entityId)
//        message.lastDepositCardColors.push(depot.lastDeposit[l].cardColor)
    }

    message.skipped = depot.skipped
    message.effect = false // depot.effect
    message.drawAmount = 1 // depot.drawAmount
//    message.gameOver = gameOver

    // save all card ids of the current depot
    var depotIDs = []
    for (var k = 0; k < deck.cardDeck.length; k++){
      if (deck.cardDeck[k].state === "depot" && !depot.lastDeposit.includes(deck.cardDeck[k].entityId)){
        depotIDs.push(deck.cardDeck[k].entityId)
      }
    }
    message.depot = depotIDs

    // send the message to the newly joined player
    message.receiverPlayerId = playerId

    message.lastPlayerUserID = depot.lastPlayerUserID
    message.finishedUserIDs = undefined // depot.finishedUserIDs

    console.debug("Send Message: " + JSON.stringify(message))
    multiplayer.sendMessage(messageSyncGameState, message)
  }

  // compares the amount of cards in each player's hand with the leader's game state
  // used to check whether to sync with the leader or not
  function compareGameStateWithLeader(messageHands){
    for (var i = 0; i < playerHands.children.length; i++){
      var currentUserId = playerHands.children[i].player.userId
      for (var j = 0; j < messageHands.length; j++){
        var messageUserId = messageHands[j].userId
        if (currentUserId == messageUserId){
          if (playerHands.children[i].hand.length != messageHands[j].handIds.length){
            // returns false if the amount of cards differentiate
            console.debug("ERROR: game state differentiates from the one of the leader because of the different amount of cards - resync the game of this player!")
            return false
          }
        }
      }
    }
    // returns true if all hands are synced
    return true
  }


//  // the other players position the players at the borders of the game field
//  function syncPlayers()
//  {
//      console.debug("syncPlayers()")
//      // it can happen that the multiplayer.players array is different than the one from the local user
//      // possible reasons are, that a player meanwhile joined the game but this did not get forwarded to the room, or not forwarded to the leader yet

//      // assign the players to the positions at the borders of the game field
//      for (var j = 0; j < multiplayer.players.length; j++) {
//          playerTags.children[j].player = multiplayer.players[j]
//          playerHands.children[j].player = multiplayer.players[j]
//      }
//  }


//  // sync all hands according to the leader
//  function syncHands(messageHands){
//    console.debug("syncHands()")
//    for (var i = 0; i < playerHands.children.length; i++){
//      var currentUserId = playerHands.children[i].player.userId
//      for (var j = 0; j < messageHands.length; j++){
//        var messageUserId = messageHands[j].userId
//        if (currentUserId == messageUserId){
//          playerHands.children[i].syncHand(messageHands[j].handIds)
//        }
//      }
//    }
//  }



// ------------------ from PlayerHand -------------------------------------

//  // change the current hand card array
//  function syncHand(cardIDs) {
//      hand = []
//      for (var i = 0; i < cardIDs.length; i++){
//          var tmpCard = entityManager.getEntityById(cardIDs[i])
//          hand.push(tmpCard)
//          changeParent(tmpCard)
//          deck.numberCardsInStack --
//          if (multiplayer.localPlayer == player){
//              tmpCard.hidden = false
//          }
//          drawSound.play()
//      }
//      // reorganize the hand
//      neatHand()
//  }

// ------------------ from Depot -------------------------------------


//  // sync the depot with the leader
//  function syncDepot(depotCardIDs, lastDepositIDs, lastDepositCardColors, skipped, effect, drawAmount, lastPlayerUserID, finishedUserIDs)
//  {
//    for (var i = 0; i < depotCardIDs.length; i++){
//      depositCards([depotCardIDs[i]])
//      deck.numberCardsInStack --
//    }

//    depositCards(lastDepositIDs)
//    for (var j = 0; j < lastDepositIDs.length; j++) {
//        lastDeposit[j].cardColor = lastDepositCardColors[j]
//    }

//    depot.skipped = skipped
//    depot.lastPlayerUserID = lastPlayerUserID
////    depot.finishedUserIDs = finishedUserIDs
//  }
