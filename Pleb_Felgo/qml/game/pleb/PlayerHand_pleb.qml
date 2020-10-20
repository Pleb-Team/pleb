import QtQuick 2.0
import Felgo 3.0
import "../../common"
import "../../interface"

// the cards in the hand of the player
Item {
  id: playerHandPleb
  width: 400
  height: 134

  property double zoom: 1.0
  property int originalWidth: 400
  property int originalHeight: 134

  // amount of cards in hand in the beginning of the game
  property int numberCardsAtBeginningOfGame: 8

  // array with all cards in hand
  property var hand: []

  property var playerTag: PlayerTag{}

  // the owner of the cards
  property var player: MultiplayerUser{}

  // the score at the end of the game
  property int score: 0
  property int scoreAllGames: 0

  // value used to spread the cards in hand
  property double offset: width/10


  // block the player for a short period of time when he gets skipped
//  property alias effectTimer: effectTimer



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
      interval: 1000
  }


  // sound effect plays when drawing a card
  SoundEffect {
    volume: 0.5
    id: drawSound
    source: "../../../assets/snd/draw.wav"
  }

  // sound effect plays when depositing a card
  SoundEffect {
    volume: 0.5
    id: depositSound
    source: "../../../assets/snd/deposit.wav"
  }

  // sound effect plays when winning the game
  SoundEffect {
    volume: 0.5
    id: winSound
    source: "../../../assets/snd/win.wav"
  }


  // playerHand background image
  // the image changes for the active player
  Image {
    id: playerHandImage
    source: multiplayer.activePlayer === player && !gameLogic.acted? "../../../assets/img/PlayerHand2.png" : "../../../assets/img/PlayerHand1.png"
    width: parent.width / 400 * 560
    height: parent.height / 134 * 260
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: parent.height * (-0.5)
    z: 0
    smooth: true

    onSourceChanged: {
      z = 0
      neatHand()
    }
  }


  // indicates that the player skipped
  Image {
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    source: "../../../assets/img/Blocked.png"
    width: 170
    height: width
    z: 100
    visible: effectTimer.running
    smooth: true
  }



  function playSkipAnimation()
  {
      skipSound.play()
      effectTimer.start()
  }


  // start the hand by picking up a specified amount of cards
  function startHand()
  {
      var cardEntities = []

      if (menuScene.localStorage.debugMode)
          cardEntities = deck.handOutCards(2)
      else
          cardEntities = deck.handOutCards(numberCardsAtBeginningOfGame)

      pickUpCards(cardEntities, true)
  }


  // reset the hand by removing all cards
  function reset()
  {
      while(hand.length)
      {
          hand.pop()
      }

      scaleHand(1.0)
  }


  // organize the hand and spread the cards
  function neatHand()
  {
      // sort all cards by their natural order
      hand.sort(function(a, b)
      {
          return a.order - b.order
      })

      // recalculate the offset between cards if there are too many in the hand
      // make sure they stay within the playerHand
      offset = originalWidth * zoom / 10
      if (hand.length > 7){
          offset = playerHandPleb.originalWidth * zoom / hand.length / 1.5
      }

      // calculate the card position and rotation in the hand and change the z order
      for (var i = 0; i < hand.length; i ++)
      {
          var card = hand[i]
          // angle span for spread cards in hand
          var handAngle = 40
          // card angle depending on the array position
          var cardAngle = handAngle / hand.length * (i + 0.5) - handAngle / 2
          //offset of all cards + one card width
          var handWidth = offset * (hand.length - 1) + card.originalWidth * zoom
          // x value depending on the array position
          var cardX = (playerHandPleb.originalWidth * zoom - handWidth) / 2 + (i * offset)

          card.rotation = cardAngle
          card.setPosInPlayerHand(cardX, Math.abs(cardAngle) * 1.5, i + 50 + playerHandImage.z)
      }
  }


  // pick up specified amount of cards
  function pickUpCards(cardEntities, updateLegacyGameState)
  {
      var nPlayerIndexLegacy = gameLogic.getHandIndex(player.userId)

      // add the stack cards to the playerHand array
      for (var i = 0; i < cardEntities.length; i ++)
      {
          hand.push(cardEntities[i])

          cardEntities[i].newParent = playerHandPleb
          cardEntities[i].state = "player"
          cardEntities[i].hidden = (multiplayer.localPlayer !== player)
          drawSound.play()

          if (updateLegacyGameState)
              gameLogic.arschlochGameLogic.addPlayerCards(nPlayerIndexLegacy, 1, cardEntities[i].points - 7)
      }

      // reorganize the hand
      neatHand()
  }


  // check if a card with a specific id is on this hand
  function inHand(cardId)
  {
      for (var i = 0; i < hand.length; i ++){
          if(hand[i].entityId === cardId){
              return true
          }
      }
      return false
  }


  function findCardIDs(nNumber, nPoints)
  {
      var result = []

      // Find the cards in the player's hand.
      for (var k = 0; (result.length < nNumber) && (k < hand.length); k++)
          if (hand[k].points === nPoints)
              result.push(hand[k].entityId)

      // Make sure we found all needed cards
      console.assert(result.length === nNumber, "findCardIDs() failed, cards not found! nNumber, nPoints: " + nNumber + ", " + nPoints)
      if (result.length !== nNumber)
          result = []

      return result
  }


  function findCards(nNumber, nPoints)
  {
      var result = []

      // Find the cards in the player's hand.
      for (var k = 0; (result.length < nNumber) && (k < hand.length); k++)
          if (hand[k].points === nPoints)
              result.push(hand[k])

      // Make sure we found all needed cards
      console.assert(result.length === nNumber, "findCardIDs() failed, cards not found! nNumber, nPoints: " + nNumber + ", " + nPoints)
      if (result.length !== nNumber)
          result = []

      return result
  }


  // counts how many cards with the supplied points are in hand
  function countCards(points)
  {
      var result = 0
      for (var i = 0; i < hand.length; i ++)
          if(hand[i].points === points)
              result++

      return result
  }


  // remove card with a specific id from hand
  function removeCardId(cardId)
  {
      for (var i = 0; i < hand.length; i ++)
      {
          if(hand[i].entityId === cardId)
          {
              hand[i].width = hand[i].originalWidth
              hand[i].height = hand[i].originalHeight
              hand.splice(i, 1)
              depositSound.play()
              neatHand()

              return true
          }
      }

      return false
  }

  // remove card with a specific id from hand
  function removeCardEntity(cardEntity)
  {
      for (var i = 0; i < hand.length; i ++)
          if (hand[i] === cardEntity)
          {
              hand[i].width = hand[i].originalWidth
              hand[i].height = hand[i].originalHeight
              hand.splice(i, 1)
              depositSound.play()
              neatHand()

              return true
          }

      return false
  }



  function getSelectedCards()
  {
      var result = []
      for (var i = 0; i < hand.length; i++)
          if (hand[i].selected === true)
              result.push(hand[i])

      return result
  }


  function getSelectedCardIDs()
  {
      var result = []
      for (var i = 0; i < hand.length; i++)
          if (hand[i].selected === true)
              result.push(hand[i].entityId)

      return result
  }

  function getAllAvailableGroups(gPoints) {
      var result = []
      var pointGroup = {}
      var group
      for (var i = 0; i < hand.length; i++) {
          group = pointGroup[hand[i].points]
          if (!group) {
              group = []
              pointGroup[hand[i].points] = group
          }
          group.push(hand[i])
      }
      for (var j = ((gPoints) ? gPoints : 0); j < 15; j++) {
          group = pointGroup[j]
          if (group) {
              for (var k = group.length; k > 1; k--) {
                  result.push(group.slice(0, k))
              }
          }
      }
      return result
  }

  // highlight all valid cards by setting the glowImage visible
  // A Card is valid iff
  // - it is allowed to select this card in order to play it later (possibly together with other cards of the same value)
  // - and not too many cards are already selected
  // Pretty complicated, but note that on mobile devices, each card is selected by manually tapping the cards one by one
  function markValid()
  {
      var selectedGroup = getSelectedCards()
      var nPlayerIndexLegacy = gameLogic.getHandIndex(player.userId)
      var cardExchangeNumber = gameLogic.arschlochGameLogic.getCardExchangeNumber(nPlayerIndexLegacy)
      var i

      if (gameLogic.arschlochGameLogic.getState() === gameLogic.arschlochGameLogic.getConstant_Jojo_SpielZustandKartenTauschen() )
      {
          if  (     (cardExchangeNumber > 0)
                &&  (hand.length >= cardExchangeNumber))
          {
              // sort all cards ascenting by points
              var listCards = hand.filter(function(item) {
                  return !item.selected
              })

              listCards.sort(function(a, b)
              {
                  return a.points - b.points
              })

              // Pleb must give away all cards with >= this many points. Note that some card might be
              // already selected which is treated as if it has been given away already
              var cardExchangeNumberRemaining = cardExchangeNumber - selectedGroup.length
              var lowestPointsForExchange = 99999
              if (cardExchangeNumberRemaining > 0)
                  lowestPointsForExchange = listCards[listCards.length-cardExchangeNumberRemaining].points


              for (i = 0; i < hand.length; i ++)
                  hand[i].glowImage.visible = (hand[i].points >= lowestPointsForExchange) && !hand[i].selected
          }
          else if  (cardExchangeNumber < 0)
          {
              for (i = 0; i < hand.length; i ++)
                  hand[i].glowImage.visible = !hand[i].selected
          }


      }
      else if (gameLogic.arschlochGameLogic.getState() === gameLogic.arschlochGameLogic.getConstant_Jojo_SpielZustandSpielen() )
      {
          if (player === multiplayer.activePlayer)
          {
              for (i = 0; i < hand.length; i ++)
              {
                  // Skip invalid cards immediately
                  if (!depot.validCardID(hand[i].entityId))
                  {
                      hand[i].glowImage.visible = false
                      continue
                  }

                  // Nothing yet selected --> All cards of valid value are allowed
                  if (selectedGroup.length === 0)
                  {
                      hand[i].glowImage.visible = true
                      continue
                  }


                  // ... already some card selected --> allow further cards to be selected only of same value
                  // and correct number of cards
                  else if (  selectedGroup[0].points === hand[i].points
                          &&  (   gameLogic.arschlochGameLogic.getLastPlayerID() < 0
                              ||  gameLogic.arschlochGameLogic.getLastPlayerID() === nPlayerIndexLegacy
                              ||  gameLogic.arschlochGameLogic.getLastMoveSimpleNumber() > selectedGroup.length
                              )
                          )
                  {
                      hand[i].glowImage.visible = !hand[i].selected
                  }
                  else
                  {
                      hand[i].glowImage.visible = false
                  }
              }
          }
      }
      else
      {
          unmark()
      }
  }

  // unmark all cards in hand
  function unmark()
  {
      for (var i = 0; i < hand.length; i ++){
          hand[i].glowImage.visible = false
          hand[i].selected = false
          hand[i].updateCardImage()
      }
  }

  // scale the whole playerHand of the active localPlayer with a zoom factor
  function scaleHand(scale){
    zoom = scale
    playerHandPleb.height = playerHandPleb.originalHeight * zoom
    playerHandPleb.width = playerHandPleb.originalWidth * zoom
    for (var i = 0; i < hand.length; i ++){
      hand[i].width = hand[i].originalWidth * zoom
      hand[i].height = hand[i].originalHeight * zoom
    }
    neatHand()
  }


  // get an array with all valid cards
  function getValidCards()
  {
      var valids = []

      // put all valid card options in the array
      for (var i = 0; i < hand.length; i ++)
          if (depot.validCardID(hand[i].entityId))
              valids.push(entityManager.getEntityById(hand[i].entityId))


      return valids
  }


  // check if the player has finished with zero cards left
  function checkWin()
  {
      if (hand.length == 0)
      {
          winSound.play()
          return true
      }
      else
      {
          return false
      }
  }


  // animate the playerHand width and height
  Behavior on width {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: Constants.nAnimationDurationMS }
  }

  Behavior on height {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: Constants.nAnimationDurationMS }
  }
}
