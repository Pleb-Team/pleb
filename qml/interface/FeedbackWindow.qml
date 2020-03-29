import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Felgo 3.0
import "../common"

// feedback window to contact Felgo
Item {
  id: feedback
  width: 400
  height: content.height + content.anchors.topMargin * 2
  z: 110

  property string originalHintText: feedbackInput.visible ?
                                      "Your feedback helps us to improve " + gameTitle
                                    : "You can also add your email address so we can reply to you."


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
      onClicked: {
        emailInput.focus = false
        feedbackInput.focus = false
      }
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

    // feedback header
    Text {
      id: headerText
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Send Feedback"
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 36
      width: parent.width * 0.8
      wrapMode: Text.Wrap
    }

    // feedback note
    Text {
      id: hintText
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: originalHintText
      font.family: standardFont.name
      color: "black"
      font.pixelSize: 18
      width: parent.width * 0.8
      wrapMode: Text.Wrap
    }

    // TextInput line with validator
    TextField {
      id: emailInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width * 0.8
      visible: !feedbackInput.visible

      horizontalAlignment: Text.AlignHCenter
      font.pixelSize: 20
      maximumLength: 200
      placeholderText: focus ? "" : "Your email (optional)"
      inputMethodHints: Qt.ImhNoPredictiveText
      validator: RegExpValidator{regExp: /^[a-zA-Z0-9äöüßÄÖÜ;,:._'#+*~@€<>|?ß=()/&%!°^" -]+$/}

      // TextFieldStyle formatting the background of emailInput
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

      onAccepted: {
        checkEmail()
      }

      // check whether the email input is correct or not
      // has to be either empty or 4+ symbols with one of them being @
      function checkEmail(){
        if (!text || (text.match(/[@]/i) && text.length >= 4)){
          // @ found
          hintText.text = originalHintText
          return true
        } else {
          hintText.text = "Invalid email address!"
          return false
        }
      }
    }

    // multiple TextInput lines with validator
    TextArea {
      id: feedbackInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width * 0.8
      height: emailInput.height * 3
      wrapMode: Text.WrapAnywhere
      text: placeHolder

      horizontalAlignment: Text.AlignHCenter
      font.pixelSize: 20
      inputMethodHints: Qt.ImhNoPredictiveText
      style: TextAreaStyle {backgroundColor: "transparent"; textColor: "black" }

      focus: false

      property string placeHolder: "Click here to add your feedback!"

      // disable and reset the inputField when closed
      onVisibleChanged: {
        readOnly = visible ? false : true
        if (!visible) {
          focus = false
        }
      }

      onFocusChanged: {
        console.debug("Focus changed: " + focus + ", Text: " + text)
        if (focus && text == placeHolder){
          feedbackInput.remove(0, text.length)
        } else if (!focus && text == ""){
          feedbackInput.append(placeHolder)
        }
      }

      // check whether the email input is correct or not
      // has to be 3+ symbols
      function checkFeedback(){
        if (text && actualInput(text) && text != placeHolder){
          hintText.text = originalHintText
          return true
        } else {
          hintText.text = "Please enter your feedback!"
          return false
        }
      }

      // check whether the feedback contains three or more actual characters or only spaces
      function actualInput(inputString){
        // remove spaces and breaks
        var trimmedString = inputString.replace(/^\s*/, "").replace(/\s*$/, "")
        if (trimmedString.length >= 3){
          // the trimmed string is more than 3 characters long
          return true
        } else {
          // the trimmed string is less than 3 characters long
          return false
        }
      }
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
      feedback.visible = false
    }
  }

  // button to send the feedback to Felgo
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
    text: "Send"

    onClicked: {
      // close the feedback window and send the feedback
      // don't continue if the email was incorrect
      if (!emailInput.checkEmail() || !feedbackInput.checkFeedback()){
        return
      }

      if (feedbackInput.visible){
        feedbackInput.visible = false
        hintText.text = originalHintText
      }

      // check if there has been feedback and send it to Felgo
      else if (feedbackInput.text){
        ga.logEvent("User", "Send Feedback")
        flurry.logEvent("User.SendFeedback")

        // send the enteredText and the optional email to Felgo
        //nativeUtils.sendEmail("support@felgo.com", gameTitle + " Feedback", "What do you think about" + gameTitle + "? What do you like, what are you missing?\nPlease add your feedback here:\n\n")

        var feedbackContent = feedbackInput.text + "\n\n" +
            "\nApp Starts: " + appStarts +
            "\nGames Played: " + gamesPlayed +
            "\nApp VersionCode: " + system.appVersionCode +
            "\nPlatform: " + Qt.platform.os +
            "\nosType: " + system.osType +
            "\nosVersion: " + system.osVersion +
            "\nDeviceModel: " + nativeUtils.deviceModel() +
            "\nFelgo Version: " + system.vplayVersion +
            "\nUDID: " + system.UDID +
            "\nGameNetwork UserId: " + gameNetwork.user.userId +
            "\nGameNetwork Username: " + gameNetwork.userName

        console.debug("Feedback: " + feedbackContent + "; email: " + emailInput.text)
        sendFeedback(feedbackContent, emailInput.text)

        localStorage.setValue("feedbackSent", true)
        feedback.visible = false
      } else {
        hintText.text = "Please enter your opinion!"
      }
    }
  }

  onVisibleChanged: {
    feedbackInput.visible = true
    feedbackInput.text = feedbackInput.placeHolder
  }

  // sendFeedback - uses XMLHttpRequest object to send the feedback to the Felgo servers
  function sendFeedback(feedback, email) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        console.debug("Successfully sent feedback to Felgo, response:", xhr.responseText)
      }
    }
    xhr.open("POST", "https://felgo.com/terminal/creator/support.php", true)
    xhr.setRequestHeader("Content-Type", "application/json")
    xhr.setRequestHeader("Accept", "application/json")
    var send = { "shared_secret": Constants.feedbackSecret, "subject": gameTitle + " Feedback", "message": feedback, "name": "", "from": email }
    console.debug("sending this feedback request:", JSON.stringify(send))
    xhr.send(JSON.stringify(send))
  }
}
