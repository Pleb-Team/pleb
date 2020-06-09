import QtQuick 2.12
import Felgo 3.0

Item {
  id: gameLogicPleb

  property bool singlePlayer: false
  property bool initialized: false
  onInitializedChanged: console.debug("GameLogic.initialized changed to:", initialized)

  // the remaining turn time for the active player
  property double remainingTime
  property double elapsedHintTime

  // turn time for the active player, in seconds
  // do not set this too low, otherwise players with higher latency could run into problems as they get skipped by the leader
  property int userInterval: multiplayer.myTurn && !multiplayer.amLeader ? 30 : 30

  // turn time for AI players, in milliseconds
  property int aiTurnTime: 1000

  // restart the game at the end after a few seconds
  property int restartTime: 8000

  // whether the user has already drawn cards this turn or not
  property bool cardsDrawn: false
  property bool acted: false
  property bool gameOver: false

  property int messageSyncGameState: 0
  property int messageRequestGameState: 1
  property int messageMoveCardsHand: 2
  property int messageMoveCardsDepot: 3
  property int messageSetEffect: 4
  property int messageSetSkipped: 5
  property int messageSetReverse: 6
//  property int messageSetDrawAmount: 7
//  property int messagePickColor: 8
//  property int messagePressONU: 9
  property int messageEndGame: 10 // we could replace this custom message with the new endGame() function from multiplayer, custom end game message was sent before this functionality existed
  property int messagePrintChat: 11
  property int messageSetPlayerInfo: 12
  property int messageTriggerTurn: 13
  property int messageRequestPlayerTags: 14

  // gets set to true when a message is received before the game state got synced. in that case, request a new game state
  property bool receivedMessageBeforeGameStateInSync: false

  // bling sound effect when selecting a color for wild or wild4 cards
  SoundEffect {
    volume: 0.5
    id: colorSound
    source: "../../../assets/snd/color.wav"
  }

  // timer decreases the remaining turn time for the active player
  Timer {
      id: timer
      repeat: true
      running: !gameOver
      interval: 1000

      onTriggered: {
          remainingTime -= 1

          // let the AI play for the connected player after 10 seconds
          if (remainingTime === 0) {
              gameLogic.turnTimedOut()
          }

          // mark the valid card options for the active player
          if (multiplayer.myTurn){
              markValid()
              scaleHand()
          }

          // repaint the timer circle on the playerTag every second
          for (var i = 0; i < playerTags.children.length; i++){
              playerTags.children[i].canvas.requestPaint()
          }
      }
  }

  // timer decreases the remaining turn time for the active player
  Timer {
      id: hintTimer
      repeat: true
      running: false
      interval: 1000

      onTriggered:
      {
          elapsedHintTime += 1

          if (elapsedHintTime >= 5)
          {
              var s2
              var s

              if (depot.lastPlayerUserID && depot.lastDeposit)
              {
                  s2 = "Play higher than " + depot.lastDeposit[0].variationType + "!"
              }
              else
              {
                  s2 = "You may start freely and play arbitrary cards. Get rid of something :-)"
              }

              s = "Select some cards and press the screen center to play or pass!"
              gameScene.hintRectangleText.text = s + "\n" + s2
              gameScene.hintRectangle.visible = true
          }
      }
  }


  // AI takes over after a few seconds if the player is not connected
  Timer {
      id: aiTimeOutTimer
      interval: aiTurnTime
      onTriggered:
      {
          gameLogic.executeAIMove()
          endTurn()
      }
  }

  // start a new match after a few seconds
  Timer {
      id: restartGameTimer
      interval: restartTime
      onTriggered:
      {
          restartGameTimer.stop()
          startNewGame()
      }
  }

  // connect to the FelgoMultiplayer object and handle all messages
  Connections {
    // this is important! only handle the messages when we are currently in the game scene
    // otherwise, we would handle the playerJoined signal when the player is still in matchmaking view!
    // do not use the visible property here! as visible only gets triggered with the opacity animation in SceneBase
    target: multiplayer
    enabled: activeScene === gameScene

    onGameStarted: {
      // the gameStarted signal is received by the client as well not only by the leader, otherwise we would not realize when a new game starts
      // otherwise only the leader would trigger a "User.RestartGame" event
      // this is called internally though, thus make it a system event
      if(gameRestarted) {
//        flurry.logEvent("System.GameReStarted", "singlePlayer", multiplayer.singlePlayer)
//        flurry.logTimedEvent("Game.TimeInGameSingleMatch", {"singlePlayer": multiplayer.singlePlayer})
      } else {
//        flurry.logEvent("System.GameStarted", "singlePlayer", multiplayer.singlePlayer)
//        flurry.logTimedEvent("Game.TimeInGameTotal", {"singlePlayer": multiplayer.singlePlayer})
      }
    }

    onAmLeaderChanged: {
      if (multiplayer.leaderPlayer){
        console.debug("Current Leader is: " + multiplayer.leaderPlayer.userId)
      }
      if(multiplayer.amLeader) {
        console.debug("this player just became the new leader")
        if(!timer.running && !gameOver) {
          console.debug("New leader selected, but the timer is currently not running, thus trigger a new turn now")
          // even when we comment this, the game does not stall 100%, thus it is likely that we would skip a player here. but better to skip a player once and make sure the game is continued than stalling the game. hard to reproduce, as it does not happen every time the leader changes!
          triggerNewTurn()
        } else if (!timer.running){
          restartGameTimer.start()
        }
      }
    }

    onMessageReceived: {
      console.debug("onMessageReceived with code", code, "initialized:", initialized)
      // not relevant for google analytics, causes to exceed the free limit

      if(!initialized && code !== messageSyncGameState) {
        console.debug("ERROR: received message before gameState was synced and user is not initialized:", code, message)

        if (message.receiverPlayerId === multiplayer.localPlayer.userId && !compareGameStateWithLeader(message.playerHands)) {
          receivedMessageBeforeGameStateInSync = true
        }
        return
      }

      // sync the game state for existing and newly joined players
      if (code == messageSyncGameState)
      {
        if (!message.receiverPlayerId || message.receiverPlayerId === multiplayer.localPlayer.userId || !compareGameStateWithLeader(message.playerHands)) {
          console.debug("Sync Game State now")
          console.debug("Received Message: " + JSON.stringify(message))
          // NOTE: the activePlayer can be undefined here, when the player makes a late-join! thus add a check in syncDepot() -> depositCard() and handle the case that it is undefined!
          console.debug("multiplayer.activePlayer when syncing game state:", multiplayer.activePlayer)

          syncPlayers()
          initTags()
          syncDeck(message.deck)
          depot.syncDepot(message.depot, message.lastDepositIDs, message.lastDepositCardColors, message.skipped, message.clockwise, message.effect, message.drawAmount, message.lastPlayerUserID, message.finishedPlayers)
          syncHands(message.playerHands)

          // join a game which is already over
          gameOver = message.gameOver
          gameScene.gameOver.visible = gameOver
          timer.running = !gameOver

          console.debug("finished syncGameState, setting initialized to true now")
          initialized = true

          // if we before received a message before game state was in sync, do request a new game state from the leader now
          if(receivedMessageBeforeGameStateInSync) {
            console.debug("requesting a new game state from server now, as receivedMessageBeforeGameStateInSync was true")
            multiplayer.sendMessage(messageRequestGameState, multiplayer.localPlayer.userId)
            receivedMessageBeforeGameStateInSync = false
          }

          // request the detailed playerTag info from the other players (highscore, level and badge)
          // if the message was specifically sent to the local user (for example when he or she joins)
          if (message.receiverPlayerId){
            multiplayer.sendMessage(messageRequestPlayerTags, multiplayer.localPlayer.userId)
          }
        }
      }

      // send a new game state to the requesting user
      else if (code == messageRequestGameState)
      {
        multiplayer.leaderCode(function() {
          sendGameStateToPlayer(message)
        })
      }

      // move card to hand
      else if (code == messageMoveCardsHand){
        // if there is an active player with a different userId, the message is invalid
        // the message was probably sent after the leader triggered the next turn
        if (multiplayer.activePlayer && multiplayer.activePlayer.userId != message.userId){
          multiplayer.leaderCode(function() {
            sendGameStateToPlayer(message.userId)
          })
          return
        }

        getCards(message.cards, message.userId)
      }

      // move card to depot
      else if (code == messageMoveCardsDepot)
      {
        // if there is an active player with a different userId, the message is invalid
        // the message was probably sent after the leader triggered the next turn
        if (multiplayer.activePlayer && multiplayer.activePlayer.userId != message.userId){
          multiplayer.leaderCode(function() {
            sendGameStateToPlayer(message.userId)
          })
          return
        }

        depositCards(message.cardIds, message.userId)
      }

//      // lasting card effect
//      else if (code == messageSetEffect){
//        // if the message wasn't sent by the leader and
//        // if it wasn't sent by the active player, the message is invalid
//        // the message was probably sent after the leader triggered the next turn
//        if (multiplayer.leaderPlayer.userId != message.userId &&
//            multiplayer.activePlayer && multiplayer.activePlayer.userId != message.userId){
//          return
//        }

//        depot.effect = message.effect
//      }

      // sync skipped state
      else if (code == messageSetSkipped)
      {
        // if the message wasn't sent by the leader and
        // if it wasn't sent by the active player, the message is invalid
        // the message was probably sent after the leader triggered the next turn
        if (multiplayer.leaderPlayer.userId != message.userId &&
            multiplayer.activePlayer && multiplayer.activePlayer.userId != message.userId){
          return
        }

        depot.skipped = message.skipped
      }
      // sync turn direction
      else if (code == messageSetReverse){
        // if the message wasn't sent by the leader and
        // if it wasn't sent by the active player, the message is invalid
        // the message was probably sent after the leader triggered the next turn
        if (multiplayer.leaderPlayer.userId != message.userId &&
            multiplayer.activePlayer && multiplayer.activePlayer.userId != message.userId){
          return
        }

        depot.clockwise = message.clockwise
      }


      // game ends
      else if (code == messageEndGame){
        // if the message wasn't sent by the leader and
        // if it wasn't a desktop test and
        // if it wasn't sent by the active player, the message is invalid
        // the message was probably sent after the leader triggered the next turn
        if (multiplayer.leaderPlayer.userId != message.userId &&
            multiplayer.activePlayer && multiplayer.activePlayer.userId != message.userId && !message.test){
          return
        }

        endGame(message.userId)
      }
      // chat message
      else if (code == messagePrintChat){
        if (!chat.gConsole.visible){
          chat.chatButton.buttonImage.source = "../../../assets/img/Chat2.png"
        }
        chat.gConsole.printLn(message)
      }

      // set highscore and level from other players
      else if (code == messageSetPlayerInfo){
        updateTag(message.userId, message.level, message.highscore, message.rank)
      }      

      // let the leader trigger a new turn
      else if (code == messageTriggerTurn){
        multiplayer.leaderCode(function() {
          // the leader only stops the turn early if the requesting user is still the active player
          if (multiplayer.activePlayer && multiplayer.activePlayer.userId == message){
            triggerNewTurn()
          }
          // if the requesting user is no longer active, it means that he timed out according to the leader
          // his last action happened after his turn and is therefore invalid
          // the leader has to send the user a new game state
          else {
            sendGameStateToPlayer(message)
          }
        })
      }

      // reset player tag info and send it to other player because it was requested
      /*
         Only the local user can access their highscore and rank from the leaderboard.
         This is the reason why we sync this information with messageSetPlayerInfo messages.
         Late join users have to request this information again after they initialize the game with a messageSyncGameState message.
         Another option would be to let the leader send highscore, rank and level of each user via messageSyncGameState.
      */
      else if (code == messageRequestPlayerTags){
        initTags()
      }
    }
  }

  // connect to the gameScene and handle all signals
  Connections {
    target: gameScene

    // the player selected a card
    onCardSelected: {
        // if the selected card is from the stack, signal it
        if (entityManager.getEntityById(cardId).state === "stack"){
            // stackSelected()
            // deposit the valid card
        } else if (entityManager.getEntityById(cardId).state === "player"){
            if (multiplayer.myTurn && !depot.skipped && !acted) {

                if (depot.validCard(cardId)){

                    var selectedCard = entityManager.getEntityById(cardId)
                    if (selectedCard.glowImage.visible || selectedCard.glowGroupImage.visible) {
                        selectedCard.glowGroupImage.visible = !selectedCard.glowGroupImage.visible
                        selectedCard.glowImage.visible = !selectedCard.glowGroupImage.visible

                        // convenience for the player to auto-select groups
                        // if there is a last move by another player which has to be beaten
                        if (depot.lastPlayerUserID && depot.lastDeposit.length > 0 && multiplayer.localPlayer.userId !== depot.lastPlayerUserID)
                        {
                            var activeHand = getHand(multiplayer.localPlayer.userId).hand
                            if (selectedCard.glowGroupImage.visible) {
                                var groupSize = 1
                                for (var i = 0; i < activeHand.length; i++) {
                                    if (activeHand[i].entityId !== selectedCard.entityId) {
                                        if (activeHand[i].points === selectedCard.points) {
                                            if (groupSize < depot.lastDeposit.length) {
                                                activeHand[i].glowGroupImage.visible = true
                                                activeHand[i].glowImage.visible = false
                                                groupSize++
                                            } else {
                                                activeHand[i].glowGroupImage.visible = false
                                                activeHand[i].glowImage.visible = false
                                            }
                                        }
                                    }
                                }
                            } else {
                                for (var j = 0; j < activeHand.length; j++) {
                                    if (activeHand[j].entityId !== selectedCard.entityId) {
                                        if (activeHand[j].points === selectedCard.points) {
                                            activeHand[j].glowGroupImage.visible = false
                                        }
                                    }
                                }
                            }
                        }

                        // refresh hand display
                        markValid()
                    }

                }
            }
        } else if (entityManager.getEntityById(cardId).state === "depot") {
            console.debug("DEPOT CARD SELECTED")
            skipOrPlay()
        }
    }

    onDepotSelected: {
        console.debug("DEPOT ITSELF SELECTED")
        skipOrPlay()
    }
  }


  function skipOrPlay() {
      if (multiplayer.myTurn && !depot.skipped && !acted) {

          // get all selected cards into cardID array
          var cardIds = []
          var activeHand = getHand(multiplayer.localPlayer.userId).hand
          for (var i = 0; i < activeHand.length; i++) {
              if (activeHand[i].glowGroupImage.visible) {
                  cardIds.push(activeHand[i].entityId)
              }
          }

          // Move cards to depot and inform Multiplayer
          acted = true
          if (cardIds.length > 0)
          {
              console.debug("Player " + multiplayer.localPlayer.userId + " is playing: " + cardIds)
              depositCards(cardIds, multiplayer.localPlayer.userId)
              multiplayer.sendMessage(messageMoveCardsDepot, {cardIds: cardIds, userId: multiplayer.localPlayer.userId})
          }
          else
          {
              console.debug("Player " + multiplayer.localPlayer.userId + "skipped its turn")
          }

          if (multiplayer.myTurn){
              endTurn()
          }
      }
  }

  // sync deck with leader and set up the game
  function syncDeck(cardInfo){
      console.debug("GameLogic::syncDeck()")
      deck.syncDeck(cardInfo)
      depot.createDepot()

      // reset all values at the start of the game
      gameOver = false
      timer.start()
      scaleHand()
      markValid()
      gameScene.gameOver.visible = false
      gameScene.leaveGameWindow.visible = false
      gameScene.switchName.visible = false
      playerInfoPopup.visible = false
      chat.reset()
  }

  // deposit the selected cards
  function depositCards(cardIds, userId){
      var activeHand = null

      // unmark all highlighted cards
      unmark()

      // scale down the active localPlayer playerHand
      scaleHand(1.0)
      for (var i = 0; i < playerHands.children.length; i++) {
          activeHand = playerHands.children[i]

          // find the playerHand for the active player
          // if the selected card is in the playerHand of the active player
          if (activeHand.inHand(cardIds[0])){
              for (var l = 0; l < cardIds.length; l++) {
                  activeHand.removeFromHand(cardIds[l])
              }

              // deposit the cards
              depot.depositCards(cardIds)

              // uncover the card for disconnected players after chosing the color
              if (!multiplayer.activePlayer || !multiplayer.activePlayer.connected){
                  for (var m = 0; m < depot.lastDeposit.length; m++) {
                      depot.lastDeposit[m].hidden = false
                  }
              }
          }
      }
      return cardIds
  }

  // let AI take over if the player is not skipped
  function executeAIMove() {
    if(!depot.skipped){
        playPlebCustom()
    }
  }


  LegacyPlebCodeBridge {
      id: legacyBridge
  }

  function playPlebCustom() {

      // Compute AI move and play it
      var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
      if (!userId)
          return

      var cardIds = legacyBridge.getMove(userId)
      // Play card animation or skip sound
      if (cardIds.length > 0) {
          multiplayer.sendMessage(messageMoveCardsDepot, {cardIds: cardIds, userId: userId})
          depositCards(cardIds, userId)
      }
  }

  // check whether a user with a specific id has valid cards or not
  function hasValidCards(user){
    var playerHand = getHand(user.userId)
    var valids = playerHand.getValidCards()
    return valids.length > 0
  }


  // start the turn for the active player
  function turnStarted(playerId) {

      console.debug("#######################################################################################################################################")
      console.debug("turnStarted() called")

      if(!multiplayer.activePlayer) {
          console.debug("ERROR: activePlayer not valid in turnStarted!")
          return
      }

      console.debug("playerId: " + playerId + ", multiplayer.activePlayer.userId: " + multiplayer.activePlayer.userId)
      console.debug("Last deposit: " + depot.lastDeposit + " by player " + depot.lastPlayerUserID)
//      console.debug("players hand: " + (getHand(multiplayer.activePlayer.userId).hand))

      // Player can play a second time in a row, meaning all other players have passed.
      // Then we have to make sure that the depot is cleared
      if (depot.lastPlayerUserID === multiplayer.activePlayer.userId)
      {
          depot.lastPlayerUserID = null
      }

      // give the connected player <xxx> seconds until the AI takes over
      remainingTime = userInterval
      timer.stop()
      if (!gameOver)
      {
          timer.start()
          scaleHand()
          markValid()
      }

      gameScene.hintRectangle.visible = false;
      elapsedHintTime = 0;
      hintTimer.start();


      // let the AI compute a move recommendation (it is not being played here)
      legacyBridge.getMove(multiplayer.activePlayer.userId);
      var s = legacyBridge.arschlochGameLogic.getPlayerCardsText()


      // the player didn't act yet
      acted = false
      cardsDrawn = false
      unmark()
      scaleHand(1.0)

      // All player except 1 have already finished
      if (depot.finishedPlayers.length === playerHands.children.length - 1) {
          plebFinish(getHand(multiplayer.activePlayer.userId))
          endTurn()
      }

      // This player has already finished (but is still called?)
      if (depot.finishedPlayers.includes(multiplayer.activePlayer.userId))
      {
          endTurn()
      }
      else
      {
          var canPlay = hasValidCards(multiplayer.activePlayer)
          if (canPlay)
          {
              depot.skipTurn(false)
          }
          else
          {
              // skip if the player has no valid cards
              depot.skipTurn(true)
          }
      }

      // zoom in on the hand of the active local player
      if (!depot.skipped && multiplayer.myTurn)
          scaleHand(1.6)


      // mark the valid card options
      markValid()

      elapsedHintTime = 0;
      hintTimer.start()

      // repaint the timer circle
      for (var i = 0; i < playerTags.children.length; i++){
          playerTags.children[i].canvas.requestPaint()
      }

      // schedule AI to take over in 3 seconds in case the player is gone
      multiplayer.leaderCode(function() {
          if (!multiplayer.activePlayer || !multiplayer.activePlayer.connected) {
              aiTimeOutTimer.start()
          }
      })
  }


  function plebFinish(plebHand)
  {
      // let the new Pleb finish its game by playing all its remaining cards
      var lastcards = []
      for (var l = 0; l < plebHand.hand.length; l++)
      {
          lastcards.push(plebHand.hand[l].entityId)
      }

      multiplayer.sendMessage(messageMoveCardsDepot, {cardIds: lastcards, userId: plebHand.player.userId})
      depositCards(lastcards, plebHand.player.userId)
  }


  // schedule AI to take over after 10 seconds if the connected player is inactive
  function turnTimedOut(){
      var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
      console.debug("[turnTimedOut] called. Active player UserID: " + userId)

      if (multiplayer.myTurn && !acted)
      {
          acted = true
          scaleHand(1.0)
      }

      // clean up our UI
      timer.running = false

      // player timed out, so leader should take over
      multiplayer.leaderCode(function () {
          // play an AI bone if this player never played anything (this happens in the case where the player left some time during his turn, and so the early 3 second AI move didn't get scheduled
          executeAIMove()
          endTurn()
      })
  }

  function createGame(){
      multiplayer.createGame()
  }

  // stop the timers and reset the deck at the end of the game
  function leaveGame()
  {
      console.debug("GameLogic::leaveGame() start")

      aiTimeOutTimer.stop()
      hintTimer.stop()
      restartGameTimer.stop()
      timer.running = false
      depot.effectTimer.stop()
      deck.reset()
      chat.gConsole.clear()
      multiplayer.leaveGame()
      scaleHand(1.0)
      initialized = false
      receivedMessageBeforeGameStateInSync = false

      console.debug("GameLogic::leaveGame() finish")
  }

  function joinGame(room){
    multiplayer.joinGame(room)
  }

  // initialize the game
  // is called from GameOverWindow when the leader restarts the game, and from GameScene when it got visible from GameScene.onVisibleChanged
  function initGame(calledFromGameOverScreen)
  {
      console.debug("initGame() called: " + calledFromGameOverScreen)
      if (calledFromGameOverScreen) {
          console.debug("************************************ NEW GAME ***************************************")
      }

      if(!multiplayer.initialized && !multiplayer.singlePlayer){
          createGame()
      }

      console.debug("multiplayer.localPlayer " + multiplayer.localPlayer)
      //console.debug("multiplayer.localPlayer.userId " + multiplayer.localPlayer.userId)
      console.debug("multiplayer.players.length " + multiplayer.players.length)
      for (var i = 0; i < multiplayer.players.length; i++){
          console.debug("multiplayer.players[" + i +"].userId " + multiplayer.players[i].userId)
      }
      console.debug("multiplayer.myTurn " + multiplayer.myTurn)

      var lastGameOutcome = depot.finishedPlayers

      // reset all values at the start of the game
      gameOver = false
      timer.start()
      scaleHand()
      markValid()
      gameScene.gameOver.visible = false
      gameScene.leaveGameWindow.visible = false
      gameScene.switchName.visible = false
      playerInfoPopup.visible = false
      chat.reset()
      depot.reset()

      // initialize the players, the deck and the individual hands
      initPlayers()
      initDeck()
      initHands()

      // reset all tags and set tag data of the leader
      initTags()

      // set the game state for all players
      multiplayer.leaderCode(function ()
      {
          // NOTE: only the leader must set this to true! the clients only get initialized after the initial syncing game state message is received
          initialized = true

          // if we call this here, gameStarted is called twice. it is not needed to call, because it is already called when the room is setup
          // thus we must not call this! forceStartGame() is called from the MatchMakingView, not from the GameScene!
          if(calledFromGameOverScreen) {
              // by calling restartGame, we emit a gameStarted call on the leader and the clients
              multiplayer.restartGame()
          }

          // we want to send the state to all players in this case, thus set the playerId to undefined and this case is handled in onMessageReceived so all players handle the game state syncing if playerId is undefined
          // send game state after forceStartGame, otherwise the message will not be received by the initial players!
          if (!multiplayer.singlePlayer) {
              sendGameStateToPlayer(undefined)
          }

          // only the leader needs to call this
          // lets always the leader take the first turn on the first game
          if (lastGameOutcome.length < 1) {
              gameLogic.triggerNewTurn(multiplayer.leaderPlayer.userId)
          } else {
              gameLogic.triggerNewTurn(lastGameOutcome[lastGameOutcome.length - 1])
          }
      })

      // start by scaling the playerHand of the active localPlayer
      scaleHand()

      console.debug("InitGame finished!")
  }


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
    message.lastDepositCardColors = []

    for (var l = 0; l < depot.lastDeposit.length; l++) {
        message.lastDepositIDs.push(depot.lastDeposit[l].entityId)
        message.lastDepositCardColors.push(depot.lastDeposit[l].cardColor)
    }

    message.skipped = depot.skipped
    message.clockwise = depot.clockwise
    message.effect = false // depot.effect
    message.drawAmount = 1 // depot.drawAmount
    message.gameOver = gameOver

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
    message.finishedPlayers = depot.finishedPlayers

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

  // the leader initializes all players and positions them at the borders of the game
  function initPlayers(){
    multiplayer.leaderCode(function () {
      console.debug("Leader Init Players")
      var clientPlayers = multiplayer.players
      var playerInfo = []
      for (var i = 0; i < clientPlayers.length; i++) {
        playerTags.children[i].player = clientPlayers[i]
        playerHands.children[i].player = clientPlayers[i]
        playerInfo[i] = clientPlayers[i].userId
      }
    })
  }

  // find player by userId
  function getPlayer(userId){
    for (var i = 0; i < multiplayer.players.length; i++){
      console.debug("All UserIDs: " + multiplayer.players[i].userId + ", Looking for: " + userId)
      if (multiplayer.players[i].userId == userId){
        return multiplayer.players[i]
      }
    }
    console.debug("ERROR: could not find player with id", userId, "in the multiplayer.players list!")
    return undefined
  }

  // find hand by userId
  function getHand(userId){
    for (var i = 0; i < playerHands.children.length; i++){
      if (playerHands.children[i].player.userId == userId){
        return playerHands.children[i]
      }
    }
    console.debug("ERROR: could not find player with id", userId, "in the multiplayer.players list!")
    return undefined
  }

  // update tag by player userId
  function updateTag(userId, level, highscore, rank){
    for (var i = 0; i < playerTags.children.length; i++){
      if (playerHands.children[i].player.userId == userId){
        playerTags.children[i].level = level
        playerTags.children[i].highscore = highscore
        playerTags.children[i].rank = rank
      }
    }
  }

  // the other players position the players at the borders of the game field
  function syncPlayers(){
    console.debug("syncPlayers()")
    // it can happen that the multiplayer.players array is different than the one from the local user
    // possible reasons are, that a player meanwhile joined the game but this did not get forwarded to the room, or not forwarded to the leader yet

    // assign the players to the positions at the borders of the game field
    for (var j = 0; j < multiplayer.players.length; j++) {
      playerTags.children[j].player = multiplayer.players[j]
      playerHands.children[j].player = multiplayer.players[j]
    }
  }

  // the leader creates the deck and depot
  function initDeck(){
    multiplayer.leaderCode(function () {
      deck.createDeck()
      depot.createDepot()
    })
  }

  // the leader hands out the cards to the other players
  function initHands(){
    multiplayer.leaderCode(function () {
      for (var i = 0; i < playerHands.children.length; i++) {
        // start the hand for each player
        playerHands.children[i].startHand()
      }
    })
  }

  // sync all hands according to the leader
  function syncHands(messageHands){
    console.debug("syncHands()")
    for (var i = 0; i < playerHands.children.length; i++){
      var currentUserId = playerHands.children[i].player.userId
      for (var j = 0; j < messageHands.length; j++){
        var messageUserId = messageHands[j].userId
        if (currentUserId == messageUserId){
          playerHands.children[i].syncHand(messageHands[j].handIds)
        }
      }
    }
  }

  // reset all tags and init the tag for the local player
  function initTags(){
    console.debug("initTags()")
    for (var i = 0; i < playerTags.children.length; i++){
      playerTags.children[i].initTag()
      if (playerHands.children[i].player && playerHands.children[i].player.userId == multiplayer.localPlayer.userId){
        playerTags.children[i].getPlayerData(true)
      }
    }
  }

  // draw the specified amount of cards
  function getCards(cards, userId){
    cardsDrawn = true

    // find the playerHand of the active player and pick up cards
    for (var i = 0; i < playerHands.children.length; i++) {
      if (playerHands.children[i].player.userId === userId){
        playerHands.children[i].pickUpCards(cards)
      }
    }
  }


  // find the playerHand of the active player and mark all valid card options
  function markValid(){
      if (multiplayer.myTurn && !acted ){
          for (var i = 0; i < playerHands.children.length; i++) {
              if (playerHands.children[i].player === multiplayer.activePlayer){
                  playerHands.children[i].markValid()
              }
          }
      } else {
          unmark()
      }
  }

  // unmark all valid card options of all players
  function unmark(){
      for (var i = 0; i < playerHands.children.length; i++) {
          playerHands.children[i].unmark()
      }
      // unmark the highlighted deck card
      deck.unmark()
  }

  // scale the playerHand of the active localPlayer
  function scaleHand(scale){
    if (!scale) scale = multiplayer.myTurn && !acted && !depot.skipped ? 1.6 : 1.0
    for (var i = 0; i < playerHands.children.length; i++){
      if (playerHands.children[i].player && playerHands.children[i].player.userId == multiplayer.localPlayer.userId){
        playerHands.children[i].scaleHand(scale)
      }
    }
  }


  // end the turn of the active player
  function endTurn(){
      console.debug("ENDING TURN <===")

      // unmark all highlighted valid card options
      unmark()

      // scale down the hand of the active local player
      scaleHand(1.0)

      var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0

      // check if the active player has just won the game and end it in that case
      for (var i = 0; i < playerHands.children.length; i++)
      {
          if (playerHands.children[i].player === multiplayer.activePlayer)
          {
              if (!depot.finishedPlayers.includes(userId))
              {
                  if (playerHands.children[i].checkWin())
                  {
                      console.debug("=================================================================================> " + multiplayer.activePlayer + " HAS FINISHED!!!")
                      depot.finishedPlayers.push(userId)
                  }
              }
          }
      }

      if (depot.finishedPlayers.length >= playerHands.children.length) { // TODO FINISH how to finish game; opting for letting all players drop their cards, even the Pleb // - 1) {
          //        for (var j = 0; depot.finishedPlayers.length < playerHands.children.length && j < playerHands.children.length; j++) {
          //            if (!depot.finishedPlayers.includes(playerHands.children[j].player.userId)) {
          //                depot.finishedPlayers.push(playerHands.children[j].player.userId)
          //            }
          //        }
          console.debug("ENDING GAME <=======================================================================================")
          endGame()
          multiplayer.sendMessage(messageEndGame, {userId: userId})
      }

      // continue if the game is still going
      if (!gameOver){
          console.debug("trigger new turn in endTurn, clockwise: " + depot.clockwise)
          if (multiplayer.amLeader){
              console.debug("Still Leader?")
              triggerNewTurn()
          } else {
              // send message to leader to trigger new turn
              multiplayer.sendMessage(messageTriggerTurn, userId)
          }
      }
  }

  function triggerNewTurn(userId){
      if (depot.clockwise){
          multiplayer.triggerNextTurn(userId)
      } else {
          multiplayer.triggerPreviousTurn(userId)
      }
  }

  // calculate the points for each player
  function calculatePoints(userId){
    // calculate the winner's score by adding all card values
    var score = 0
    for (var i = 0; i < playerHands.children.length; i++) {
      score += playerHands.children[i].points()
    }
    if (multiplayer.singlePlayer){
      score = Math.round(score/3)
    }

    // set the name of the winner
    if (userId == undefined) {
      // calculate the ranking of the other three players
      var tmpPlayers = [playerHands.children[0], playerHands.children[1], playerHands.children[2], playerHands.children[3]]
      var points = [score, 15, 10, 5]
      tmpPlayers.sort(function(a, b) {
        return a.hand.length - b.hand.length
      })

      var winnerHand = getHand(tmpPlayers[0].player.userId)
      if (winnerHand) gameScene.gameOver.winner = winnerHand.player

      for (var i = 0; i < tmpPlayers.length; i++){
        // get player by userId
        var tmpPlayer = getHand(tmpPlayers[i].player.userId)
        if (tmpPlayer) tmpPlayer.score = points[i]

        // check if two players had the same amount of cards
        if (i > 0){
          var prevPlayer = getHand(tmpPlayers[i-1].player.userId)
          if (prevPlayer && prevPlayer.hand.length == tmpPlayer.hand.length){
            tmpPlayer.score = prevPlayer.score
          }
        }
      }
    } else {
      // specific calculation for the "close round" desktop option
      // make the player who pressed the button the winner and simply order the other 3 players
      var tmpPlayers2 = []
      for (i = 0; i < playerHands.children.length; i++){
        if (playerHands.children[i].player.userId != userId){
          tmpPlayers2[tmpPlayers2.length] = playerHands.children[i]
        }
      }
      var points2 = [15, 10, 5]
      tmpPlayers2.sort(function(a, b) {
        return a.hand.length - b.hand.length
      })

      var winnerHand2 = getHand(userId)
      if (winnerHand2) gameScene.gameOver.winner = winnerHand2.player
      var winner = getHand(userId)
      if (winner) winner.score = score

      for (var j = 0; j < tmpPlayers2.length; j++){
        // get player by userId
        var tmpPlayer2 = getHand(tmpPlayers2[j].player.userId)
        if (tmpPlayer2) tmpPlayer2.score = points2[j]

        // check if two players had the same amount of cards
        if (j > 0){
          var prevPlayer2 = getHand(tmpPlayers2[j-1].player.userId)
          if (prevPlayer2 && prevPlayer2.hand.length == tmpPlayer2.hand.length){
            tmpPlayer2.score = prevPlayer2.score
          }
        }
      }
    }
  }

  // end the game and report the scores
  /*
    This is called by both the leader and the clients.
    Each user calculates and displays the points of all players. The local user reports his score and updates his level.
    If it differs from the previous level, the local user levelled up. In this case we display a message with the new level on the game over window.
    If he doesn't have a nickname, we ask him to chose one. Then we reset all timers and values.
    */
  function endGame(userId){
      console.debug("ENDGAME called: " + userId)
    // calculate the points of each player and set the name of the winner
    calculatePoints(userId)

    // show the gameOver message with the winner and score
    gameScene.gameOver.visible = true

    // add points to MultiplayerUser score of the winner
    var currentHand = getHand(multiplayer.localPlayer.userId)
    if (currentHand) gameNetwork.reportRelativeScore(currentHand.score)

    var currentTag
    for (var i = 0; i < playerTags.children.length; i++){
      if (playerTags.children[i].player.userId == multiplayer.localPlayer.userId){
        currentTag = playerTags.children[i]
      }
    }

    // calculate level with new points and check if there was a level up
    var oldLevel = currentTag.level
    currentTag.getPlayerData(false)
    if (oldLevel != currentTag.level){
      gameScene.gameOver.level = currentTag.level
      gameScene.gameOver.levelText.visible = true
    } else {
      gameScene.gameOver.levelText.visible = false
    }

    // show window with text input to switch username
    if (!multiplayer.singlePlayer && !gameNetwork.user.hasCustomNickName()) {
      gameScene.switchName.visible = true
    }

    // stop all timers and end the game
    scaleHand(1.0)
    gameOver = true
    hintTimer.stop()
    aiTimeOutTimer.stop()
    timer.running = false
    depot.effectTimer.stop()

    multiplayer.leaderCode(function () {
      restartGameTimer.start()
    })

//    ga.logEvent("System", "End Game", "singlePlayer", multiplayer.singlePlayer)
//    flurry.logEvent("System.EndGame", "singlePlayer", multiplayer.singlePlayer)
//    flurry.endTimedEvent("Game.TimeInGameSingleMatch", {"singlePlayer": multiplayer.singlePlayer})
  }

  function startNewGame(){
    restartGameTimer.stop()
    // the true causes a gameStarted to be emitted
    gameLogic.initGame(true)
  }
}
