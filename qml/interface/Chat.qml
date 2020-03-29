import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../common" as Common

// chat for multiple users
Item {
  id: chat

  // access chat items from the outside
  property alias chatButton: chatButton
  property alias gConsole: gConsole
  property alias inputText: inputText


  // top box displays chat history
  Common.GConsole {
    id: gConsole
    height: parent.height - inputWindow.height
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    visible: false
  }

  // bottom box with input field and background
  Rectangle {
    id: inputWindow
    height: 50
    width: parent.width - 20
    anchors.top: gConsole.bottom
    radius: 15
    color: "white"
    border.color: "#28a3c1"
    border.width: 2.5
    visible: false

    // MouseArea covers the inputWindow and focuses the inputText when clicked
    MouseArea {
      anchors.fill: parent
      anchors.margins: -25
      enabled: !inputText.focus
      onClicked: inputText.focus = true
    }

    // TextInput line with maximum contentWidth and validator
    TextField {
      id: inputText
      anchors.verticalCenter: inputWindow.verticalCenter
      anchors.left: inputWindow.left
      anchors.leftMargin: 8
      font.pixelSize: 16
      width: parent.width - 40
      maximumLength: 200
      placeholderText: "Write something..."
      style: TextFieldStyle {background: null; textColor: "black" }
      inputMethodHints: Qt.ImhNoPredictiveText
      validator: RegExpValidator{regExp: /^[a-zA-Z0-9äöüßÄÖÜ;,:._'#+*~@€<>|?ß=()/&%!°^" -]+$/}

      // disable and reset the inputField when closed
      onVisibleChanged: {
        readOnly = visible ? false : true
        if (!visible) focus = false
        text = ""
      }

      // check, send and reset the text after hitting enter
      onAccepted: {
        if (text){
          var message = multiplayer.localPlayer.name + ": " + text
          gConsole.printLn(message)
          multiplayer.sendMessage(gameLogic.messagePrintChat, message)
          text = ""
          maximumLength = 100
        }
      }
    }
  }

  // open/close chat and display different chat images
  Common.ButtonBase {
    id: chatButton
    color: "transparent"
    anchors.bottom: inputWindow.bottom
    anchors.bottomMargin: inputWindow.visible ? 0 : -5
    anchors.right: inputWindow.right
    anchors.rightMargin: inputWindow.visible ? -20 : -22
    width: inputWindow.visible ? inputWindow.height : 60
    height: inputWindow.visible ? width : 60
    buttonImage.source: "../../assets/img/Messages.png"
    onClicked: {
      buttonImage.source = !inputWindow.visible ? "../../assets/img/Chat1.png" : "../../assets/img/Messages.png"
      gConsole.visible ^= true
      inputWindow.visible ^= true
    }
  }

  // reset the chat by clearing and closing it
  function reset (){
    gConsole.visible = false
    inputWindow.visible = false
    chatButton.buttonImage.source = "../../assets/img/Messages.png"
  }
}
