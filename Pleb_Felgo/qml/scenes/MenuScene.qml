import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.1
import QtQml 2.12
import Qt.labs.folderlistmodel 1.0

import Felgo 3.0
import "../common"
import "../interface"

SceneBase {
  id: menuScene

  // signal that indicates that other scenes should be displayed
  signal menuButtonPressed(string button)

  property alias localStorage: localStorage   // is used by ONUMain to access gamesPlayed counter
//  property alias tokenInfo: tokenInfo         // used by ONUMainItem to trigger tokenInfo animation
//  property bool _initialTokens: false         // is set to true when user gets initial tokens

  // background music
  BackgroundMusic {
    volume: 0.20
    id: ambienceMusic
//    source: "../../assets/snd/bg.mp3"
  }

  FolderListModel {
      id: folderModel
      nameFilters: "*.mp3"
      folder: "../../assets/music"
      showDotAndDotDot: false
      showDirs: false
  }

  // timer plays the background music
  Timer {
      id: timerMusic
      interval: 100; running: true; repeat: true
      onTriggered:
      {
          running = false

          // Chose an existing sound folder by random
          var nIndex = Math.floor(Math.random() * folderModel.count)
          var s = folderModel.get(nIndex, "filePath")
          ambienceMusic.source = s
          ambienceMusic.play()
      }
  }

  // background
  Image {
    id: background
    source: "../../assets/img/BG.png"
    anchors.fill: menuScene.gameWindowAnchorItem
    fillMode: Image.PreserveAspectCrop
    smooth: true
  }

  // the title image
  Image {
    id: titleImage
    anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
    anchors.top: gameWindowAnchorItem.top
    anchors.topMargin: 15
    source: "../../assets/img/Title.png"
    fillMode: Image.PreserveAspectFit
    width: 380
  }


  // detailed playerInfo window
//  Rectangle {
//      id: playerInfo
//      radius: 15
//      color: "white"
//      border.color: "#28a3c1"
//      border.width: Constants.nBorderWidth
//      visible: Constants.bShowBetaFeatures
//      width: 130

//      anchors {
//          top: localTag.top
//          bottom: localTag.bottom
//          right: localTag.right
//          topMargin: localTag.height / 2 - 9
//          bottomMargin: - 6
//          rightMargin: - 3
//      }

//      // detailed playerInfo text
//      Item {
//          y: 34

//          Text {
//              id: infoText
//              text: "Rank: " + rank + "\nLevel: " + localTag.level + "\nScore: " + localTag.highscore
//              font.family: standardFont.name
//              color: "black"
//              font.pixelSize: 8
//              width: contentWidth
//              anchors.verticalCenter: parent.verticalCenter
//              anchors.left: parent.left
//              anchors.leftMargin: 14
//              verticalAlignment: Text.AlignVCenter

//              property string rank: localTag.rank > 0 ? "#" + localTag.rank : "-"
//          }
//      }

//      // clickable area to hide the detailed playerInfo
//      MouseArea {
//          enabled: Constants.bShowBetaFeatures
//          anchors.fill: parent
//          onClicked: playerInfo.visible ^= true
//      }
//  }

  // local player tag
  PlayerTag {
    id: localTag
    visible: Constants.bShowBetaFeatures
    player: gameNetwork.user
//    nameColor: playerInfo.visible ? "#28a3c1" : "white"
    menu: true
    avatarSource: gameNetwork.user.profileImageUrl ? gameNetwork.user.profileImageUrl : "../../assets/img/User.png"
    level: Math.max(1, Math.min(Math.floor(gameNetwork.userHighscoreForCurrentActiveLeaderboard / 300), 999))
    highscore: gameNetwork.userHighscoreForCurrentActiveLeaderboard
    rank: gameNetwork.userPositionForCurrentActiveLeaderboard

    scale: 0.5
    transformOrigin: Item.BottomRight
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10
    anchors.right: gameWindowAnchorItem.right
    anchors.rightMargin: 10

    infoButton.enabled: player.name !== "" && Constants.bShowBetaFeatures
//    infoButton.onClicked: {
//      playerInfo.visible ^= true
//    }
  }

  // main menu
  Column {
      id: gameMenu
      anchors.top: titleImage.bottom
      anchors.topMargin: 10
      anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
      spacing: 6

      MenuButton {
          visible: Constants.bShowBetaFeatures
          opacity: 0.4
          anchors.horizontalCenter: parent.horizontalCenter
          text: "Quick Game (beta)"
          action: "quick"
      }

      MenuButton {
          visible: Constants.bShowBetaFeatures
          opacity: 0.4
          anchors.horizontalCenter: parent.horizontalCenter
          text: "Matchmaking (beta)"
      }
  }

  // Moved outside the above column s.t. the button is bottom-aigned
  // Hint: Move back to the above column when the other buttons get reactivated
  MenuButton {
      anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
      anchors.bottom: gameWindowAnchorItem.bottom
      anchors.bottomMargin: 50
      text: "Single Player"
      action: "single"
  }

  // columnButtons submenu
  Column {
    id: columnButtons
    width: 35
    spacing: 4
    anchors.left: gameWindowAnchorItem.left
    anchors.leftMargin: 10
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10


    MenuButton {
      visible: Constants.bShowBetaFeatures
      action: "friends"
      color: "transparent"
      opacity: 0.6
      width: columnButtons.width
      height: columnButtons.width
      buttonImage.source: "../../assets/img/Friends.png"
    }

    MenuButton {
      visible: Constants.bShowBetaFeatures
      action: "leaderboard"
      color: "transparent"
      opacity: 0.6
      width: columnButtons.width
      height: columnButtons.width
      buttonImage.source: "../../assets/img/Network.png"
    }

    MenuButton {
      id: inboxButton
      visible: Constants.bShowBetaFeatures
      action: "inbox"
      color: "transparent"
      opacity: 0.6
      width: columnButtons.width
      height: columnButtons.width
      buttonImage.source: "../../assets/img/Messages.png"
    }

    // button leading to the profile view
    MenuButton {
      visible: Constants.bShowBetaFeatures
      action: "profile"
      color: "transparent"
      opacity: 0.6
      width: columnButtons.width
      height: columnButtons.width
      buttonImage.source: "../../assets/img/Settings.png"
    }

//    // button to share the game
//    ButtonBase {
//      color: "transparent"
//      width: columnButtons.width
//      height: columnButtons.width
//      buttonImage.source: "../../assets/img/Community.png"
//      onClicked:
////          gameScene.switchNameWindow.visible = true
//    }

    // button to share the game
    ButtonBase {
      color: "transparent"
      width: columnButtons.width
      height: columnButtons.width
      buttonImage.source: "../../assets/img/Share.png"
      visible: !system.desktopPlatform

      onClicked: {
        nativeUtils.share("Come and play "
                        + gameTitle
                        + " with me, the best multiplayer card game! My player name is "
                        + gameNetwork.displayName, "https://github.com/Pleb-team/pleb/")
      }
    }

    ButtonBase {
      color: "transparent"
      width: columnButtons.width
      height: columnButtons.width
      buttonImage.source: "../../assets/img/Instructions.png"
      onClicked: window.state = "introduction"
    }


    // button to toggle the music
    ButtonBase {
      id: buttonMusic
      color: "transparent"
      width: columnButtons.width
      height: columnButtons.width
      buttonImage.source: "../../assets/img/Music.png"
      opacity: settings.musicEnabled ? 1.0 :  0.6
      onClicked: {
        settings.musicEnabled ^= true
      }
    }

    // button to toggle the sound effects
    ButtonBase {
      color: "transparent"
      width: columnButtons.width
      height: columnButtons.width
      buttonImage.source: "../../assets/img/Sound.png"
      opacity: settings.soundEnabled ? 1.0 :  0.6
      onClicked: {
        settings.soundEnabled ^= true
      }
    }

    // button to toggle the sound effects
    ButtonBase {
      color: "transparent"
      width: columnButtons.width
      height: columnButtons.width
      buttonImage.source: "../../assets/img/Settings.png"
      opacity: localStorage.debugMode ? 1.0 :  0.6
      onClicked: {
        localStorage.setDebugMode(!localStorage.debugMode)
        if (localStorage.debugMode)
            nativeUtils.displayMessageBox(qsTr("Test mode activated - this is only for development purposes. Make sure to know what you're doing!"))
        else
            nativeUtils.displayMessageBox(qsTr("Test mode deactivated, enjoy regular playing."))
      }
    }
  }

  Text {
      id: txtVersion
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.margins: 10
      font.pixelSize: 9
      color: "black"
      text: qsTr("Version name: " + Qt.application.version)
  }


  // connect to the FelgoGameNetwork to handle new inbox entries
  Connections{
    target: gameNetwork

    onInboxEntriesChanged:{
      var conv = gameNetwork.inboxEntries
      var count = 0
      for(var i = 0; i < conv.length; i++){
        count += conv[i].unread_count
      }
      inboxButton.notification = count
    }
  }

  // define Storage item for loading/storing key-value data
  // ask the user for feedback after opening the app 5 times
  Storage {
      id: localStorage
      property int appStarts: 0
      property int gamesPlayed: 0 // store number of games played
      property real lastLogin: 0   // date (day) of last login (reward received)
      property bool debugMode: false

      // update app starts counter
      Component.onCompleted:
      {
          // uncomment this to clear the storage
          //localStorage.clearValue("appstarts")
          //localStorage.clearValue("gamesplayed")
          //localStorage.clearValue("lastlogin")
          console.debug("[MenuScene::Storage::onCompleted] Qt.application.version:" + Qt.application.version)
          console.debug("[MenuScene::Storage::onCompleted] Qt.application.name:" + Qt.application.name)
          console.debug("[MenuScene::Storage::onCompleted] Qt.application.organization:" + Qt.application.organization)
          console.debug("[MenuScene::Storage::onCompleted] Qt.application.domain:" + Qt.application.domain)


          var nr = localStorage.getValue("appstarts")
          if(nr === undefined) nr = 0

          nr++
          localStorage.setValue("appstarts", nr)
          appStarts = nr

          // init or load gamesPlayed counter
          if(localStorage.getValue("gamesplayed") === undefined)
              localStorage.setValue("gamesplayed", 0)
          gamesPlayed = localStorage.getValue("gamesplayed")

          // init or load last login day
          if(localStorage.getValue("lastlogin") === undefined)
              localStorage.setValue("lastlogin", 0) // will be correctly set when first checked
          lastLogin = localStorage.getValue("lastlogin")

          if(localStorage.getValue("debugMode") === undefined)
              localStorage.setValue("debugMode", false) // will be correctly set when first checked
          debugMode = localStorage.getValue("debugMode")
      }

      // set and store gamesPlayed locally
      function setGamesPlayed(count) {
          localStorage.setValue("gamesplayed", count)
          localStorage.gamesPlayed = count
      }

      // set and store last login day
      function setLastLogin(day) {
          localStorage.setValue("lastlogin", day)
          localStorage.lastLogin = day
      }

      // set and store last login day
      function setDebugMode(b) {
          localStorage.setValue("debugMode", b)
          localStorage.debugMode = b
      }

  }

  // sync messages on the main menu page
  onVisibleChanged: {
    if(visible){
      gameNetwork.api.inbox()
      gameNetwork.sync()
    }
  }
}
