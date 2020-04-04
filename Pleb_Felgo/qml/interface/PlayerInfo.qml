import QtQuick 2.0
import Felgo 3.0
import "../common"

// playerInfo window show detailed information and add friend function
Item {
  id: playerInfo
  width: 400
  height: playerName.contentHeight + playerName.anchors.topMargin * 2 + infoTag.height + infoTag.anchors.topMargin
  z: 110

  property var refTag: PlayerTag
  property string rank: refTag.rank > 0 ? "#" + refTag.rank : "-"
  property alias infoTag: infoTag
  property alias closeButton: closeButton


  // window background
  Rectangle {
    id: playerRect
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

  // playerInfo player name
  Text {
    id: playerName
    horizontalAlignment: Text.AlignHCenter
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: 40
    text: infoTag.player.name
    font.family: standardFont.name
    color: "black"
    font.pixelSize: 36
    width: parent.width - anchors.topMargin * 2
    wrapMode: Text.Wrap
  }

  // playerInfo content
  Row {
    spacing: 50
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: playerName.bottom
    anchors.topMargin: 20

    // playerTag of the player
    PlayerTag {
      id: infoTag
      anchors.topMargin: 15
      transformOrigin: Item.Top
      scale: 1.5
      player: refTag.player
      infoButton.enabled: false
      avatarSource: refTag.avatarSource
      level: refTag.level
      name: ""
      width: 92 * scale
      height: 92 * scale
    }

    // detailled playerInfo text
    Text {
      id: infoText
      text: "Rank: " + rank + "\nLevel: " + refTag.level + "\nScore: " + refTag.highscore
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 20
      width: contentWidth
      anchors.verticalCenter: infoTag.verticalCenter
    }
  }

  // button to add friend
  ButtonBase {
    id: friendButton
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
    enabled: !refTag.player.isFriend && !refTag.friendRequested
    textColor: enabled ? "#28a3c1" : "lightgrey"
    visible: refTag.player != multiplayer.localPlayer

    text: {
      var requestText = refTag.friendRequested ? "Requested" : "Add Friend"
      return refTag.player.isFriend ? "Befriended" : requestText
    }

    onClicked: {
//      ga.logEvent("User", "Request Friend")
//      flurry.logEvent("User.RequestFriend")
      var message = "You have got a friendship request from Player " + gameNetwork.user.name
      gameNetwork.sendFriendRequest(refTag.player.userId, message, function(success) { })
      refTag.friendRequested = true
    }
  }

  // button to close the window
  ButtonBase {
    id: closeButton
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
    text: "Cancel"
    onClicked: {
      playerInfo.visible = false
    }
  }
}
