import QtQuick 2.0
import Felgo 3.0

// includes all cards in the game and the stack functionality
Item {
  id: deck
  width: 82
  height: 134

  // amount of cards in the game
  property int cardsInDeck: 108
  // amount of cards in the stack left to draw
  property int cardsInStack: 108
  // array with the information of all cards in the game
  property var cardInfo: []
  // array with all card entities in the game
  property var cardDeck: []
  // all card types and colors
  property var types: ["zero", "one", "two", "three", "four", "five", "six",
    "seven", "eight", "nine", "draw2", "skip", "reverse", "wild", "wild4"]
  property var cardColor: ["yellow", "red", "green", "blue", "black"]


  // shuffle sound in the beginning of the game
  SoundEffect {
    volume: 0.5
    id: shuffleSound
    source: "../../assets/snd/shuffle.wav"
  }

  // the leader creates the deck in the beginning of the game
  function createDeck(){
    reset()
    fillDeck()
    shuffleDeck()
    printDeck()
  }

  // the other players sync their deck with the leader in the beginning of the game
  function syncDeck(deckInfo){
    reset()
    for (var i = 0; i < cardsInDeck; i ++){
      cardInfo[i] = deckInfo[i]
    }
    printDeck()
  }

  // create the information for all cards
  function fillDeck(){
    var card
    var order = 0

    // create yellow, green, red and blue colored cards
    for (var i = 0; i < 4; i ++){
      // one zero card per color
      card = {variationType: types[0], cardColor: cardColor[i], points: 5, hidden: true, order: order}
      cardInfo.push(card)
      order ++

      // two 1-9 value cards per color
      for (var j = 1; j <= 9; j ++){
        for (var k = 0; k < 2; k ++){
          card = {variationType: types[j], cardColor: cardColor[i], points: 5, hidden: true, order: order}
          cardInfo.push(card)
          order ++
        }
      }

      // two draw2/skip/reverse cards per color
      for (var l = 10; l <= 12; l ++){
        for (var m = 0; m < 2; m ++){
          card = {variationType: types[l], cardColor: cardColor[i], points: 20, hidden: true, order: order}
          cardInfo.push(card)
          order ++
        }
      }
    }

    // create four black wild and four wild4 cards
    for (var n = 13; n <= 14; n ++){
      for (var o = 0; o < 4; o ++){
        card = {variationType: types[n], cardColor: cardColor[4], points: 50, hidden: true, order: order}
        cardInfo.push(card)
        order ++
      }
    }
  }

  // create the card entities with the cardInfo array
  function printDeck(){
    shuffleSound.play()
    var id
    for (var i = 0; i < cardInfo.length; i ++){
      id = entityManager.createEntityFromUrlWithProperties(
            Qt.resolvedUrl("Card.qml"), {
              "variationType": cardInfo[i].variationType,
              "cardColor": cardInfo[i].cardColor,
              "points": cardInfo[i].points,
              "order": cardInfo[i].order,
              "hidden": cardInfo[i].hidden,
              "z": i,
              "state": "stack",
              "parent": deck,
              "newParent": deck})
      cardDeck.push(entityManager.getEntityById(id))
    }
    offsetStack()
  }

  // hand out cards
  function handOutCards(amount){
    var handOut = []
    for (var i = 0; i < (cardsInStack + i) && i < amount; i ++){
      // highest index for the last card on top of the others
      var index = deck.cardDeck.length - (deck.cardDeck.length - deck.cardsInStack) - 1
      handOut.push(cardDeck[index])
      cardsInStack --
    }
    // deactivate ONU state after drawing cards
    passedChance()
    // deactivate card effects after drawing a card
    depot.effect = false
    var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
    multiplayer.sendMessage(gameLogic.messageSetEffect, {effect: false, userId: userId})
    return handOut
  }

  // deactivate ONU state for active player after drawing cards
  function passedChance(){
    for (var i = 0; i < playerHands.children.length; i++) {
      if (playerHands.children[i].player === multiplayer.activePlayer){
        if (multiplayer.myTurn || !multiplayer.activePlayer || !multiplayer.activePlayer.connected){
          playerHands.children[i].onu = false
          var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
          multiplayer.sendMessage(gameLogic.messagePressONU, {userId: userId, onu: false})
        }
      }
    }
  }

  // the leader shuffles the cardInfo array in the beginning of the game
  function shuffleDeck(){
    // randomize array element order in-place using Durstenfeld shuffle algorithm
    for (var i = cardInfo.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1))
      var temp = cardInfo[i]
      cardInfo[i] = cardInfo[j]
      cardInfo[j] = temp
    }
    cardsInStack = cardsInDeck
  }

  // remove all cards and playerHands between games
  function reset(){
    var toRemoveEntityTypes = ["card"]
    entityManager.removeEntitiesByFilter(toRemoveEntityTypes)
    while(cardDeck.length) {
      cardDeck.pop()
      cardInfo.pop()
    }
    cardsInStack = cardsInDeck
    for (var i = 0; i < playerHands.children.length; i++) {
      playerHands.children[i].reset()
    }
  }

  // get the id of the card on top of the stack
  function getTopCardId(){
    // create a new stack from depot cards if there's no card left to draw
    reStack()
    var index = Math.max(cardDeck.length - (cardDeck.length - cardsInStack) - 1, 0)
    return deck.cardDeck[index].entityId
  }

  // reposition the remaining cards to create a stack
  function offsetStack(){
    for (var i = 0; i < cardDeck.length; i++){
      if (cardDeck[i].state == "stack"){
        cardDeck[i].y = i * (-0.1)
      }
    }
  }

  // mark the stack if there are no other valid card options
  function markStack(){
    if (cardDeck.length <= 0) return
    var card = entityManager.getEntityById(getTopCardId())
    card.glowImage.visible = true
  }

  // unmark the stack
  function unmark(){
    if (cardDeck.length <= 0) return
    var card = entityManager.getEntityById(getTopCardId())
    card.glowImage.visible = false
  }

  // move the old depot cards to the stack if there are no cards left to draw
  function reStack(){
    var cardIds = []
    if (cardsInStack <= 1){
      // find all old depot cards
      for (var i = 0; i < cardDeck.length; i ++){
        if (cardDeck[i].state === "depot" && cardDeck[i].entityId !== depot.current.entityId){
          cardIds.push(cardDeck[i].entityId)
        }
      }
      // reparent and hide the cards and move them to the beginning of the cardDeck array
      for (var j = 0; j < cardIds.length; j++) {
        for (var k = 0; k < cardDeck.length; k ++){
          if (cardDeck[k].entityId == cardIds[j]){
            if(cardDeck[k].variationType == "wild" || cardDeck[k].variationType == "wild4"){
              cardDeck[k].cardColor = "black"
            }
            cardDeck[k].hidden = true
            cardDeck[k].newParent = deck
            cardDeck[k].state = "stack"
            moveElement(k, 0)
            cardsInStack ++
            break
          }
        }
      }
    }
    // reposition the new cards to create a stack
    offsetStack()
  }

  // move the stack cards to the beginning of the cardDeck array
  function moveElement(from, to){
    cardDeck.splice(to,0,cardDeck.splice(from,1)[0])
    return this
  }
}
