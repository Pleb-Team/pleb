import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../common"

Item {
  id: switchNameWindow
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

  Rectangle {
      radius: 30
      anchors.fill: parent
      color: "white"
      border.color: "#28a3c1"
      border.width: Constants.nBorderWidth
  }

  Column {
      id: content
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.margins: 40
      spacing: 20

      Text {
          id: headerText
          horizontalAlignment: Text.AlignHCenter
          anchors.horizontalCenter: parent.horizontalCenter
          text: "Hey buddy, what's your name?"
          font.family: standardFont.name
          color: "black"
          font.pixelSize: 36
          width: parent.width * 0.8
          wrapMode: Text.Wrap
      }

      // set username hint
      Text {
          id: hintText
          horizontalAlignment: Text.AlignHCenter
          anchors.horizontalCenter: parent.horizontalCenter
          text: "You can compare your score with other players around the world in the leaderboards.\nPlease enter your name:"
          font.family: standardFont.name
          color: "black"
          font.pixelSize: 20
          width: parent.width * 0.8
          wrapMode: Text.Wrap
      }

      // TextInput line with validator
      TextField {
          id: inputText
          anchors.horizontalCenter: parent.horizontalCenter
          width: parent.width * 0.6

          horizontalAlignment: Text.AlignHCenter
          font.pixelSize: 30
          maximumLength: 16
          placeholderText: focus ? "" : gameNetwork.user.name
          inputMethodHints: Qt.ImhNoPredictiveText
          validator: RegExpValidator{regExp: /^[a-zA-Z0-9äöüßÄÖÜß_ -]{3,}$/}

          // TextFieldStyle formatting the background of inputText
          style: TextFieldStyle {
              textColor: "black"
              background: Rectangle {
                  radius: height
                  color: "#3028a3c1"
                  anchors.margins: -4
              }
          }

          // disable and reset the inputField when closed
          onVisibleChanged: {
              readOnly = visible ? false : true
              if (!visible) focus = false
              text = ""
          }

          // check, send and reset the text after hitting enter
          onAccepted: inputTextAccepted()
      }
  }

  // button Cancel
  ButtonBase {
      anchors.left: parent.left
      anchors.top: parent.bottom
      anchors.topMargin: 10
      width: parent.width / 2 - anchors.topMargin / 2
      height: (20 + buttonText.height + paddingVertical * 2)
      paddingHorizontal: 8
      paddingVertical: 4
      box.border.width: Constants.nBorderWidth
      box.radius: 30
      textSize: 28
      text: "Cancel"
      onClicked: switchNameWindow.visible = false
  }

  // button OK
  ButtonBase {
      anchors.right: parent.right
      anchors.top: parent.bottom
      anchors.topMargin: 10
      width: parent.width / 2 - anchors.topMargin / 2
      height: (20 + buttonText.height + paddingVertical * 2)
      paddingHorizontal: 8
      paddingVertical: 4
      box.border.width: Constants.nBorderWidth
      box.radius: 30
      textSize: 28
      text: "Ok"

      onClicked: inputTextAccepted()
  }


  function inputTextAccepted()
  {
      if (!inputText.text)
          return

      // Update name in all storage locations
      var set = gameNetwork.updateUserName(inputText.text)
      playerHands.children[0].player.nickName = inputText.text
      menuScene.localStorage.setPlayerName(inputText.text)

      playerTags.children[0].updateTag()

      if (set)
          switchNameWindow.visible = false
      else
          nativeUtils.displayMessageBox(qsTr("Invalid username"))

  }
}
