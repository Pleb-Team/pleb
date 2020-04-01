import QtQuick 2.0
import "../common"

// window to like or dislike the game
Item {
  id: like
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
    id: likeRect
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

    // like text
    Text {
      id: likeText
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Do you like this game?"
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 36
      width: parent.width * 0.8//- anchors.topMargin * 2
      wrapMode: Text.Wrap
    }
  }

  // button to dislike the game
  ButtonBase {
    anchors.left: parent.left
    anchors.top: parent.bottom
    anchors.topMargin: 10
    width: parent.width / 2 - anchors.topMargin / 2
    height: 120
    paddingHorizontal: 8
    paddingVertical: 4
    box.border.width: 5
    box.radius: 30
    textSize: 28
    text: " "

    buttonImage.source: "../../assets/img/RedThumb.png"
    buttonImage.anchors.margins: 15
    buttonImage.fillMode: Image.PreserveAspectFit

    onClicked: {
//      ga.logEvent("User", "Dislike ONU")
//      flurry.logEvent("User.DislikeONU")

      // open the feedback window instead
      like.visible = false
      feedback.visible = true
    }
  }

  // button to like the game
  ButtonBase {
    anchors.right: parent.right
    anchors.top: parent.bottom
    anchors.topMargin: 10
    width: parent.width / 2 - anchors.topMargin / 2
    height: 120
    paddingHorizontal: 8
    paddingVertical: 4
    box.border.width: 5
    box.radius: 30
    textSize: 28
    text: " "

    buttonImage.source: "../../assets/img/GreenThumb.png"
    buttonImage.anchors.margins: 15
    buttonImage.fillMode: Image.PreserveAspectFit

    onClicked: {
      // open the rating window instead
//      ga.logEvent("User", "Like ONU")
//      flurry.logEvent("User.LikeONU")

      like.visible = false
      rating.visible = true
    }
  }
}
