import QtQuick 2.0
import "../common"

// gameOver window with winner and score
Item {
  id: gameOverWindow
  width: 500
  height: content.height + content.anchors.topMargin * 2
  z: 110

  property int level: 99
  property int nPlayerIndexPrasei: -1

  // don't send the black bg here because we want to encourage adding friends and chatting after a match
  // message background
  Rectangle {
    radius: 30
    anchors.fill: parent
    color: "white"
    border.color: "#28a3c1"
    border.width: Constants.nBorderWidth

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

      text: nPlayerIndexPrasei >= 0 ? "The winner is: <font color=\"" + Constants.sBorderColor + "\">" + playerHands.children[nPlayerIndexPrasei].playerTag.getPlayerNameNice() + "</font>" : "Error: nPlayerIndexPrasei not set"
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 30
      width: parent.width * 0.8
      wrapMode: Text.Wrap
    }

    Text {
      id: scoreText
      horizontalAlignment: Text.AlignRight
      anchors.horizontalCenter: parent.horizontalCenter
      text: ""
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 20
      width: parent.width * 0.8
      wrapMode: Text.Wrap
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
      box.border.width: Constants.nBorderWidth
      box.radius: 30
      textSize: 28
      text: "New Game"
      visible: multiplayer.amLeader
      onClicked: {
          gameLogic.initGame(true)
      }
  }

  function calcText()
  {
      var result = ""
      var sColor = ""
      var highestScoreAllGames = getHighestScoreAllGames()

      for (var n = 0; n < playerHands.children.length; n++)
      {
          if (playerHands.children[n].scoreAllGames === highestScoreAllGames)
              sColor = Constants.sBorderColor
          else
              sColor = "black"

          result = result + playerHands.children[n].playerTag.getPlayerNameNice()
                  + ": " + playerHands.children[n].score + " points"
                  + ", <font color=\"" + sColor + "\">Total score: "
                  + playerHands.children[n].scoreAllGames + "</font><br>"
      }

      scoreText.text = result
  }


  // get the score of a player with their array index
  function getHighestScoreAllGames()
  {
      var result = 0;

      for (var n = 0; n < playerHands.children.length; n++)
          result = Math.max(result, playerHands.children[n].scoreAllGames)

      return result
  }

}
