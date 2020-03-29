import QtQuick 2.0
import "../common"
import "../scenes"

// facebook connection popup
Item {
  id: connectFacebook
  width: 400
  height: content.height + content.anchors.topMargin * 2
  z: 110

  signal connectFacebookClicked

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

    // message text
    Text {
      id: facebookHeader
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Connect with Facebook"
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 32
      width: parent.width * 0.8
      wrapMode: Text.Wrap
    }

    // message details
    Text {
      id: facebookDetails
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Play together with your friends!"
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 18
      width: parent.width * 0.8
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
    textSize: 24
    text: "Cancel"

    onClicked: connectFacebook.visible = false
  }

  // button to connect with facebook
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
    textSize: 24
    text: "Connect"

    onClicked: {
      ga.logEvent("User", "Connect Facebook")
      flurry.logEvent("User.ConnectFacebook")
      gameNetwork.connectFacebookUser()
      gameNetwork.showProfileView()
      window.state = "gn"
      connectFacebook.visible = false
      connectFacebookClicked() // trigger signal that user clicked connect
    }
  }
}
