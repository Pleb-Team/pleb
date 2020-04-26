import QtQuick 2.0
import Felgo 3.0
import "../common"

// window leads to the Pleb repo
Item {
  id: websiteWindow
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

    // repo header
    Text {
      id: websiteText
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Pleb"
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 36
      width: parent.width * 0.8
      wrapMode: Text.Wrap
    }

    // repo note
    Text {
      id: websiteNote
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Visit the Pleb repository on GitHub now?"
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
      websiteWindow.visible = false
    }
  }

  // button to the repo
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
      // open the repo websiteWindow instead
//      ga.logEvent("User", "Felgo")
//      flurry.logEvent("User.Felgo")
      nativeUtils.openUrl("https://github.com/Pleb-Team/pleb")
      websiteWindow.visible = false
    }
  }

}
