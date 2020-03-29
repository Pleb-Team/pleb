import QtQuick 2.0
import QtQuick.Controls 1.3

Item {
  id: sconsole

  // console background
  Rectangle {
    anchors.fill: parent
    radius: 15
    color: "white"
    border.color: "#28a3c1"
    border.width: 2.5
  }

  // console scrollable content
  ScrollView {
    id: scrollView
    anchors.fill: parent
    anchors.margins: 8
    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
    flickableItem.boundsBehavior: Flickable.StopAtBounds
    flickableItem.flickableDirection: Flickable.VerticalFlick
    //flickableItem.interactive: false

    Text {
      id: text
      color: "black"
      font.pixelSize: 16
      text: ""
      width: sconsole.width - 40
      wrapMode: Text.WrapAnywhere
    }

    function scrollToBottom() {
      var rawOffset = scrollView.flickableItem.contentHeight - scrollView.height
      var correctedOffset = rawOffset >= 0 ? rawOffset : 0
      scrollView.flickableItem.contentY = correctedOffset
    }
  }

  function printLn(string) {    
    ga.logEvent("User", "Chat Message")
    flurry.logEvent("User.ChatMessage")

    // unless this is the first line, add a newline
    if (text.text.length > 0) {
      text.text += "\n"
    }

    // add our string
    text.text += string
    scrollView.scrollToBottom()
  }

  function clear() {
    text.text = ""
    scrollView.scrollToBottom()
  }
}
