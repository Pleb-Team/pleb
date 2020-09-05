import Felgo 3.0
import QtQuick 2.2

import "../common"
import "../game/pleb"

// displayer username, profile image and remaining time
EntityBase {
  id: playerTag
  entityType: "playerTag"
  width: 120
  height: canvas.height + name.contentHeight + name.anchors.topMargin

  property var player: MultiplayerUser{}
  property int nPlayerIndexLegacy: -1

  property int level: 1
  property string activeColor: "#f9c336"
  property string inactiveColor: "#28a3c1"

  property alias canvas: canvas
  property alias avatar: avatar
  property alias avatarSource: avatar.source
  property alias name: name.text
  property alias nameColor: name.color
  property alias infoButton: infoButton

  // display tag of unconnected player in the main menu
  property bool menu: false

  // user gameNetwork properties
  property int highscore
  property int rank
  property bool friendRequested: player && player.isFriend ? true : false

  // circle indicating the game leader
  Rectangle {
    id: leaderMarker
    width: name.font.pixelSize * 0.75
    height: width
    radius: width * 0.5
    color: name.color
    visible: player && player.leader && !menu && name != ""
    anchors.top: canvas.bottom
    anchors.topMargin: 6
    x: (parent.width - name.implicitWidth) * 0.5 - leaderMarker.width - 6
  }

  // username text
  Text {
    id: name
    text: "Ghost"
    anchors.top: canvas.bottom
    anchors.topMargin: 3
    anchors.horizontalCenter: canvas.horizontalCenter
    // make as big that a typical player text like "Player 1234567" fits into the width
    font.pixelSize: 12
    font.bold: true
    font.family: standardFont.name
    color: player && player.isFriend ? activeColor : "white"
    width: playerTag.width - (leaderMarker.visible ? (leaderMarker.width + 6) : 0) // max width is reduced by leader marker
    wrapMode: Text.WrapAnywhere
    horizontalAlignment: Text.AlignHCenter
  }

  // canvas displays the remaining time as a circle
  Canvas {
      id: canvas
      width: 92
      height: 92
      anchors.top: parent.top
      anchors.horizontalCenter: parent.horizontalCenter
      onPaint: {
          var ctx = getContext("2d")
          ctx.reset()

          if (multiplayer.activePlayer === player)
          {
              var centreX = canvas.width / 2
              var centreY = canvas.height / 2
              var step = 360 / gameLogic.userInterval - 1

              ctx.beginPath()
              ctx.fillStyle = player.connected ? activeColor : inactiveColor
              ctx.moveTo(centreX, centreY)

              // x, y, r, startAngle, endAngle, counterclockwise
              ctx.arc(centreX, centreY, 46, 315 * Math.PI / 180, (gameLogic.userInterval - 1 - gameLogic.remainingTime) * step * Math.PI / 180, true)
              ctx.lineTo(centreX, centreY)
              ctx.fill()
          }
      }
  }

  // circular profile image
  UserImage {
    id: avatar
    width: 80
    height: 80
    anchors.centerIn: canvas
    source: getAvatar()
    locale: player && player.locale ? player.locale : ""
  }

  Image {
    height: 38
    fillMode: Image.PreserveAspectFit
    visible: ((player && player.connected) || menu) && level > 10
    anchors.top: canvas.top
    anchors.left: canvas.left
    source: {
      if (level >= 500){
        return "../../assets/img/PlatinumBadge.png"
      } else if (level >= 100){
        return "../../assets/img/GoldBadge.png"
      } else if (level >= 50){
        return "../../assets/img/SilverBadge.png"
      } else {
        return "../../assets/img/BronzeBadge.png"
      }
    }
  }

  // level circle
  Rectangle {
    width: 38
    height: 38
    color: player && player.connected || menu ? activeColor : inactiveColor
    radius: width / 2
    anchors.top: canvas.top
    anchors.right: canvas.right
    visible: player && player.connected || menu ? true : false

    // circle for auto players - unused
    Rectangle {
      visible: false
      width: 15
      height: 15
      border.width: 2
      border.color: "white"
      color: inactiveColor
      radius: width / 2
      anchors.centerIn: parent
    }

    // user level
    Text {
      id: levelText
      text: player && player.connected || menu ? level : ""
      font.bold: true
      anchors.fill: parent
      anchors.topMargin: 4 // the font has an offset - topMargin centers the text again
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      font.pixelSize: 14
      font.family: standardFont.name
      color: "white"
    }
  }

  // displays the detailed playerInfoPopup
  MouseArea {
      id: infoButton
      anchors.fill: parent
//      enabled: player && player.connected && Constants.bShowBetaFeatures ? true: false
      enabled: player && player.connected ? true: false
      onClicked: {
//          gameScene.playerInfoPopup.visible = true
//          gameScene.playerInfoPopup.refTag = playerTag
          gameScene.switchNameWindow.visible = true
      }
  }

  function getPlayerNameNice()
  {
      if (player.connected)
          return player.name
      else if (nPlayerIndexLegacy >= 0)
          return Constants.listPlayerNameDefaults[nPlayerIndexLegacy]
      else
          return "getPlayerNameNice() empty result"
  }

  // get the avatar for auto and connected users
  function getAvatar(){
    var tmpAvatar = player && player.connected ? "../../assets/img/User.png" : "../../assets/img/Auto.png"
    if (player && player.connected && player.profileImageUrl.length > 0){
      tmpAvatar = player.profileImageUrl
    }
    return tmpAvatar
  }

  // reset the tag at the beginning of the game
  function initTag(player_, nPlayerIndexLegacy_)
  {
      player = player_
      nPlayerIndexLegacy = nPlayerIndexLegacy_
      name.text = getPlayerNameNice()
      canvas.requestPaint()
  }

  /*
     Explanation for sendToOthers:
     This function is used in two cases:

     1. In the beginning of the game in initGame(). The local user accesses their leaderboard and saves and calculates highscore, rank and level.
        He initializes his own tag and sends the information to the other players (sendToOthers true). He also receives the information of the other players.

     2. At the end of the game in endGame() after updating the highscore of the local user with the calculated points.
        The local user saves his current level in a variable and recalculates it with his new highscore. There's no need to send the update to the other players (sendToOthers false).
        If the values differ, it means he levelled up.
  */
  function getPlayerData(sendToOthers){
    gameNetwork.sync()

    // Warning: may return only one value for multiple desktop test users
    var highScore = gameNetwork.userHighscoreForLeaderboard()
    var level = 1
    if (highScore > 0){
      // the player has to win 300 games with about 100 points to reach the maximum level
      level = Math.floor(highScore / 300)
      // the level is between 1 and 999
      level = Math.max(1, Math.min(level, 999))
      playerTag.level = level
    }

    highscore = gameNetwork.userHighscoreForCurrentActiveLeaderboard
    rank = gameNetwork.userPositionForCurrentActiveLeaderboard

    if (sendToOthers){
      multiplayer.sendMessage(gameLogic.messageSetPlayerInfo, {userId: multiplayer.localPlayer.userId, level: level, highscore: highscore, rank: rank})
    }
  }
}
