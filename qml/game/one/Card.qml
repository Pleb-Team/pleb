import QtQuick 2.0
import Felgo 3.0
import QtGraphicalEffects 1.0
import "../scenes"

EntityBase {
  id: card
  entityType: "card"
  width: 82
  height: 134
  transformOrigin: Item.Bottom

  // original card size for zoom
  property int originalWidth: 82
  property int originalHeight: 134

  // these properties are different for every card type
  variationType: "wild4"
  property int points: 50
  property string cardColor: "black"
  property int order

  // hidden cards show the back side  
  // you could also offer an in-app purchase to show the cards of a player for example!
  property bool hidden: !forceShowAllCards

  // to show all cards on the screen and to test multiplayer syncing, set this to true
  // it is useful for testing, thus always enable it for debug builds and non-publish builds
  property bool forceShowAllCards: system.debugBuild && !system.publishBuild

  // access the image and text from outside
  property alias cardImage: cardImage
  property alias glowImage: glowImage
  property alias cardButton: cardButton

  // for coloring the card
  property real hue: 60/360 // red
  property real lightness: 0
  property real saturation: 0

  // used to reparent the cards at runtime
  property var newParent


  // glow image highlights a valid card
  Image {
    id: glowImage
    anchors.centerIn: parent
    width: parent.width * 1.3
    height: parent.height * 1.2
    source: "../../assets/img/cards/one/glow.png"
    visible: false
    smooth: true
  }

  // card image displaying either the front or the back of the card
  Image {
    id: cardImage
    anchors.fill: parent
    source: "../../assets/img/cards/one/back.png"
    smooth: true

    // changes the cards hue according to the cardColor
    layer.enabled: true
    layer.effect: HueSaturation {
      hue: parent.hue
      lightness: parent.lightness
      saturation: parent.saturation

      Behavior on lightness {
        NumberAnimation { easing.type: Easing.InOutQuad; duration: 400 }
      }

      Behavior on saturation {
        NumberAnimation { easing.type: Easing.InOutQuad; duration: 400 }
      }
    }
  }

  // clickable card area
  MouseArea {
    id: cardButton
    anchors.fill: parent
    onClicked: {
      gameScene.cardSelected(entityId)
    }
  }

  // card flip animation resizes the card and switches the image source
  SequentialAnimation {
    id: hiddenAnimation
    running: false

    NumberAnimation { target: scaleTransform; property: "xScale"; easing.type: Easing.InOutQuad; to: 0; duration: 80 }

    PropertyAction { target: cardImage; property: "source"; value: updateCardImage() }

    NumberAnimation { target: scaleTransform; property: "xScale"; easing.type: Easing.InOutQuad; to: 1.0; duration: 80 }
  }


  // Behaviors animate the card x and y movement and rotation
  Behavior on x {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: 400 }
  }

  Behavior on y {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: 400 }
  }

  Behavior on rotation {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: 400 }
  }

  Behavior on width {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: 400 }
  }

  Behavior on height {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: 400 }
  }

  // reparent card when it changes its state
  states: [
    State {
      name: "depot"
      ParentChange { target: card; parent: newParent; x: 0; y: 0; rotation: 0}
    },
    State {
      name: "player"
      ParentChange { target: card; parent: newParent; x: 0; y: 0; rotation: 0}
    },
    State {
      name: "stack"
      ParentChange { target: card; parent: newParent; x: 0; y: 0; rotation: 0}
    }
  ]

  // transform in the center of the card for the flip animation
  transform: Scale {
    id: scaleTransform
    origin.x: width/2
    origin.y: height/2
  }

  // start the card flip animation when the hidden var changes
  onHiddenChanged: {
    // force to set hidden always to false if we are in development mode, this helps in debugging as we can then see all cards
    if(hidden && forceShowAllCards) {
      hidden = false
    }

    hiddenAnimation.start()
  }

  // update the card image of turning cards
  // update wild and wild4 cards after selecting a color
  // use normal multicolor images for wild and wild4 cards
  // color the other cards with the help of HueSaturation
  function updateCardImage(){
    // hidden cards show the back side without effect
    if (hidden){
      cardImage.layer.enabled = false // deactivate coloring of card
      cardImage.source = "../../assets/img/cards/one/back.png"
      // wild and wild4 cards use normal multicolor images without effect
    } else if (variationType == "wild" || variationType == "wild4"){
      card.hue = 0
      card.saturation = 0
      card.lightness = 0.0
      cardImage.layer.enabled = true // enable coloring of card
      cardImage.source = "../../assets/img/cards/one/" + variationType + "_" + cardColor + ".png"
      // the numbered cards, skip and draw2 are colored with the help of HueSaturation
    } else {
      cardImage.layer.enabled = true // enable coloring of card
      card.lightness = 0.0
      if (cardColor == "yellow") {
        card.hue = 55/360
        card.saturation = 0
      } else if (cardColor == "red") {
        card.hue = 0/360
        card.saturation = 0
      } else if (cardColor == "green") {
        card.hue = 110/360
        card.saturation = -0.1
      } else if (cardColor == "blue") {
        card.hue = 220/360
        card.saturation = -0.1
      }
      cardImage.source = "../../assets/img/cards/one/" + variationType + "_red.png"
    }
  }
}
