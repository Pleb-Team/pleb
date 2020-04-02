import Felgo 3.0
import QtQuick 2.12
import "../common"
import "../game/one"
import "../game/blatt52"
import "../interface"

SceneBase {
  id: gameScene
  height: 640
  width: 960

  // game signals
  signal cardSelected(var cardId)
  signal stackSelected()
  signal colorPicked(var pickedColor)

  // access the elements from outside
  property alias deck: deck
  property alias depot: depot
  property alias gameLogic: gameLogic
  property alias onuButton: onuButton
  property alias gameOver: gameOver
  property alias leaveGame: leaveGame
  property alias switchName: switchName
  property alias drawCounter: drawCounter
  property alias bottomHand: bottomHand
  property alias playerInfoPopup: playerInfoPopup
  property alias onuHint: onuHint
  property alias rightPlayerTag: rightPlayerTag // ad banner will be aligned based on rightPlayerTag


  // connect to the FelgoMultiplayer object and handle all signals
  Connections {
    // this is important! only handle the messages when we are currently in the game scene
    // otherwise, we would handle the playerJoined signal when the player is still in matchmaking view!
    // do not use the visible property here! as visible only gets triggered with the opacity animation in SceneBase
    target: multiplayer
    enabled: activeScene === gameScene

    onPlayerJoined: {
      console.debug("GameScene.onPlayerJoined:", JSON.stringify(player))
      console.debug(multiplayer.localPlayer.name + " is leader? " + multiplayer.amLeader)

      // send a new message with the new sync value to the new player (or actually to all), as we now support late-joins of the game
      if(multiplayer.amLeader && activeScene === gameScene) {
        console.debug("Leader send game state to player")
        gameLogic.sendGameStateToPlayer(player.userId)

        // log event when a player joined the game
      }
    }

    onPlayerChanged: {

    }

    onPlayersReady: {

    }

    onGameStarted: {

    }

    onPlayerLeft:{
      // log event when a player left the game
      if(multiplayer.amLeader && activeScene === gameScene) {
        // not relevant for google analytics, causes to exceed the free limit
        // flurry.logEvent("System.PlayerLeft", "singlePlayer", multiplayer.singlePlayer)
      }
    }

    onLeaderPlayerChanged:{
      console.debug("leaderPlayer changed to:", multiplayer.leaderPlayer)
    }

    onActivePlayerChanged:{
    }

    onTurnStarted:{
      gameLogic.turnStarted(playerId)
    }
  }

  // background
  Image {
    id: background
    source: "../../assets/img/BG.png"
    anchors.fill: gameScene.gameWindowAnchorItem
    fillMode: Image.PreserveAspectCrop
    smooth: true
  }

  // circle image with the game direction
  Image {
    id: depotImage
    source: "../../assets/img/Depot.png"
    width: 280
    height: width
    anchors.centerIn: depot
    smooth: true
    mirror: !depot.clockwise

    onMirrorChanged: {
      if (!mirror){
        mirrorAnimation.from = 0
        mirrorAnimation.to = 180
      } else {
        mirrorAnimation.from = 180
        mirrorAnimation.to = 0
      }
      mirrorAnimation.start()
    }

    NumberAnimation { id: mirrorAnimation; target: depotImage; properties: "rotation";
      from: 0; to: 180; duration: 400; easing.type: Easing.InOutQuad }
  }

  // contains all game logic functions
  GameLogic_52 {
    id: gameLogic
  }

  // lose keyboard focus after clicking outside of the chat
  MouseArea {
    id: unfocus
    anchors.fill: gameWindowAnchorItem
    enabled: chat.inputText.focus
    onClicked: chat.inputText.focus = false
    z: multiplayer.myTurn ? 0 : 150
  }

  // back button to leave scene
  ButtonBase {
    id: backButton
    width: 50
    height: 50
    buttonImage.source: "../../assets/img/Home.png"
    anchors.right: gameWindowAnchorItem.right
    anchors.rightMargin: 20
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 20
    onClicked: leaveGame.visible = true
  }

  // button to finish the game
  // the player who clicked the button will be the winner
  // for debug purposes
  ButtonBase {
    text: "Close\nRound"
    width: buttonText.contentWidth + 30
    visible: system.debugBuild && !gameLogic.gameOver
    anchors.horizontalCenter: onuButton.horizontalCenter
    anchors.bottom: onuButton.top
    anchors.bottomMargin: 20
    onClicked: {
      gameLogic.endGame(multiplayer.localPlayer.userId)
      multiplayer.sendMessage(gameLogic.messageEndGame, {userId: multiplayer.localPlayer.userId, test: true})
    }
  }
  ButtonBase {
    text: "Switch Name"
    //width: buttonText.contentWidth + 30
    // for testing the switch name dialog, only for debugging
    visible: system.debugBuild
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    z: 1
    onClicked: {
      switchName.visible = true
    }
  }

  // onu button on the left of the depot
  ONUButton {
    id: onuButton
    anchors.verticalCenter: depot.verticalCenter
    anchors.right: depot.left
    anchors.rightMargin: 85
    visible: false // remove ONU button (ONU will auto-activate for all users then, makes game a bit easier and faster to play)
  }

  // the deck on the right of the depot
  Deck_52 {
    id: deck
    anchors.verticalCenter: depot.verticalCenter
    anchors.left: depot.right
    anchors.leftMargin: 90
  }

  // the drawCounter on top of the depot showing the current drawAmount
  Text {
    id: drawCounter
    anchors.left: depot.right
    anchors.leftMargin: 18
    anchors.bottom: depot.top
    anchors.bottomMargin: 12
    text: "+" + depot.drawAmount
    color: "white"
    font.pixelSize: 40
    font.family: standardFont.name
    font.bold: true
    visible: depot.drawAmount > 1 && !onuHint.visible ? true : false
  }

  // the drawCounter on top of the depot showing the current drawAmount
  Text {
    id: onuHint
    anchors.left: depot.right
    anchors.leftMargin: 18
    anchors.bottom: depot.top
    anchors.bottomMargin: 12
    text: "+2"
    color: "white"
    font.pixelSize: 40
    font.family: standardFont.name
    font.bold: true
    visible: false

    Text {
      anchors.left: parent.right
      anchors.leftMargin: 14
      anchors.verticalCenter: parent.verticalCenter
      text: "Forgot to press\nOne Button"
      color: "white"
      font.pixelSize: 14
      font.family: standardFont.name
      font.bold: true
    }

    onVisibleChanged: {
      if (visible){
        singleTimer.start()
      }
    }

    Timer {
      id: singleTimer
      interval: 3000
      repeat: false
      running: false

      onTriggered: {
        onuHint.visible = false
      }
    }
  }

  // the four playerHands placed around the main game field
  Item {
    id: playerHands
    anchors.fill: gameWindowAnchorItem

    PlayerHand_52 {
      id: bottomHand
      anchors.bottom: parent.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      z: 100
    }

    PlayerHand_52 {
      id: leftHand
      anchors.left: parent.left
      anchors.leftMargin: -width/2 + height/2
      anchors.verticalCenter: parent.verticalCenter
      rotation: 90
    }

    PlayerHand_52 {
      id: topHand
      anchors.top: parent.top
      anchors.horizontalCenter: parent.horizontalCenter
      rotation: 180
    }

    PlayerHand_52 {
      id: rightHand
      anchors.right: parent.right
      anchors.rightMargin: -width/2 + height/2
      anchors.verticalCenter: parent.verticalCenter
      rotation: 270
    }
  }

  // the depot in the middle of the game field
  Depot_52 {
    id: depot
    //anchors.centerIn: gameWindowAnchorItem
    anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: move()

    function move(){
      return(gameWindowAnchorItem.height - depot.height ) / 2 + (bottomHand.height - bottomHand.originalHeight) / 2.5
    }
  }

  // the playerTags for each playerHand
  Item {
    id: playerTags
    anchors.fill: gameWindowAnchorItem

    PlayerTag {
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 5
      anchors.right: parent.right
      anchors.rightMargin: (parent.width - bottomHand.width) / 2 - width * 0.8
    }

    PlayerTag {
      anchors.left: parent.left
      anchors.leftMargin: 5
      anchors.top: parent.top
      anchors.topMargin: 10
    }

    PlayerTag {
      anchors.top: parent.top
      anchors.topMargin: 10
      anchors.left: parent.left
      anchors.leftMargin: (parent.width - topHand.width) / 2 - width
    }

    PlayerTag {
      id: rightPlayerTag
      anchors.right: parent.right
      anchors.rightMargin: 5
      anchors.top: parent.top
      anchors.topMargin: 10
    }
  }

  // the colorPicker in the middle of the screen
  ColorPicker {
    id: colorPicker
    visible: false
    anchors.centerIn: depot
  }

  // the gameOver message in the middle of the screen
  GameOverWindow {
    anchors.centerIn: gameWindowAnchorItem
    id: gameOver
    visible: false
  }

  // the gameOver message in the middle of the screen
  SwitchNameWindow {
    anchors.centerIn: gameWindowAnchorItem
    id: switchName
    visible: false
  }

  // the playerInfoPopup shows detailed information of a user
  PlayerInfo {
    id: playerInfoPopup
    anchors.centerIn: gameWindowAnchorItem
    refTag: playerTags.children[0]
  }

  // the leaveGame message in the middle of the screen
  LeaveGameWindow {
    anchors.centerIn: gameWindowAnchorItem
    id: leaveGame
    visible: false
  }

  // chat on the bottom left corner for all connected players
  Chat {
    id: chat
    height: gameWindowAnchorItem.height - bottomHand.width / 2
    width: (gameWindowAnchorItem.width - bottomHand.width) / 2 - 20
    anchors.left: gameWindowAnchorItem.left
    anchors.leftMargin: 20
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 20
  }

  // init the game after switching to the gameScene
  onVisibleChanged: {
    if(visible){
      gameLogic.initGame()
    }
  }
}
