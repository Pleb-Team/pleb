import QtQuick 2.0
import Felgo 3.0
import QtGraphicalEffects 1.0
import "../../scenes"
import "../../common"

EntityBase {
  id: cardPleb
  entityType: "card"
  width: 82
  height: 134
  transformOrigin: Item.Bottom

  // original card size for zoom
  property int originalWidth: 82
  property int originalHeight: 134

  // these properties are different for every card type
  variationType: "ace"
  property int points: 14
  property string cardColor: "spades"
  property int order

  // hidden cards show the back side  
  // you could also offer an in-app purchase to show the cards of a player for example!
  property bool hidden: true

  // to show all cards on the screen and to test multiplayer syncing, set this to true
  // it is useful for testing, thus always enable it for debug builds and non-publish builds
//  property bool forceShowAllCards: (system.debugBuild && !system.publishBuild) || menuScene.localStorage.debugMode

  property bool selected: false

  // access the image and text from outside
  property alias cardImage: cardImage
  property alias glowImage: glowImage
  property alias glowGroupImage: glowGroupImage
  property alias cardButton: cardButton

  // used to reparent the cards at runtime
  property var newParent

  property int posX: 0
  property int posY: 0
  property int posZ: 0

  function setPosInPlayerHand(newX, newY, newZ)
  {
      posX = newX
      posY = newY
      posZ = newZ

      x = posX
      y = posY
      z = posZ

      adjustGeometry()
  }

  onSelectedChanged:
  {
//      glowGroupImage.visible = selected
      adjustGeometry()
  }

  function adjustGeometry()
  {
      if (selected)
          y = posY - 40
      else
          y = posY
  }

  // glow image highlights a valid card
  Image {
    id: glowImage
    anchors.centerIn: parent
    width: parent.width * 1.3
    height: parent.height * 1.2
    source: "../../../assets/img/cards/glow.png"
    visible: false
    smooth: true
  }

  // glow image highlights a group card
  Image {
    id: glowGroupImage
    anchors.centerIn: parent
    width: parent.width * 1.3
    height: parent.height * 1.2
    source: "../../../assets/img/cards/glowGroup.png"
    visible: false
    smooth: true
  }

  // card image displaying either the front or the back of the card
  Image {
    id: cardImage
    anchors.fill: parent
    source: "../../../assets/img/cards/back.png"
    smooth: true
  }

  // clickable card area
  MouseArea {
    id: cardButton
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: {
        if (mouse.button === Qt.RightButton) {
            gameScene.cardGroupToggle(entityId)
        } else {
            gameScene.cardSelected(entityId)
        }
    }
  }

  // card flip animation resizes the card and switches the image source
  SequentialAnimation {
    id: hiddenAnimation
    running: false

//    NumberAnimation { target: scaleTransform; property: "xScale"; easing.type: Easing.InOutQuad; to: 0; duration: 80 }

    PropertyAction { target: cardImage; property: "source"; value: updateCardImage() }

//    NumberAnimation { target: scaleTransform; property: "xScale"; easing.type: Easing.InOutQuad; to: 1.0; duration: 80 }
  }


  // Behaviors animate the card x and y movement and rotation
  Behavior on x {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: Constants.nAnimationDurationMS }
  }

  Behavior on y {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: Constants.nAnimationDurationMS }
  }

  Behavior on rotation {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: Constants.nAnimationDurationMS }
  }

  Behavior on width {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: Constants.nAnimationDurationMS }
  }

  Behavior on height {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: Constants.nAnimationDurationMS }
  }

  // reparent card when it changes its state
  states: [
    State {
      name: "depot"
      ParentChange { target: cardPleb; parent: newParent; x: 0; y: 0; rotation: 0}
    },
    State {
      name: "player"
      ParentChange { target: cardPleb; parent: newParent; x: 0; y: 0; rotation: 0}
    },
    State {
      name: "stack"
      ParentChange { target: cardPleb; parent: newParent; x: 0; y: 0; rotation: 0}
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
//    if(hidden && forceShowAllCards) {
//      hidden = false
//    }

    hiddenAnimation.start()
  }

  // update the card image of turning cards
  function updateCardImage(){
    // hidden cards show the back side without effect
    if (hidden /*&& !menuScene.localStorage.debugMode*/){
      cardImage.source = "../../../assets/img/cards/back.png"
    } else if (variationType == "ten") {
        cardImage.source = "../../../assets/img/cards/" + "X" + cardColor.charAt(0).toLowerCase() + ".png"
    } else if (variationType == "jack" || variationType == "queen" || variationType == "king" || variationType == "ace"){
      cardImage.source = "../../../assets/img/cards/" + variationType.charAt(0).toUpperCase() + cardColor.charAt(0).toLowerCase() + ".png"
    } else {
        cardImage.source = "../../../assets/img/cards/" + points + cardColor.charAt(0).toLowerCase() + ".png"
    }
  }
}
