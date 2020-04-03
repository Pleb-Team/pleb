import QtQuick 2.0
import "../common"

// custom popup dialog
Item {
  id: dialog
  width: 400 * _internalScale
  height: content.height + content.anchors.topMargin * 2 + buttons.height + buttons.spacing * options.length
  anchors.centerIn: parent
  z: 110

  property alias title: titleText.text
  property alias description: descriptionText.text
  property var options: ["Quit Game", "Cancel"]

  property real _internalScale: 0.5 * menuScene.xScaleForScene // scale to match with dialogs of gameScene
  property Item backgroundTargetItem: dialog.parent

  signal optionSelected(int index)

  // dark background
  Rectangle {
    width: backgroundTargetItem.width
    height: backgroundTargetItem.height
    anchors.centerIn: parent
    color: "black"
    opacity: 0.3
    MouseArea { anchors.fill:  parent } // catch clicks
  }

  // dialog window
  Rectangle {
    id: dialogWindow
    radius: 30 * _internalScale
    width: parent.width
    height: content.height + content.anchors.topMargin * 2
    color: "white"
    border.color: "#28a3c1"
    border.width: 5 * _internalScale

    // content
    Column {
      id: content
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.margins: 40 * _internalScale
      spacing: 20 * _internalScale

      // title text
      Text {
        id: titleText
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Do you really want to quit the game?"
        font.family: standardFont.name
        color: "black"
        font.pixelSize: 36 * _internalScale
        width: parent.width * 0.8//- anchors.topMargin * 2
        wrapMode: Text.Wrap
        visible: text !== ""
      }

      // description text
      Text {
        id: descriptionText
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text: "All your points from the last match will be lost."
        font.family: standardFont.name
        color: "black"
        font.pixelSize: 20 * _internalScale
        width: parent.width * 0.8//- 20
        wrapMode: Text.Wrap
        visible: text !== ""
      }
    }
  }

  // dialog buttons
  Flow {
    id: buttons
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: dialogWindow.bottom
    anchors.topMargin: 10 * _internalScale
    width: dialogWindow.width
    spacing: 10 * _internalScale

    Repeater {
      model: options
      delegate: ButtonBase {
        width: dialogWindow.width
        height: 20 * _internalScale + buttonText.height + paddingVertical * 2
        paddingHorizontal: 8 * _internalScale
        paddingVertical: 4 * _internalScale
        box.border.width: 5 * _internalScale
        box.radius: 30 * _internalScale
        textSize: 28 * _internalScale
        text: modelData
        onClicked: optionSelected(index)
      }
    }
  }
}
