import QtQuick 2.0
import Felgo 3.0
import "../common"

// window leads to the Felgo website
Item {
  id: website
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

  // window background
  Rectangle {
    id: websiteRect
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

    // website header
    Text {
      id: websiteText
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Felgo"
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 36
      width: parent.width * 0.8
      wrapMode: Text.Wrap
    }

    // website note
    Text {
      id: websiteNote
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "This game is built with Felgo. The source code is available in the free Felgo SDK - so you can build your own card game in minutes! Visit Felgo.net now?"
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 20
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
    textSize: 28
    text: "No"
    onClicked: {
      // close the window
      website.visible = false
    }
  }

  // button to the website
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
    text: "Yes"
    onClicked: {
      // open the website instead
      ga.logEvent("User", "Felgo")
      flurry.logEvent("User.Felgo")
      nativeUtils.openUrl("https://felgo.com/onu-game-in-app/")// this is added by the wp redirect: /?utm_medium=game&utm_source=onu&utm_campaign=onu - do not add this here, because then we cant link e.g. to an anchor like showcases/#onu
      website.visible = false
    }
  }
}
