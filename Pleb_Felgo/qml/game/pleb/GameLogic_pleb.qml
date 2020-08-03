import QtQuick 2.12
import Felgo 3.0
import "../../common"
import io.qt.examples.backend 1.0

Item {
  id: gameLogicPleb

  property bool singlePlayer: false
  property bool initialized: false
  onInitializedChanged: console.debug("GameLogic.initialized changed to:", initialized)

  property alias arschlochGameLogic: arschlochGameLogic

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

  // Redundant to !multiplayer.myTurn, however the multiplayer.myTurn information is updated delayed due to network,
  // so we must store the information twice that the player just acted
  property bool acted: false
//  property bool gameOver: false

  property int messageSyncGameState: 0
  property int messageRequestGameState: 1
  property int messageMoveCardsHand: 2
  property int messageMoveCardsDepot: 3
  property int messageSetEffect: 4
  property int messageSetSkipped: 5
//  property int messageSetReverse: 6
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


  LegacyPlebCodeBridge {
      id: legacyPlebCodeBridge
  }

  BackEnd  {
      id: arschlochGameLogic
  }


  // bling sound effect when selecting a color for wild or wild4 cards
  SoundEffect {
    volume: 0.5
    id: colorSound
    source: "../../../assets/snd/color.wav"
  }

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

  // timer decreases the remaining turn time for the active player
  Timer {
      id: hintTimer
      repeat: true
      running: false
      interval: 1000

      onTriggered:
      {
          var nPlayerIndexLegacy = getHandIndex(multiplayer.localPlayer.userId)
          var nPlayerIndexCardExchange = arschlochGameLogic.getCardExchangePartner(nPlayerIndexLegacy)
          var nCardExchangeNumber = arschlochGameLogic.getCardExchangeNumber(nPlayerIndexLegacy)

          elapsedHintTime += 1

          if (elapsedHintTime >= 5)
          {
              var s2 = ""
              var s = ""

              if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandKartenTauschen())
              {
                  if (nCardExchangeNumber > 0)
                        s = "You lost! Give your " + nCardExchangeNumber + " highest cards to player " + nPlayerIndexCardExchange
                  else if (nCardExchangeNumber < 0)
                      s = "You won! Give your " + nCardExchangeNumber + " lowest or other arbitrary cards to player " + nPlayerIndexCardExchange
              }
              else if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())
              {
                  if (depot.lastPlayerUserID && depot.lastDeposit)
                      s2 = "Beat your opponent and play higher than " + depot.lastDeposit[0].variationType + "!"
                  else
                      s2 = "You may start freely and play arbitrary cards. Get rid of something :-)"

                  if (depot.lastPlayerUserID && depot.lastDeposit.length === 1)
                      s = "Select 1 card and press the screen center to play, or simply press screen center to pass."
                  else if (depot.lastPlayerUserID && depot.lastDeposit.length > 1)
                      s = "Select " + depot.lastDeposit.length + " cards and press the screen center to play, or simply press screen center to pass."
                  else
                      s = "Select arbitrary cards of the same value and press the screen center to play."
              }

              gameScene.hintRectangleText.text = s2 + "\n\n" + s
              gameScene.hintRectangle.visible = true
          }
      }
  }


  // AI will play after short time
  Timer {
      id: aiThinkingTimer
      interval: aiTurnTime
      onTriggered:
      {
          var nPlayerIndexLegacy = -1;
          var userId = 0;
          var cardIds = []

          if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandKartenTauschen())
          {
              // Search for AI player which still has to exchange cards
              for (var m = 0; m < playerHands.children.length; m++)
              {
                  if (  (playerHands.children[m].player !== multiplayer.localPlayer)
                     && (arschlochGameLogic.getCardExchangeNumber(m) !== 0) )
                  {
                      nPlayerIndexLegacy = m
                      userId = playerHands.children[m].player.userId
                      break
                  }
              }

              if (nPlayerIndexLegacy === -1)
                  return

              cardIds = legacyPlebCodeBridge.calcMoveCardExchange(userId, nPlayerIndexLegacy)
              console.assert(cardIds.length === 1)

              var nPlayerIndexCardExchange = arschlochGameLogic.getCardExchangePartner(nPlayerIndexLegacy)
              var exchangePartnerHand = playerHands.children[nPlayerIndexCardExchange]

              // First deposit the cards to the depot for 1 ms such that the owner is changed correctly
              depositCards(cardIds, userId)

              // ... then hand them over to the exchange partner. Note that we need an array here
              var cards = []
              cards.push(entityManager.getEntityById(cardIds[0]))
              exchangePartnerHand.pickUpCards(cards)

              // Sync legacy gamestate
              arschlochGameLogic.giveCardToExchangePartner(nPlayerIndexLegacy, nPlayerIndexCardExchange, cards[0].points - 7)

              // Card exchange has just finished
              if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())
                  multiplayer.triggerNextTurn(playerHands.children[arschlochGameLogic.getActualPlayerID()].player.userId)
          }

          else if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())
          {
              // Compute AI move and play it
              userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
              if (!depot.skipped && userId)
              {
                  nPlayerIndexLegacy = getHandIndex(userId)
                  cardIds = legacyPlebCodeBridge.calcMove(userId, nPlayerIndexLegacy)

                  // Play card animation or skip sound
                  if (cardIds.length > 0)
                  {
                      multiplayer.sendMessage(messageMoveCardsDepot, {cardIds: cardIds, userId: userId})
                      depositCards(cardIds, userId)
                  }
              }

              endTurn()
          }
      }
  }


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

  // connect to the gameScene and handle all signals
  Connections {
      target: gameScene

      // the player selected a card
      onCardSelected:
      {
          // if the selected card is from the stack, signal it
          if (entityManager.getEntityById(cardId).state === "stack")
          {
              // stackSelected()
              // deposit the valid card
          }
          else if (entityManager.getEntityById(cardId).state === "player")
          {
              var selectedCard = entityManager.getEntityById(cardId)
              if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandKartenTauschen())
              {
                  // Todo: Regeln fürs selektieren einer Karte
                  // Aktuell kann man sogar die Karten der Gegner selektieren
//                  if (selectedCard.glowImage.visible || selectedCard.selected)
//                  {
                      selectedCard.selected = !selectedCard.selected
//                  }

                  // refresh hand display
//                  markValid()

                  return
              }



              if (multiplayer.myTurn && !depot.skipped && !acted)
              {
                  if (!depot.validCard(cardId))
                      return


                  if (selectedCard.glowImage.visible || selectedCard.selected)
                  {
                      selectedCard.selected = !selectedCard.selected
                      selectedCard.glowImage.visible = !selectedCard.selected

                      // convenience for the player to auto-select groups
                      // if there is a last move by another player which has to be beaten
                      if (depot.lastPlayerUserID && depot.lastDeposit.length > 0 && multiplayer.localPlayer.userId !== depot.lastPlayerUserID)
                      {
                          var activeHand = getHand(multiplayer.localPlayer.userId).hand
                          if (selectedCard.selected) {
                              var groupSize = 1
                              for (var i = 0; i < activeHand.length; i++) {
                                  if (activeHand[i].entityId !== selectedCard.entityId) {
                                      if (activeHand[i].points === selectedCard.points) {
                                          if (groupSize < depot.lastDeposit.length) {
                                              activeHand[i].selected = true
                                              activeHand[i].glowImage.visible = false
                                              groupSize++
                                          } else {
                                              activeHand[i].selected = false
                                              activeHand[i].glowImage.visible = false
                                          }
                                      }
                                  }
                              }
                          }
                          else
                          {
                              // Unselect other cards of same value
                              for (var j = 0; j < activeHand.length; j++) {
                                  if (    (activeHand[j].entityId !== selectedCard.entityId)
                                      &&  (activeHand[j].points === selectedCard.points) )
                                  {
                                      activeHand[j].selected = false
                                  }
                              }
                          }
                      }

                      // refresh hand display
                      markValid()
                  }


              }
          }
          else if (entityManager.getEntityById(cardId).state === "depot")
          {
              console.debug("DEPOT CARD SELECTED")
              skipOrPlay()
          }
      }

      onDepotSelected:
      {
          console.debug("DEPOT ITSELF SELECTED")
          skipOrPlay()
      }
  }


  function skipOrPlay()
  {
      var activeHand = getHand(multiplayer.localPlayer.userId)
      var nPlayerIndexLegacy = getHandIndex(multiplayer.localPlayer.userId)
      var cardIds = activeHand.getSelectedCardIDs()


      if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandKartenTauschen())
      {

          if (  (arschlochGameLogic.getCardExchangeNumber(nPlayerIndexLegacy) === 0)
            ||  (arschlochGameLogic.getCardExchangePartner(nPlayerIndexLegacy) < 0) )
          {
              console.debug("Card exchange is already finished or no exchange partner defined for player index:" + nPlayerIndexLegacy)
              return
          }

          var nPlayerIndexCardExchange = arschlochGameLogic.getCardExchangePartner(nPlayerIndexLegacy)
          var selectedCards = activeHand.getSelectedCards()
          var exchangePartnerHand = playerHands.children[nPlayerIndexCardExchange]

          // First deposit the cards to the depot for 1 ms such that the owner is changed correctly
          depositCards(cardIds, multiplayer.localPlayer.userId)

          // ... then hand them over to the exchange partner
          exchangePartnerHand.pickUpCards(selectedCards)

          // Sync legacy gamestate
          for (var n = 0; n < selectedCards.length; n++)
              arschlochGameLogic.giveCardToExchangePartner(nPlayerIndexLegacy, nPlayerIndexCardExchange, selectedCards[n].points - 7)

          // Card exchange has just finished
          if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())
              multiplayer.triggerNextTurn(playerHands.children[arschlochGameLogic.getActualPlayerID()].player.userId)
      }

      else if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())
      {
          // Make sure this player still has to play
          if (!multiplayer.myTurn || depot.skipped || acted)
              return

          // Move cards to depot and inform Multiplayer
          acted = true
          if (cardIds.length > 0)
          {
              console.debug("Player " + multiplayer.localPlayer.userId + " is playing: " + cardIds)
              depositCards(cardIds, multiplayer.localPlayer.userId)
              multiplayer.sendMessage(messageMoveCardsDepot, {cardIds: cardIds, userId: multiplayer.localPlayer.userId})
          }
          else
              console.debug("Player " + multiplayer.localPlayer.userId + "skipped its turn")


          endTurn()
      }
  }

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

  // deposit the selected cards from player hand to depot
  function depositCards(cardIds, userId)
  {
      var activeHand = getHand(userId)

      // unmark all highlighted cards. Good point here, as the cards flying to the depot shall not be marked
      unmark()

      // find the playerHand for the active player
      // if the selected card is in the playerHand of the active player
      if (activeHand.inHand(cardIds[0]))
      {
          for (var l = 0; l < cardIds.length; l++)
              activeHand.removeFromHand(cardIds[l])

          // deposit the cards
          depot.depositCards(cardIds)
      }
  }


  // check whether a user with a specific id has valid cards or not
  function hasValidCards(user){
    var playerHand = getHand(user.userId)
    var valids = playerHand.getValidCards()
    return valids.length > 0
  }


  // start the turn for the active player
  function turnStarted(playerId)
  {
      console.debug("[turnStarted]")

      if(!multiplayer.activePlayer) {
          console.debug("ERROR: activePlayer not valid in turnStarted!")
          return
      }

      var nPlayerIndexLegacy = getHandIndex(multiplayer.activePlayer.userId)


      console.debug("[turnStarted] PlayerId: " + playerId + ", multiplayer.activePlayer.userId: " + multiplayer.activePlayer.userId)
      console.debug("[turnStarted] Last deposit: " + depot.lastDeposit + " by player " + depot.lastPlayerUserID)

      // Player can play a second time in a row, meaning all other players have passed.
      // Then we have to make sure that the depot is cleared
      if (depot.lastPlayerUserID === multiplayer.activePlayer.userId)
          depot.lastPlayerUserID = null

      // give the connected player <xxx> seconds until the AI takes over
//      remainingTime = userInterval
//      timerPlayerThinking.stop()
//      if (!gameOver)
//      {
////          timerPlayerThinking.start()
//          scaleHand()
//          markValid()
//      }


      // the player didn't act yet
      acted = false

//      scaleHand(1.0)



      // This player has already finished (but is still called?)
      if (arschlochGameLogic.getPlayerGameResult(nPlayerIndexLegacy) !== Constants.nGameResultUndefined)
          endTurn()

      // This player just became Pleb, as all others finished before him
      else if (arschlochGameLogic.getNumberPlayers() <= 1)
      {
          plebFinish(getHand(multiplayer.activePlayer.userId))
          endTurn()
      }

      else
      {
          var canPlay = hasValidCards(multiplayer.activePlayer)
          if (canPlay)
          {
              depot.skipTurn(false)

              unmark()
              scaleHand()
              markValid()
          }
          else
          {
              // skip if the player has no valid cards
              depot.skipTurn(true)
          }
      }

      // zoom in on the hand of the active local player
//      if (!depot.skipped && multiplayer.myTurn)
//          scaleHand(1.6)


      // mark the valid card options
//      markValid()

      // Reset hint
      gameScene.hintRectangle.visible = false;
      elapsedHintTime = 0;
      hintTimer.start()

      // repaint the timer circle
//      for (var i = 0; i < playerTags.children.length; i++){
//          playerTags.children[i].canvas.requestPaint()
//      }

      // schedule AI to take over in 3 seconds for AI players / not connected initPlayers()
      multiplayer.leaderCode(function() {
          if (!multiplayer.activePlayer || !multiplayer.activePlayer.connected) {
              aiThinkingTimer.start()
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


  // stop the timers and reset the deck at the end of the game
  function leaveGame()
  {
      console.debug("GameLogic::leaveGame() start")

      aiThinkingTimer.stop()
      hintTimer.stop()
//      timerPlayerThinking.running = false
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
      if (calledFromGameOverScreen)
          console.debug("************************************ NEW GAME ***************************************")

      if(!multiplayer.initialized && !multiplayer.singlePlayer)
          multiplayer.createGame()


      console.debug("multiplayer.localPlayer: " + multiplayer.localPlayer)
      console.debug("multiplayer.localPlayer.userId: " + multiplayer.localPlayer.userId)
      console.debug("multiplayer.players.length " + multiplayer.players.length)
      for (var i = 0; i < multiplayer.players.length; i++){
          console.debug("multiplayer.players[" + i +"].userId " + multiplayer.players[i].userId)
      }
      console.debug("multiplayer.myTurn " + multiplayer.myTurn)

      // reset all values at the start of the game
//      gameOver = false
//      timerPlayerThinking.start()
      gameScene.gameOverWindow.visible = false
      gameScene.leaveGameWindow.visible = false
      gameScene.switchNameWindow.visible = false
      playerInfoPopup.visible = false
      chat.reset()
      depot.reset()

      // Check who was Pleb, BEFORE we reset the gamestate and thus the game result
//      var nPlayerIndexArschloch = undefined
//      for (var n = 0; n < arschlochGameLogic.getNumberPlayersMax(); n++)
//          if (arschlochGameLogic.getPlayerGameResult(n) === 0)
//              nPlayerIndexArschloch = n

      // computes
      // - Card exchange numbers + Partners
      // - Game state (Exchange cards or Play)
      // - First player to play
      arschlochGameLogic.resetGameState()
      arschlochGameLogic.checkCardExchangePartners()
      arschlochGameLogic.resetGameResult()

      // initialize the players, the deck and the individual hands
      initPlayers()
      initDeck()
      initHands()
      initTags()

      scaleHand()
      markValid()

      // set the game state for all players
      multiplayer.leaderCode(function ()
      {
          // NOTE: only the leader must set this to true! the clients only get initialized after the initial syncing game state message is received
          initialized = true

          // if we call this here, gameStarted is called twice. it is not needed to call, because it is already called when the room is setup
          // thus we must not call this! forceStartGame() is called from the MatchMakingView, not from the GameScene!
          if(calledFromGameOverScreen)
              // by calling restartGame, we emit a gameStarted call on the leader and the clients
              multiplayer.restartGame()

          // we want to send the state to all players in this case, thus set the playerId to undefined and this case is handled in onMessageReceived so all players handle the game state syncing if playerId is undefined
          // send game state after forceStartGame, otherwise the message will not be received by the initial players!
          if (!multiplayer.singlePlayer)
              sendGameStateToPlayer(undefined)


          // Set first player to play
          var nActualPlayer = arschlochGameLogic.getActualPlayerID()
          console.assert(nActualPlayer >= 0)

          if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())
          {
              multiplayer.triggerNextTurn(playerHands.children[nActualPlayer].player.userId)
          }
          else if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandKartenTauschen())
          {
              // Reset hint
              gameScene.hintRectangle.visible = false;
              elapsedHintTime = 0;
              hintTimer.start()
              aiThinkingTimer.start()
          }

          scaleHand()
      })


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

  // the leader initializes all players and positions them at the borders of the game
  function initPlayers()
  {
      multiplayer.leaderCode(function () {
          console.debug("Leader Init Players")
          var clientPlayers = multiplayer.players
          for (var i = 0; i < clientPlayers.length; i++)
          {
              playerTags.children[i].player = clientPlayers[i]
              playerHands.children[i].player = clientPlayers[i]
          }
      })
  }


  // find hand by userId
  function getHand(userId)
  {
      return playerHands.children[getHandIndex(userId)]
  }


  // find player hand index 0...3 by userId
  function getHandIndex(userId)
  {
      for (var i = 0; i < playerHands.children.length; i++)
          if (playerHands.children[i].player.userId === userId)
              return i

      console.debug("ERROR: could not find player with id", userId, "in the multiplayer.players list!")
      return undefined
  }


  // update tag by player userId
  function updateTag(userId, level, highscore, rank)
  {
      var i = getHandIndex(userId)
      playerTags.children[i].level = level
      playerTags.children[i].highscore = highscore
      playerTags.children[i].rank = rank
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

  // the leader creates the deck and depot
  function initDeck()
  {
      multiplayer.leaderCode(function () {
          deck.createDeck()
          depot.createDepot()
      })
  }

  // the leader hands out the cards to the other players
  function initHands()
  {
      multiplayer.leaderCode(function () {
          for (var i = 0; i < playerHands.children.length; i++) {
              // start the hand for each player
              playerHands.children[i].startHand()
          }
      })
  }

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

  // reset all tags and init the tag for the local player
  function initTags()
  {
      console.debug("initTags()")
      for (var i = 0; i < playerTags.children.length; i++)
      {
          playerTags.children[i].initTag()
          if (playerHands.children[i].player && playerHands.children[i].player.userId == multiplayer.localPlayer.userId){
              playerTags.children[i].getPlayerData(true)
          }
      }
  }

  // draw the specified amount of cards
  function getCards(cards, userId)
  {
      // find the playerHand of the active player and pick up cards
      for (var i = 0; i < playerHands.children.length; i++)
          if (playerHands.children[i].player.userId === userId)
              playerHands.children[i].pickUpCardsFromDeck(cards)
  }


  // find the playerHand of the active player and mark all valid card options
  function markValid()
  {
//      if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandKartenTauschen())
//      {
//      }
//      else if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())
      {
          if (multiplayer.myTurn && !acted )
              getHand(multiplayer.activePlayer.userId).markValid()
          else
              unmark()
      }
  }

  // unmark all valid card options of all players
  function unmark()
  {
      for (var i = 0; i < playerHands.children.length; i++)
          playerHands.children[i].unmark()
  }

  // scale the playerHand of the active localPlayer
  function scaleHand(scale)
  {
      var nLocalPlayerLegacyID = getHandIndex(multiplayer.localPlayer.userId)
      console.assert(nLocalPlayerLegacyID >= 0)

      if (!scale)
      {
          if (  multiplayer.myTurn
                  && !acted
                  && !depot.skipped
                  && arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen()
                  )
              scale = 1.6
          else if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandKartenTauschen()
                && arschlochGameLogic.getCardExchangeNumber(nLocalPlayerLegacyID) !== 0
                   )
              scale = 1.6
          else
              scale = 1
      }

      playerHands.children[nLocalPlayerLegacyID].scaleHand(scale)
  }


  // end the turn of the active player
  function endTurn()
  {
      console.debug("[endTurn]")

      // unmark all highlighted valid card options
      unmark()

      // scale down the hand of the active local player
      scaleHand(1.0)

      var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
      var nActualPlayerLegacy = getHandIndex(userId)
      var playerHand = getHand(userId)

      // CHeck if player just won
      if (arschlochGameLogic.getPlayerGameResult(nActualPlayerLegacy) === Constants.nGameResultUndefined)
      {
          if (playerHand.checkWin())
          {
              console.debug("[endTurn] Player " + multiplayer.activePlayer + + ", LegacyID: " + nActualPlayerLegacy + " HAS FINISHED!!!")

              // Spielergebnis: 3 = Präsi, 0 = Arschloch
              var nNumberPlayers = arschlochGameLogic.getNumberPlayers()
              arschlochGameLogic.setPlayerGameResult(nActualPlayerLegacy, nNumberPlayers - 1)

              // Should eventually be computed within the C++ legacy game logic itself, instead of this external manipulation
              arschlochGameLogic.setNumberPlayers(nNumberPlayers - 1)
          }
      }

      // Everybody has finished
      if (arschlochGameLogic.getNumberPlayers() <= 0)
      {
          console.debug("[endTurn] Ending game")
          endGame()
          multiplayer.sendMessage(messageEndGame, {userId: userId})
      }

      else
      {
          console.debug("[endTurn] Trigger new turn")
          if (multiplayer.amLeader)
              multiplayer.triggerNextTurn()
          else
              multiplayer.sendMessage(messageTriggerTurn, userId)
      }
  }


  // calculate the points for each player
  function calculateScores()
  {
      // Store the winnerPlayer
//      console.assert(depot.finishedUserIDs.length > 0)

      for (var i = 0; i < arschlochGameLogic.getNumberPlayersMax(); i++)
      {
//          var playerHand = getHand(depot.finishedUserIDs[i])
          var playerHand = playerHands.children[i]
//          console.assert(playerHand)

          // President = +2 ... Pleb = -2, Vice = +-1
//          var vScores = [2, 1, -1, -2]
//          playerHand.score = vScores[i]
//          playerHand.scoreAllGames+= vScores[i]
          playerHand.score = arschlochGameLogic.getPlayerGameResult(i)
          playerHand.scoreAllGames+= playerHand.score

          // Store the overall winner - president
          if (i === 0)
              gameScene.gameOverWindow.winnerPlayer = playerHand.player
      }
  }

  // end the game and report the scores
  //    This is called by both the leader and the clients.
  //    Each user calculates and displays the points of all players. The local user reports his score and updates his level.
  //    If it differs from the previous level, the local user levelled up. In this case we display a message with the new level on the game over window.
  //    If he doesn't have a nickname, we ask him to chose one. Then we reset all timers and values.
  function endGame(userId)
  {
      var nPlayerIndex = getHandIndex(multiplayer.localPlayer.userId)
      console.debug("[endGame] called by user: " + userId + ", LegacyPlayerID: " + nPlayerIndex)

      // calculate the points of each player and set the name of the winner
      calculateScores()

      // show the gameOver message with the winner and score
      gameScene.gameOverWindow.visible = true

      // add points to MultiplayerUser score of the winner
      if (nPlayerIndex)
      {
          var currentHand = playerHands.children[nPlayerIndex]
          gameNetwork.reportRelativeScore(currentHand.score)

          var currentTag = playerTags.children[nPlayerIndex]

          // calculate level with new points and check if there was a level up
          var oldLevel = currentTag.level
          currentTag.getPlayerData(false)
          if (oldLevel !== currentTag.level)
          {
              gameScene.gameOverWindow.level = currentTag.level
              gameScene.gameOverWindow.levelText.visible = true
          }
          else
          {
              gameScene.gameOverWindow.levelText.visible = false
          }
      }

      // show window with text input to switch username
      if (!multiplayer.singlePlayer && !gameNetwork.user.hasCustomNickName())
          gameScene.switchNameWindow.visible = true

      // stop all timers and end the game
//      gameOver = true
      arschlochGameLogic.setState(arschlochGameLogic.getConstant_Jojo_SpielZustandNix())
      scaleHand()
      gameScene.hintRectangle.visible = false;
      hintTimer.stop()
      aiThinkingTimer.stop()
//      timerPlayerThinking.running = false
      depot.effectTimer.stop()
  }
}
