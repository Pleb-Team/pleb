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

          for (var n = 0; n < 4; n++)
          {
              var playerHand = playerHands.children[n]
              if (playerHand.hand.length !== arschlochGameLogic.getPlayerCardsNumber(n))
              {
                  console.error("------------------------------------ERROR! Internal game state discrepancy --------------------------")

                  var sCards = arschlochGameLogic.getPlayerCardsText()
                  console.error("Internal state\n" + sCards)
              }
          }

          elapsedHintTime += 1

          if (elapsedHintTime >= 5)
          {
              var s2 = ""
              var s = ""

              if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandKartenTauschen())
              {
                  if (nCardExchangeNumber > 0)
                      s2 = "You lost! Give your " + nCardExchangeNumber + " highest cards to player " + nPlayerIndexCardExchange
                  else if (nCardExchangeNumber < 0)
                      s2 = "You won! Give your " + (-nCardExchangeNumber) + " lowest cards to player " + nPlayerIndexCardExchange
                  else
                      s2 = "Lean back and wait for the others to finish exchanging cards"

                  if (nCardExchangeNumber !== 0)
                      s = "Select cards and press the screen center to pass them to your exchange player."

              }
              else if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())
              {
                  if (depot.lastPlayerUserID && depot.lastDeposit && !hasValidCards(multiplayer.localPlayer))
                      s2 = "Too bad, you cannot exceed your opponents move :-("
                  else if (depot.lastPlayerUserID && depot.lastDeposit)
                      s2 = "Beat your opponent and play higher than " + depot.lastDeposit[0].variationType + "!"
                  else
                      s2 = "Start freely and play arbitrary cards. Get rid of something :-)"

                  if (depot.lastPlayerUserID && depot.lastDeposit && !hasValidCards(multiplayer.localPlayer))
                      s = "Press screen center to pass."
                  else if (depot.lastPlayerUserID && depot.lastDeposit.length === 1)
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
      repeat: false
      onTriggered:
      {

          if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandKartenTauschen())
          {
              // Search for AI player which still has to exchange cards
              for (var m = 0; m < playerHands.children.length; m++)
                  if (  (playerHands.children[m].player !== multiplayer.localPlayer)
                     && (arschlochGameLogic.getCardExchangeNumber(m) !== 0) )
                  {
                      skipOrPlay(playerHands.children[m].player.userId, false)
                  }
          }

          else if (     (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())
                   &&   (multiplayer.activePlayer !== 0)
                   &&   (multiplayer.localPlayer !== multiplayer.activePlayer) )
          {
              skipOrPlay(multiplayer.activePlayer.userId, false)
          }
      }
  }


  function skipOrPlay(userId, bHumanPlayer)
  {
      if (!userId)
          userId = multiplayer.localPlayer.userId

      var activeHand = getHand(userId)
      var nPlayerIndexLegacy = getHandIndex(userId)
      var cardIds = activeHand.getSelectedCardIDs()
      var selectedCards = activeHand.getSelectedCards()
      var moveSimpleValue = -1
      var moveSimpleNumber = 0

      if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandKartenTauschen())
      {

          if (  (arschlochGameLogic.getCardExchangeNumber(nPlayerIndexLegacy) === 0)
            ||  (arschlochGameLogic.getCardExchangePartner(nPlayerIndexLegacy) < 0)  )
          {
              console.debug("Card exchange is already finished or no exchange partner defined for player index:" + nPlayerIndexLegacy)
              return
          }

          if (!bHumanPlayer)
          {
              cardIds = legacyPlebCodeBridge.calcMoveCardExchange(userId, nPlayerIndexLegacy)
              console.assert(cardIds.length === 1)

              selectedCards = []
              selectedCards.push(entityManager.getEntityById(cardIds[0]))
          }

          // Check if correct number of cards selected
          if (  (selectedCards.length === 0) ||
                (selectedCards.length > Math.abs(arschlochGameLogic.getCardExchangeNumber(nPlayerIndexLegacy)) ) )
              return


          var nPlayerIndexCardExchange = arschlochGameLogic.getCardExchangePartner(nPlayerIndexLegacy)
          var exchangePartnerHand = playerHands.children[nPlayerIndexCardExchange]

          // Workaround: First deposit the cards to the depot for 1 ms such that the owner is changed correctly
          depositCards(cardIds, userId)
          depot.reset()

          // ... then hand them over to the exchange partner
          exchangePartnerHand.pickUpCards(selectedCards)
          scaleHand()

          // Sync legacy gamestate
          for (var n = 0; n < selectedCards.length; n++)
              arschlochGameLogic.giveCardToExchangePartner(nPlayerIndexLegacy, nPlayerIndexCardExchange, selectedCards[n].points - 7)

          // Card exchange has just finished
          if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())
          {
              aiThinkingTimer.stop()
              multiplayer.triggerNextTurn(playerHands.children[arschlochGameLogic.getActualPlayerID()].player.userId)
          } 
      }

      else if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())
      {
          // Make sure this player still has to play
          if (bHumanPlayer)
          {
              if (!multiplayer.myTurn || depot.skipped || acted)
                  return
          }
          else
          {
              if (depot.skipped)
              {
                  endTurn()
                  return
              }

              cardIds = legacyPlebCodeBridge.calcMove(userId, nPlayerIndexLegacy)
          }

          // Move cards to depot and inform Multiplayer
          acted = true
          if (cardIds.length > 0)
          {
              console.debug("Player " + userId + " plays these cards: " + cardIds)
              depositCards(cardIds, userId)
              multiplayer.sendMessage(messageMoveCardsDepot, {cardIds: cardIds, userId: userId})

              var card = entityManager.getEntityById(cardIds[0])
              moveSimpleNumber = cardIds.length
              moveSimpleValue = card.points - 7
          }
          else
              console.debug("Player " + userId + "skipped his turn")


          // Now play in the internal legacy game model
          console.assert(nPlayerIndexLegacy === arschlochGameLogic.getActualPlayerID(), "Wrong Player Ids! QML: " + nPlayerIndexLegacy + ", Legacy: " + arschlochGameLogic.getActualPlayerID());

          arschlochGameLogic.setMoveSimpleNumber(moveSimpleNumber)
          arschlochGameLogic.setMoveSimpleValue(moveSimpleValue)
          if (!arschlochGameLogic.playCards())
          {
              var s = arschlochGameLogic.getPlayerCardsText()
              console.error("Error when playing cards! Player " + userId + " tried to play number cards: " + moveSimpleNumber + ", value legacy: " + moveSimpleValue)
              console.error("Internal game state: \n" + s)
          }


          endTurn()
      }
  }


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
  function hasValidCards(user)
  {
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
      {
          depot.lastPlayerUserID = null
          depot.lastDeposit = []
      }

      // Verify last move
      if ((depot.lastPlayerUserID === null) !== (arschlochGameLogic.getLastPlayerID() === -1))
      {
          var nProblem = 42;
      }


      console.assert((depot.lastPlayerUserID === null) === (arschlochGameLogic.getLastPlayerID() === -1), "Last move discrepancy!")
      if (depot.lastPlayerUserID !== null)
      {
          console.assert(depot.lastDeposit.length === arschlochGameLogic.getLastMoveSimpleNumber())
          console.assert(depot.lastDeposit[0].points - 7 === arschlochGameLogic.getLastMoveSimpleValue())
      }


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
//          var canPlay = hasValidCards(multiplayer.activePlayer)
//          if (canPlay)
//          {
              depot.skipTurn(false)

              unmark()
              scaleHand()
              markValid()
//          }
//          else
//          {
//              // skip if the player has no valid cards
//              // Note: The effectTimer used to show the skip message will also trigger the next turn upon expiration
////              depot.skipTurn(true)
//          }
      }


      // Reset hint
      gameScene.hintRectangle.visible = false;
      elapsedHintTime = 0;
      hintTimer.start()

      // schedule AI to play after some time
      multiplayer.leaderCode(function() {
          if (!multiplayer.activePlayer || !multiplayer.activePlayer.connected) {
              aiThinkingTimer.start()
              aiThinkingTimer.repeat = false
          }
      })
  }


  function plebFinish(plebHand)
  {
      // let the new Pleb finish its game by playing all its remaining cards
      var lastcards = []
      for (var l = 0; l < plebHand.hand.length; l++)
          lastcards.push(plebHand.hand[l].entityId)

      multiplayer.sendMessage(messageMoveCardsDepot, {cardIds: lastcards, userId: plebHand.player.userId})
      depositCards(lastcards, plebHand.player.userId)
  }



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
      gameScene.gameOverWindow.visible = false
      gameScene.leaveGameWindow.visible = false
      gameScene.switchNameWindow.visible = false
      playerInfoPopup.visible = false
      chat.reset()
      depot.reset()


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

      // Players take cards from the deck
      initHands()
      initTags()

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
//          if (!multiplayer.singlePlayer)
//              sendGameStateToPlayer(undefined)


          // Set first player to play
          var nActualPlayerLegacy = arschlochGameLogic.getActualPlayerID()
          console.assert(nActualPlayerLegacy >= 0)

          if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())
          {
              multiplayer.triggerNextTurn(playerHands.children[nActualPlayerLegacy].player.userId)
          }
          else if (arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandKartenTauschen())
          {
              // Reset hint
              gameScene.hintRectangle.visible = false;
              elapsedHintTime = 0;
              hintTimer.start()

              // Repeating timer needed here s.t. all AI players can act
              aiThinkingTimer.start()
              aiThinkingTimer.repeat = true
          }
      })

      scaleHand()
      markValid()

      console.debug("InitGame finished!")
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


  // reset all tags and init the tag for the local player
  function initTags()
  {
      console.debug("initTags()")
      for (var i = 0; i < playerTags.children.length; i++)
      {
          playerTags.children[i].initTag()
          if (playerHands.children[i].player && playerHands.children[i].player.userId === multiplayer.localPlayer.userId){
              playerTags.children[i].getPlayerData(true)
          }
      }
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

      // Check if player just won
      if (arschlochGameLogic.getPlayerGameResult(nActualPlayerLegacy) === Constants.nGameResultUndefined)
          if (playerHand.checkWin())
          {
              console.debug("[endTurn] Player " + multiplayer.activePlayer + ", LegacyID: " + nActualPlayerLegacy + " HAS FINISHED!!!")

              // Spielergebnis: 3 = Präsi, 0 = Arschloch
//              var nNumberPlayers = arschlochGameLogic.getNumberPlayers()
//              arschlochGameLogic.setPlayerGameResult(nActualPlayerLegacy, nNumberPlayers - 1)

              // Should eventually be computed within the C++ legacy game logic itself, instead of this external manipulation
//              arschlochGameLogic.setNumberPlayers(nNumberPlayers - 1)
          }

      // Everybody has finished
      if (arschlochGameLogic.getNumberPlayers() <= 0)
      {
          console.debug("[endTurn] Ending game")
          console.assert(arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielZuEnde)

          endGame()
          multiplayer.sendMessage(messageEndGame, {userId: userId})
      }

      else
      {
          console.debug("[endTurn] Trigger new turn")
          if (multiplayer.amLeader)
          {
              nActualPlayerLegacy = arschlochGameLogic.getActualPlayerID()
              console.assert(nActualPlayerLegacy >= 0)
              console.assert(arschlochGameLogic.getState() === arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen())

              multiplayer.triggerNextTurn(playerHands.children[nActualPlayerLegacy].player.userId)
          }
          else
              multiplayer.sendMessage(messageTriggerTurn, userId)
      }
  }


  // calculate the points for each player
  function calculateScores()
  {
      for (var i = 0; i < arschlochGameLogic.getNumberPlayersMax(); i++)
      {
          var playerHand = playerHands.children[i]
          playerHand.score = arschlochGameLogic.getPlayerGameResult(i)
          playerHand.scoreAllGames+= playerHand.score

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
              skipOrPlay(multiplayer.localPlayer.userId, true)
          }
      }

      onDepotSelected:
      {
          console.debug("DEPOT ITSELF SELECTED")
          skipOrPlay(multiplayer.localPlayer.userId, true)
      }
  }
}
