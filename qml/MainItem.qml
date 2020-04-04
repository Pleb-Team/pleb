import QtQuick 2.0
import Felgo 3.0
import "common"
import "scenes"
import "interface"

Item {
  id: mainItem
  width: window.width
  height: window.height

  // set up properties to access scenes
  property alias menuScene: menuScene
  property alias gameScene: gameScene
  property alias instructionScene: instructionScene
  property alias cardScene: cardScene
  property alias matchmakingScene: matchmakingScene
  property alias gameNetworkScene: gameNetworkScene
  property alias storeScene: storeScene

  // menu scene
  MenuScene {
    id: menuScene

    // switch scenes after pressing a MenuButton
    onMenuButtonPressed: {
      // calculate time until bonus
      var timeUntilBonus = getTimeUntilBonus()
      var timeUntilBonusStr = (timeUntilBonus.hours !== 0 ? timeUntilBonus.hours+" Hours" : timeUntilBonus.minutes !== 0 ? timeUntilBonus.minutes+ " Minutes" : timeUntilBonus.seconds+ " Seconds")

      switch (button){
      case "single":
          multiplayer.createSinglePlayerGame()
          window.state = "game"
        break
      case "matchmaking":
          multiplayer.showMatchmaking()
          window.state = "multiplayer"
        break
      default:
        window.state = button
      }
    }

    // needed to only quit the app if the messagebox opened was the quit confirmation dialog
    property bool shownQuitDialog: false

    // the menu scene is our start scene, so if back is pressed there we ask the user if he wants to quit the application
    Keys.onBackPressed: {
      menuScene.shownQuitDialog = true
      nativeUtils.displayMessageBox(qsTr("Really quit the game?"), "", 2)
    }

    // listen to the return value of the MessageBox
    Connections {
      target: nativeUtils
      onMessageBoxFinished: {
        // only quit if coming from the quit dialog, e.g. the GameNetwork might also show a messageBox
        if (accepted && menuScene.shownQuitDialog) {
          Qt.quit()
        }
        menuScene.shownQuitDialog = false
      }
    }
  }

  // game scene
  GameScene {
    id: gameScene
    onBackButtonPressed: {
      if(!gameScene.leaveGame.visible && !noTokenDialog.visible)
        gameScene.leaveGame.visible = true
      else {
        adMobInterstitial.displayInterstitial(true, false, "leaveGame") // true = open menu after interstitial
      }

    }
  }

  // instruction scene
  InstructionScene {
    id: instructionScene
    onBackButtonPressed: window.state = "menu"

    onMenuButtonPressed: {
      switch (button){
      case "cards":
        window.state = "cards"
        break
      }
    }
  }

  // card scene
  CardScene {
    id: cardScene
    onBackButtonPressed: window.state = "instructions"

    onMenuButtonPressed: {
      switch (button){
      case "menu":
        window.state = "menu"
        break
      }
    }
  }

 // matchmaking scene
 MultiplayerScene {
   id: matchmakingScene
   onBackButtonPressed: window.state = "menu"
 }

 GameNetworkScene{
   id: gameNetworkScene
   onBackButtonPressed: window.state = "menu"
 }

 // scene for in-game store
 StoreScene {
   id: storeScene
   property string previousState: "" // memorize previously visible screen
   onBackButtonPressed: window.state = previousState
 }

  // dummy mousearea to lock whole game while interstitial is showing
  // otherwise user may click something in short time until it opens up
  MouseArea {
    id: lockScreenArea
    visible: false
    enabled: Constants.lockScreenForInterstitial // disabled for testing purposes (would lock screen forever if no ad is received)
    anchors.fill: parent
  }

  // use loader to check for available app updates
  Loader {
    property string updateCheckUrl: system.publishBuild ? "https://felgo.com/qml-sources/OnuVersionCheck.qml" : "https://felgo.com/qml-sources/OnuVersionCheck-test.qml"

    visible: false
    source: !system.desktopPlatform ? updateCheckUrl : ""
    property var menuScene: mainItem.menuScene // required to access menuScene scaleFactor in loaded QML
    property Component dialogComponent: Qt.createComponent(Qt.resolvedUrl("interface/OnuDialog.qml")) // make dialog component available for loaded QML
    onLoaded: item.parent = mainItem
  }



  // calculates remaining time for daily bonus
  function getTimeUntilBonus() {
    var now = new Date().getTime()
    var next = menuScene.localStorage.lastLogin + (24 * 60 * 60 * 1000)
    var remaining = next - now

    var seconds = Math.ceil((remaining / 1000) % 60)
    var minutes = Math.floor((remaining / 1000 / 60) % 60)
    var hours = Math.floor((remaining / 1000 / 60) / 60)

    if(seconds === 60) {
      minutes++
      seconds = 0
    }
    if(minutes === 60) {
      hours++
      minutes = 0
    }
    if(hours < 0)
      hours = 0
    if(minutes < 0)
      minutes = 0
    if(seconds < 0)
      seconds = 0
    return { hours: hours, minutes: minutes, seconds: seconds }
  }
}
