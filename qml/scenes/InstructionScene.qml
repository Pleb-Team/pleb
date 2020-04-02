import Felgo 3.0
import QtQuick 2.0
import "../common"

// scene describing the game rules
SceneBase {
  id: instructionScene

  signal menuButtonPressed(string button)


  // background
  Image {
    id: background
    source: "../../assets/img/BG.png"
    anchors.fill: instructionScene.gameWindowAnchorItem
    fillMode: Image.PreserveAspectCrop
    smooth: true
  }

  // content window
  Rectangle {
    id: infoRect
    radius: 15
    anchors.centerIn: gameWindowAnchorItem
    width: gameWindowAnchorItem.width - 70
    height: gameWindowAnchorItem.height - 70
    color: "white"
    border.color: "#28a3c1"
    border.width: 2.5
  }

  // credits
  Text {
    anchors.bottom: infoRect.bottom
    anchors.bottomMargin: 5
    anchors.right: infoRect.right
    anchors.rightMargin: 15
    font.pixelSize: 6
    color: "#28a3c1"
    text: "Music: Bensound.com, Sound Effects: freesound.org"
  }

  // the header
  Text {
    anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
    horizontalAlignment: Text.AlignHCenter
    anchors.top: gameWindowAnchorItem.top
    anchors.topMargin: 60
    font.pixelSize: 20
    font.family: standardFont.name
    color: "#28a3c1"
    text: "Instructions"
  }

  // row with the main game rules
  Row {
    spacing: 25
    anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
    anchors.top: gameWindowAnchorItem.top
    anchors.topMargin: 100

    // objectives
    Column {
      spacing: 5

      Image {
        width: 60
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../assets/img/Bubble.png"
        smooth: true
      }

      Text {
        font.pixelSize: 10
        color: "#28a3c1"
        text: "Objectives"
        font.family: standardFont.name
      }

      Text {
        font.pixelSize: 9
        color: "black"
        width: 100
        wrapMode: Text.WordWrap
        text: "Get rid of all cards in your hand before your opponents. When it is your turn, match the card on the Discard pile by either number, symbol or color."
      }
    }

    // draw card
    Column {
      spacing: 5

      Image {
        width: 33
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../assets/img/Stack.png"
        smooth: true
      }

      Text {
        font.pixelSize: 10
        color: "#28a3c1"
        text: "Draw Card"
        font.family: standardFont.name
      }

      Text {
        font.pixelSize: 9
        color: "black"
        width: 100
        wrapMode: Text.WordWrap
        text: "If you do not have a matching card, you must draw one from the Draw pile. You get the chance to play the valid card before your turn ends."
      }
    }

    // ONU button
    Column {
      spacing: 5

      Image {
        width: 60
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../assets/img/ONUButton2.png"
        smooth: true
      }

      Text {
        font.pixelSize: 10
        color: "#28a3c1"
        text: "One Button"
        font.family: standardFont.name
      }

      Text {
        font.pixelSize: 9
        color: "black"
        width: 100
        wrapMode: Text.WordWrap
        text: "Press the One button before playing your second to last card. You have to pick up 2 cards from the Draw pile if you fail."
      }
    }
  }

  // switch between the scenes with swipe motions
  SwipeArea {
    anchors.fill: parent
    onSwipeRight: cardButton.clicked()
    onSwipeLeft: backButtonPressed()
  }

  // back button to leave scene
  ButtonBase {
    width: 25
    height: 25
    buttonImage.source: "../../assets/img/ArrowLeft.png"
    anchors.left: gameWindowAnchorItem.left
    anchors.leftMargin: 10
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10
    onClicked: {
      backButtonPressed()
    }
  }

  // button to cardScene
  MenuButton {
    id: cardButton
    action: "cards"
    color: "transparent"
    width: 25
    height: 25
    buttonImage.source: "../../assets/img/ArrowRight.png"
    anchors.right: gameWindowAnchorItem.right
    anchors.rightMargin: 10
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10
  }

  onVisibleChanged: {
    if(visible) {
      //  logEvent("Screen.InstructionScene")
    }
  }
}
