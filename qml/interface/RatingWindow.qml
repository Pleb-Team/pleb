import QtQuick 2.0
import Felgo 3.0
import "../common"

// window to rate the game in the app store
Item {
  id: rating
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
    id: ratingRect
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

    // rating header
    Text {
      id: ratingText
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Rate " + gameTitle
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 36
      width: parent.width * 0.8//- anchors.topMargin * 2
      wrapMode: Text.Wrap
    }

    // rating note
    Text {
      id: ratingNote
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Support " + gameTitle + "  by rating the app in the store!"
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
    text: "Close"
    onClicked: {
      // close the window
      rating.visible = false
    }
  }

  // button to rate the game
  ButtonBase {
    id: ratingButton
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
    text: "Rate"
    onClicked: {
      // open the store site to rate the game instead
      ga.logEvent("User", "Rate in Store")
      flurry.logEvent("User.RateInStore")

      nativeUtils.openUrl(Constants.ratingUrl)
      rating.visible = false
    }
  }

  // button to signal that the player has already rated the game in the store
  ButtonBase {
    anchors.top: ratingButton.bottom
    anchors.topMargin: 10
    anchors.horizontalCenter: parent.horizontalCenter
    height: (14 + buttonText.height + paddingVertical * 2)
    paddingHorizontal: 8
    paddingVertical: 4
    box.border.width: 5
    box.radius: 30
    textSize: 16
    text: "I already rated the game"
    onClicked: {
      localStorage.setValue("feedbackSent", true)
      // close the window
      rating.visible = false
    }
  }
}
