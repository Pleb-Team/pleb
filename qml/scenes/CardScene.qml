import Felgo 3.0
import QtQuick 2.0
import "../common"

// scene describes the main card types
SceneBase {
  id: cardScene

  signal menuButtonPressed(string button)


  // background
  Image {
    id: background
    source: "../../assets/img/BG.png"
    anchors.fill: cardScene.gameWindowAnchorItem
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
    text: "Fonts: 1001FreeFonts.com, kamarashev.deviantart.com"
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
    text: "Cards"
  }

  // a row describing the main card types
  Row {
    spacing: 13
    anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
    anchors.top: gameWindowAnchorItem.top
    anchors.topMargin: 100

    // skip card
    Column {
      spacing: 5

      Image {
        width: 37
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../assets/img/cards/one/skip_red.png"
        smooth: true
      }

      Text {
        font.pixelSize: 10
        color: "#28a3c1"
        text: "Skip"
        font.family: standardFont.name
      }

      Text {
        font.pixelSize: 9
        color: "black"
        width: 65
        wrapMode: Text.WordWrap
        text: "The next player is skipped and unable to play a card."
      }
    }

    // reverse card
    Column {
      spacing: 5

      Image {
        width: 37
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../assets/img/cards/one/reverse_red.png"
        smooth: true
      }

      Text {
        font.pixelSize: 10
        color: "#28a3c1"
        text: "Reverse"
        font.family: standardFont.name
      }

      Text {
        font.pixelSize: 9
        color: "black"
        width: 65
        wrapMode: Text.WordWrap
        text: "Changes the current turn order."
      }
    }

    // draw2 card
    Column {
      spacing: 5

      Image {
        width: 37
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../assets/img/cards/one/draw2_red.png"
        smooth: true
      }

      Text {
        font.pixelSize: 10
        color: "#28a3c1"
        text: "Draw Two"
        font.family: standardFont.name
      }

      Text {
        font.pixelSize: 9
        color: "black"
        width: 65
        wrapMode: Text.WordWrap
        text: "The next player must draw 2 cards and end their turn unless they can play another Draw Two card."
      }
    }

    // wild and wild4 cards
    Column {
      spacing: 5

      Image {
        width: 74
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../assets/img/Wilds.png"
        smooth: true
      }

      Text {
        font.pixelSize: 10
        color: "#28a3c1"
        text: "Wild &\nWild Draw Four"
        font.family: standardFont.name
      }

      Text {
        font.pixelSize: 9
        color: "black"
        width: 150
        wrapMode: Text.WordWrap
        text: "The player gets to choose the color of the card. It can be played at any time.\nThe next player must draw 4 cards and end their turn unless they can play another Wild Draw Four card."
      }
    }
  }

  // switch between the scenes with swipe motions
  SwipeArea {
    anchors.fill: parent
    onSwipeRight: menuButton.clicked()
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

  // button to main menu
  MenuButton {
    id: menuButton
    action: "menu"
    color: "transparent"
    width: 25
    height: 25
    buttonImage.source: "../../assets/img/Exit.png"
    anchors.right: gameWindowAnchorItem.right
    anchors.rightMargin: 10
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10
  }

  onVisibleChanged: {
    if(visible) {
//      ga.logScreen("CardScene")
//      flurry.logEvent("Screen.CardScene")
    }
  }
}
