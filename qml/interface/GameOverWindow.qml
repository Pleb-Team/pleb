import QtQuick 2.0
import "../common"

// gameOver message with winner and score
Item {
  id: gameOver
  width: 400
  height: content.height + content.anchors.topMargin * 2
  z: 110

  property int level: 99
  property var winner
  property string winnerName: winner? winner.name : "Someone"
  property int score

  property alias levelText: levelText

  // don't send the black bg here because we want to encourage adding friends and chatting after a match
  // message background
  Rectangle {
    radius: 30
    anchors.fill: parent
    color: "white"
    border.color: "#28a3c1"
    border.width: 5

    // catch the mouse clicks
    MouseArea {
      anchors.fill: parent
    }
  }

  Column {
    id: content
    width: parent.width
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.margins: 40
    spacing: 20

    // message text
    Text {
      id: winnerText
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "The winner is <font color=\"#28a3c1\">" + winnerName + "</font>"
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 36
      width: parent.width * 0.8
      wrapMode: Text.Wrap
    }

    Text {
      id: scoreText
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: gameOver.visible ? playerHands.children[0].player.name + ": " + getScore(0) + "<br>"
                               + playerHands.children[1].player.name + ": " + getScore(1) + "<br>"
                               + playerHands.children[2].player.name + ": " + getScore(2) + "<br>"
                               + playerHands.children[3].player.name + ": " + getScore(3) : ""
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 20
      width: parent.width * 0.8
      wrapMode: Text.Wrap
    }

    Text {
      id: levelText
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Congratulations, you've reached level " + level + "!"
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 20
      width: parent.width * 0.8
      wrapMode: Text.Wrap
      visible: false
    }

    Text {
      id: hintText
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Wait for the leader to start a new match!"
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 20
      width: parent.width * 0.8
      wrapMode: Text.Wrap
      visible: !multiplayer.amLeader
    }
  }

  // lets the leader restart the game
  ButtonBase {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.bottom
    anchors.topMargin: 10
    height: (20 + buttonText.height + paddingVertical * 2)
    paddingHorizontal: 8
    paddingVertical: 4
    box.border.width: 5
    box.radius: 30
    textSize: 28
    text: "New Game"
    visible: multiplayer.amLeader
    onClicked: {
      gameLogic.startNewGame()
    }
  }

  // get the score of a player with their array index
  function getScore(index){
    return playerHands.children[index].score
  }
}
