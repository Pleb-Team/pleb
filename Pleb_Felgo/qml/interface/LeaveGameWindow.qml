import QtQuick 2.0
import "../common"

// leaveGame window when trying to exit the game
Item {
  id: leaveGame
  width: 400
  height: content.height + content.anchors.topMargin * 2
  z: 110


  // dark background
  Rectangle {
    anchors.centerIn: parent
    width: gameScene.width * 2
    height: gameScene.height * 2
    color: "black"
    opacity: 0.3

    // catch the mouse clicks
    MouseArea {
      anchors.fill: parent
    }
  }

  // message background
  Rectangle {
    id: leaveRect
    radius: 30
    anchors.fill: parent
    color: "white"
    border.color: "#28a3c1"
    border.width: 5
  }

  Column {
    id: content
    width: parent.width
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.margins: 40
    spacing: 20

    // leave text
    Text {
      id: leaveText
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Do you really want to quit the game?"
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 36
      width: parent.width * 0.8//- anchors.topMargin * 2
      wrapMode: Text.Wrap
    }

    // points lost text
    Text {
      id: pointsText
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "All your points from the last match will be lost."
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 20
      width: parent.width * 0.8//- 20
      wrapMode: Text.Wrap
    }
  }

  // button to close the window
  ButtonBase {
    anchors.left: parent.left
    anchors.top: parent.bottom
    anchors.topMargin: 10
    width: parent.width / 2 - anchors.topMargin / 2
    height: (20 + buttonText.height + paddingVertical * 2)
    paddingHorizontal: 8
    paddingVertical: 4
    box.border.width: 5
    box.radius: 30
    textSize: 28
    text: "Cancel"
    onClicked: leaveGame.visible = false
  }

  // button to leave the game
  ButtonBase {
    anchors.right: parent.right
    anchors.top: parent.bottom
    anchors.topMargin: 10
    width: parent.width / 2 - anchors.topMargin / 2
    height: (20 + buttonText.height + paddingVertical * 2)
    paddingHorizontal: 8
    paddingVertical: 4
    box.border.width: 5
    box.radius: 30
    textSize: 28
    text: "Quit Game"
    onClicked: {
      gameLogic.leaveGame()
      backButtonPressed()
      leaveGame.visible = false
    }
  }
}
