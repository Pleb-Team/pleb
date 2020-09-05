import Felgo 3.0
import QtQuick 2.12
import "../common"
import "../game/pleb"
import "../interface"

SceneBase {
  id: gameScene
  height: 640
  width: 960

  // game signals
  signal cardSelected(var cardId)
  signal stackSelected()
  signal depotSelected()

  // access the elements from outside
  property alias deck: deck
  property alias depot: depot
  property alias gameLogic: gameLogic
  property alias gameOverWindow: gameOverWindow
  property alias leaveGameWindow: leaveGameWindow
  property alias switchNameWindow: switchNameWindow
  property alias bottomHand: bottomHand
  property alias playerInfoPopup: playerInfoPopup
  property alias hintRectangle: hintRectangle
  property alias hintRectangleText: hintRectangleText
  property alias rightPlayerTag: rightPlayerTag // ad banner will be aligned based on rightPlayerTag


  // connect to the FelgoMultiplayer object and handle all signals
  Connections {
    // this is important! only handle the messages when we are currently in the game scene
    // otherwise, we would handle the playerJoined signal when the player is still in matchmaking view!
    // do not use the visible property here! as visible only gets triggered with the opacity animation in SceneBase
    target: multiplayer

    enabled: activeScene === gameScene

    onPlayerJoined:
    {
        console.debug("GameScene.onPlayerJoined:", JSON.stringify(player))
        console.debug(multiplayer.localPlayer.name + " is leader? " + multiplayer.amLeader)

        // send a new message with the new sync value to the new player (or actually to all), as we now support late-joins of the game
        if (multiplayer.amLeader && activeScene === gameScene)
        {
            console.debug("Leader send game state to player")
            gameLogic.sendGameStateToPlayer(player.userId)
        }
    }

    onPlayerChanged: {    }

    onPlayersReady: {    }

    onGameStarted: {    }

    onPlayerLeft:{    }

    onLeaderPlayerChanged: console.debug("leaderPlayer changed to:", multiplayer.leaderPlayer)

    onActivePlayerChanged:{   }

    onTurnStarted: gameLogic.turnStarted(playerId)

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

    // clickable depot area
    MouseArea {
      id: depotButton
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: {
          gameScene.depotSelected()
      }
    }
  }

  // contains all game logic functions
  GameLogic_pleb {
    id: gameLogic
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
    onClicked: leaveGameWindow.visible = true
  }


//  ButtonBase {
//    text: "Switch Name"
//    //width: buttonText.contentWidth + 30
//    // for testing the switch name dialog, only for debugging
//    visible: menuScene.localStorage.debugMode
//    anchors.horizontalCenter: parent.horizontalCenter
//    anchors.top: parent.top
////    anchors.topMargin: adMobBanner.visible && adMobBanner.height > 0 ? (adMobBanner.height / gameScene.yScaleForScene) + 10 : 10
//    anchors.topMargin: 10
//    z: 1
//    onClicked: {
//      switchNameWindow.visible = true
//    }
//  }


  // the deck on the right of the depot
  Deck_pleb {
    id: deck
    visible: false
    anchors.verticalCenter: depot.verticalCenter
    anchors.left: depot.right
    anchors.leftMargin: 90
  }


  Rectangle {
      id: hintRectangle
      radius: 10
      anchors.left: depotImage.right
      anchors.verticalCenter: depotImage.verticalCenter
      width: gameWindowAnchorItem.width / 2 - depotImage.width / 2 - rightHand.height * 1.3;
      height: depotImage.height / 400 * (400 - 35 * 2) // Höhe des grauen Kreises (ohne weiße Pfeile)
      color: "white"
      border.color: Constants.sBorderColor
      border.width: 1

      Text {
          id: hintRectangleText
          anchors.fill: parent
          anchors.margins: 5
          font.pixelSize: 18
          wrapMode: Text.Wrap
          text: "Hint:"
      }
  }


  // the four playerHands placed around the main game field
  Item {
    id: playerHands
    anchors.fill: gameWindowAnchorItem

    PlayerHand_pleb {
      id: bottomHand
      anchors.bottom: parent.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      z: 100
    }

    PlayerHand_pleb {
      id: leftHand
      anchors.left: parent.left
      anchors.leftMargin: -width/2 + height/2
      anchors.verticalCenter: parent.verticalCenter
      rotation: 90
    }

    PlayerHand_pleb {
      id: topHand
      anchors.top: parent.top
      anchors.horizontalCenter: parent.horizontalCenter
      rotation: 180
    }

    PlayerHand_pleb {
      id: rightHand
      anchors.right: parent.right
      anchors.rightMargin: -width/2 + height/2
      anchors.verticalCenter: parent.verticalCenter
      rotation: 270
    }
  }

  // the depot in the middle of the game field
  Depot_pleb {
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
          id: bottomPlayerTag
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 5
          anchors.right: parent.right
          anchors.rightMargin: (parent.width - bottomHand.width) / 2 - width * 0.8
      }

      PlayerTag {
          id: leftPlayerTag
          anchors.left: parent.left
          anchors.leftMargin: 5
          anchors.top: parent.top
          anchors.topMargin: 10
      }

      PlayerTag {
          id: topPlayerTag
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


  // the gameOver message in the middle of the screen
  GameOverWindow {
    anchors.centerIn: gameWindowAnchorItem
    id: gameOverWindow
    visible: false
  }

  SwitchNameWindow {
    anchors.centerIn: gameWindowAnchorItem
    id: switchNameWindow
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
    id: leaveGameWindow
    visible: false
  }

  // chat on the bottom left corner for all connected players
  Chat {
    id: chat
    visible: Constants.bShowBetaFeatures
    height: gameWindowAnchorItem.height - bottomHand.width / 2
    width: (gameWindowAnchorItem.width - bottomHand.width) / 2 - 20
    anchors.left: gameWindowAnchorItem.left
    anchors.leftMargin: 20
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 20
  }

  // lose keyboard focus after clicking outside of the chat
  MouseArea {
    id: unfocus
    anchors.fill: gameWindowAnchorItem
    enabled: chat.inputText.focus
    onClicked: chat.inputText.focus = false
    z: multiplayer.myTurn ? 0 : 150
  }

  // init the game after switching to the gameScene
  onVisibleChanged:
  {
      console.debug("GameScene::onVisibleChanged() start")

      if(visible)
          gameLogic.initGame()

      console.debug("GameScene::onVisibleChanged() finish")
  }
}
