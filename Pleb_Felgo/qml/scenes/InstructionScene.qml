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
    border.color: Constants.sBorderColor
    border.width: 1
  }


  // row with the main game rules
  Row {
    spacing: 20
    anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
    anchors.top: gameWindowAnchorItem.top
    anchors.topMargin: 60

    // objectives
    Column {
      spacing: 5

      Image {
        width: 45
        height: 45
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
        width: 120
        wrapMode: Text.WordWrap
        text: "Become president and be the first to get rid of all cards in your hand! Or be the last to finish and be the pleb. At the start of each game, the pleb has to pass his or her 2 highest cards to the president, who in turn discards 2 arbitrary (usually lowest) cards back to the pleb [not yet implemented]."
      }
    }

    // draw card
    Column {
      spacing: 5

      Image {
        width: 24
        height: 45
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../assets/img/Stack.png"
        smooth: true
      }

      Text {
        font.pixelSize: 10
        color: "#28a3c1"
        text: "Rules"
        font.family: standardFont.name
      }

      Text {
        font.pixelSize: 9
        color: "black"
        width: 120
        wrapMode: Text.WordWrap
        text: "Upon fresh start, you may freely play 1,2,3 or 4 cards of the same value (e.g. one 8 or triple Queen). Else, play the same amount of cards, but exceed the value on the discard pile. If you can't or don't want to play, you pass. If everyone passes, the last player can restart freshly. "
      }
    }

    // ONU button
    Column {
      spacing: 5

      Image {
        width: 45
        height: 45
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../assets/img/ONUButton2.png"
        smooth: true
      }

      Text {
        font.pixelSize: 10
        color: "#28a3c1"
        text: "How to play"
        font.family: standardFont.name
      }

      Text {
        font.pixelSize: 9
        color: "black"
        width: 120
        wrapMode: Text.WordWrap
        text: "Upon your turn, possible cards are highlighted in yellow. Select your move by tapping the cards which will become green. Tab screen center to play. Select nothing and tap center to pass."
      }
    }
  }

  // switch between the scenes with swipe motions
//  SwipeArea {
//    anchors.fill: parent
//    onSwipeRight: cardButton.clicked()
//    onSwipeLeft: backButtonPressed()
//  }

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
//    color: "transparent"
    width: 25
    height: 25
    buttonImage.source: "../../assets/img/ArrowRight.png"
    anchors.right: gameWindowAnchorItem.right
    anchors.rightMargin: 10
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10
  }
}
