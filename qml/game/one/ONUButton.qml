import QtQuick 2.0
import Felgo 3.0
import "../../common"

// enables when the player has 2 or less cards in his hand
Item {
  id: onuButton
  width: 110
  height: 110

  property alias button: button
  property alias blinkAnimation: blinkAnimation


  // effect plays when the user activates the ONUButton
  SoundEffect {
    volume: 0.5
    id: onuSound
    source: "../../../assets/snd/onu.wav"
  }

  // button starts the fade animation when enabled changes
  ButtonBase {
    id: button
    radius: width/2
    enabled: false
    anchors.fill: parent

    onClicked: {
      // do not react to clicks if ONUButton is set invisible (= removed from the game / not available for users)
      if(onuButton.visible) {
        button.enabled = false
        onu(multiplayer.localPlayer.userId)
      }
    }

    onEnabledChanged: {
      if (enabled){
        blinkAnimation.start()
      } else {
        blinkAnimation.stop()
      }
    }
  }

  // darker deactivated button image
  Image {
    id: onuButton1
    anchors.fill: parent
    source: "../../../assets/img/ONUButton1.png"
    smooth: true
  }

  // lighter activated button image
  Image {
    id: onuButton2
    anchors.fill: parent
    source: "../../../assets/img/ONUButton2.png"
    opacity: 0
    smooth: true
  }

  // fade animation between the two button images
  SequentialAnimation {
    id: blinkAnimation
    running: false
    loops: Animation.Infinite
    alwaysRunToEnd: true

    NumberAnimation { target: onuButton2; property: "opacity"; easing.type: Easing.InOutQuad; to: 1.0; duration: 400 }
    NumberAnimation { target: onuButton2; property: "opacity"; easing.type: Easing.InOutQuad; to: 0.0; duration: 400 }
  }

  // activate the player's onu state
  function onu(userId){
    onuSound.play()
    var hand = gameLogic.getHand(userId)
    if (hand) hand.onu = true
    multiplayer.sendMessage(gameLogic.messagePressONU, {userId: userId, onu: true})
  }
}
