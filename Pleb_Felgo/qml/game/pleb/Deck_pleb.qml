import QtQuick 2.0
import Felgo 3.0

// includes all cards in the game and the stack functionality
Item {
  id: deckPleb
  width: 82
  height: 134

  // amount of cards in the game
  property int numberCardsInDeck: 32
  // amount of cards in the stack left to draw
  property int numberCardsInStack: 32

  // array with the information of all cards in the game
  property var cardInfo: []
  // array with all card entities in the game
  property var cardDeck: []

  // all card types and colors
  property var types: ["two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "jack", "queen", "king", "ace"]
  property var cardColor: ["clubs", "diamonds", "hearts", "spades"]


  // shuffle sound in the beginning of the game
  SoundEffect {
    volume: 0.5
    id: shuffleSound
    source: "../../../assets/snd/shuffle.wav"
  }

  // the leader creates the deck in the beginning of the game
  function createDeck(){
    reset()
    createCardInfos()
    shuffleDeck()
    createCards()
  }

//  // the other players sync their deck with the leader in the beginning of the game
//  function syncDeck(deckInfo){
//    reset()
//    for (var i = 0; i < numberCardsInDeck; i ++){
//      cardInfo[i] = deckInfo[i]
//    }
//    createCards()
//  }

  // create the information for all cards
  function createCardInfos(){
      var card
      var order = 0
      // create one clubs, diamonds, hearts and spades card for each type
      for (var i = 5; i < types.length; i++) {
          for (var j = 0; j < cardColor.length; j++) {
              card = {variationType: types[i], cardColor: cardColor[j], points: i+2, hidden: true, order: order}
              cardInfo.push(card)
              order++
          }
      }
  }

  // create the card entities with the cardInfo array
  function createCards()
  {
      shuffleSound.play()
      var id
      for (var i = 0; i < cardInfo.length; i ++){
          id = entityManager.createEntityFromUrlWithProperties(
                      Qt.resolvedUrl("Card_pleb.qml"), {
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


  // hand out cards from cardDeck
  function handOutCards(amount)
  {
      var handOut = []
      for (var i = 0; i < (numberCardsInStack + i) && i < amount; i ++){
          // highest index for the last card on top of the others
          var index = deck.cardDeck.length - (deck.cardDeck.length - deck.numberCardsInStack) - 1
          handOut.push(cardDeck[index])
          numberCardsInStack --
      }

      if (numberCardsInStack < playerHands.children.length) {
          for (; numberCardsInStack > 0; numberCardsInStack--) {
              cardDeck[numberCardsInStack - 1].newParent = null
              cardDeck[numberCardsInStack - 1].state = "void"
              console.debug("voided " + cardDeck[numberCardsInStack - 1])
          }
      }

      return handOut
  }



  // the leader shuffles the cardInfo array in the beginning of the game
  function shuffleDeck()
  {
      // randomize array element order in-place using Durstenfeld shuffle algorithm
      for (var i = cardInfo.length - 1; i > 0; i--) {
          var j = Math.floor(Math.random() * (i + 1))
          var temp = cardInfo[i]
          cardInfo[i] = cardInfo[j]
          cardInfo[j] = temp
      }
      numberCardsInStack = numberCardsInDeck
  }

  // remove all cards and playerHands between games
  function reset()
  {
      var toRemoveEntityTypes = ["card"]
      entityManager.removeEntitiesByFilter(toRemoveEntityTypes)
      while(cardDeck.length) {
          cardDeck.pop()
          cardInfo.pop()
      }
      numberCardsInStack = numberCardsInDeck
      for (var i = 0; i < playerHands.children.length; i++) {
          playerHands.children[i].reset()
      }
  }


  // reposition the remaining cards to create a stack
  function offsetStack(){
    for (var i = 0; i < cardDeck.length; i++){
      if (cardDeck[i].state == "stack"){
        cardDeck[i].y = i * (-0.1)
      }
    }
  }


  // move the stack cards to the beginning of the cardDeck array
  function moveElement(from, to){
    cardDeck.splice(to,0,cardDeck.splice(from,1)[0])
    return this
  }
}
