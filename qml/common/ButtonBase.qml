import QtQuick 2.0

Rectangle {
  id: button

  color: "transparent"
  width: buttonText.contentWidth + 60
  height: 4 + buttonText.height + paddingVertical * 2
  property int paddingHorizontal: notification > 0 ? notificationRect.width/2+4:4
  property int paddingVertical: 4

  // called when the button is clicked
  signal clicked

  // button properties
  property alias buttonImage: buttonImage
  property alias buttonText: buttonText
  property alias text: buttonText.text
  property alias textColor: buttonText.color
  property alias textSize: buttonText.font.pixelSize
  property alias backgroundColor: button.color
  property alias box: box
  property alias mouseArea: mouseArea

  property int notification: 0


  // show the box when the button has text
  Rectangle {
    id: box
    radius: 15
    color: "white"
    border.color: "#28a3c1"
    border.width: 2.5
    visible: text !== ""
    anchors.fill: parent
  }

  // button with image instead of text
  Image {
    id: buttonImage
    source: ""
    anchors.fill: parent
    smooth: true
  }

  // button text content
  Text {
    id: buttonText
    font.pixelSize: 14
    font.family: standardFont.name
    color: "#28a3c1"
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: notification > 0 ? undefined: parent.horizontalCenter
    x: notification > 0 ? 2 : 0
  }

  // clickable button area
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    onClicked: button.clicked()
    onPressed: if (buttonImage.source == "") button.opacity = 0.8
    onReleased: if (buttonImage.source == "")  button.opacity = 1

    anchors.margins: -2
  }

  // rectangle with notifications
  Rectangle{
    id: notificationRect
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: "#f9c336"
    width: 15
    height: 15
    radius: 40
    visible: notification > 0

    Text{
      font.pixelSize: 10
      font.bold: true
      anchors.centerIn: parent
      text: notification
      color: "white"
    }
  }
}
