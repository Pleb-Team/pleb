import QtQuick 2.12
import QtQuick.Controls 1.4
import Felgo 3.0
import "../common"
import "../interface"

SceneBase {
  id: menuScene

  // signal that indicates that other scenes should be displayed
  signal menuButtonPressed(string button)

  property alias localStorage: localStorage   // is used by ONUMain to access gamesPlayed counter

  // background music
//  BackgroundMusic {
//    volume: 0.20
//    id: ambienceMusic
//    source: "../../assets/snd/bg.mp3"
//  }

  // timer plays the background music
//  Timer {
//    id: timerMusic
//    interval: 100; running: true; repeat: true
//    onTriggered: {
//      ambienceMusic.play()
//      running = false
//    }
//  }

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

  // main menu
  Column {
    id: gameMenu
    anchors.top: titleImage.bottom
    anchors.topMargin: 10
    anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
    spacing: 6

//    MenuButton {
//      anchors.horizontalCenter: parent.horizontalCenter
//      text: "Quick Game"
//      action: "quick"
//      onClicked: {
//          // logEvent("User.Quick Game")
//      }
//    }

//    MenuButton {
//      anchors.horizontalCenter: parent.horizontalCenter
//      text: "Matchmaking"
//      onClicked: {
//         // logEvent("User.Matchmaking")
//      }
//    }

    MenuButton {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Single Player"
      action: "single"
      //visible: false
      onClicked: {
         // logEvent("User.Single Game")
      }
    }
  }

  // animation to slide the community menu in and out
  NumberAnimation {
    id: slideAnimation
    running: false
    target: community
    property: "anchors.bottomMargin"
    duration: 200
    to: 0
    easing.type: Easing.InOutQuad
  }

  // community submenu
  Column {
    id: community
    width: communityButton.width
    spacing: 4
    anchors.left: gameWindowAnchorItem.left
    anchors.leftMargin: 10
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: (community.height - communityButton.height) * (-1) + 10

    // community button to slide the community submenu in and out
    ButtonBase {
      id: communityButton
      color: "transparent"
      width: 38
      height: 38
      buttonImage.source: "../../assets/img/More.png"

      property bool hidden: true

      onClicked: {
        hidden = !hidden
        slideMenu()
//        ga.logEvent("User", "Community Menu")
//        flurry.logEvent("User.Community Menu")
      }

      // slides the community menu in or out depending on the hidden
      function slideMenu(){
        if (hidden){
          slideAnimation.to = (community.height - communityButton.height) * (-1) + 10
          opacity = 1.0
        }else{
          slideAnimation.to = 10
          opacity = 0.6
        }
        slideAnimation.start()
      }
    }

    MenuButton {
      action: "friends"
      color: "transparent"
      width: communityButton.width
      height: communityButton.height
      anchors.margins: communityButton.anchors.margins
      buttonImage.source: "../../assets/img/Friends.png"
      onClicked: {
        // logEvent("User.Friends")
      }
      opacity: communityButton.hidden ? 0 : 1
    }

    // music and sound effect toggle buttons
    Row {
      spacing: 4

      // button to toggle the music
      ButtonBase {
        color: "transparent"
        width: communityButton.width
        height: communityButton.height
        anchors.margins: communityButton.anchors.margins
        buttonImage.source: "../../assets/img/Music.png"
        opacity: settings.musicEnabled ? 1.0 :  0.6
        onClicked: {
          // logEvent("User.Music")
          settings.musicEnabled ^= true
        }
      }

      // button to toggle the sound effects
      ButtonBase {
        color: "transparent"
        width: communityButton.width
        height: communityButton.height
        anchors.margins: communityButton.anchors.margins
        buttonImage.source: "../../assets/img/Sound.png"
        opacity: settings.soundEnabled ? 1.0 :  0.6
        onClicked: {
          // logEvent("User.Sound")
          settings.soundEnabled ^= true
        }
      }
    }

    // button to send feedback to Felgo
    ButtonBase {
      color: "transparent"
      width: communityButton.width
      height: communityButton.height
      anchors.margins: communityButton.anchors.margins
      buttonImage.source: "../../assets/img/Instructions.png"
      onClicked: window.state = "instructions"
      visible: false
    }
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
//      inboxButton.notification = count
    }
  }

  Connections {
    target: window.loadingScene
    onOpacityChanged: {
      if (window.loadingScene.opacity === 0){
        if (localStorage.getValue("appstarts") > 5 && !localStorage.getValue("feedbackSent")){
          // cleaned up
        }
      }
    }
  }

  // define Storage item for loading/storing key-value data
  // ask the user for feedback after opening the app 5 times
  Storage {
    id: localStorage
    property int appStarts: 0
    property int gamesPlayed: 0 // store number of games played
    property real lastLogin: 0   // date (day) of last login (reward received)

    // update app starts counter
    Component.onCompleted: {
      // uncomment this to clear the storage
      //localStorage.clearValue("appstarts")
      //localStorage.clearValue("gamesplayed")
      //localStorage.clearValue("lastlogin")

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
  }

  // sync messages on the main menu page
  onVisibleChanged: {
    if(visible){
      // logEvent("Screen.MenuScene")
      gameNetwork.api.inbox()
      gameNetwork.sync()
    }
  }

  // enter scene will be called whenever menuScene is shown
  function enterScene() {
      checkDailyBonus();
  }

  // check date to give daily bonus
  function checkDailyBonus() {
     // cleaned up
  }
}
