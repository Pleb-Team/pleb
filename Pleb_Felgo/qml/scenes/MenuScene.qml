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
  property alias tokenInfo: tokenInfo         // used by ONUMainItem to trigger tokenInfo animation
  property bool _initialTokens: false         // is set to true when user gets initial tokens

  // background music
  BackgroundMusic {
    volume: 0.20
    id: ambienceMusic
    source: "../../assets/snd/bg.mp3"
  }

  // timer plays the background music
  Timer {
    id: timerMusic
    interval: 100; running: true; repeat: true
    onTriggered: {
      ambienceMusic.play()
      running = false
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

  // button opens powered by Felgo message and links to the website
  MouseArea {
    anchors.top: titleImage.top
    anchors.bottom: titleImage.bottom
    anchors.left: titleImage.left
    anchors.leftMargin: 55
    anchors.right: titleImage.right
    anchors.rightMargin: 55
    width: 240
    height: 30

    onClicked: {
      website.visible = true
    }
  }

  // detailed playerInfo window
  Rectangle {
    id: info
    radius: 15
    color: "white"
    border.color: "#28a3c1"
    border.width: 2.5
    visible: true
    width: 130

    anchors {
      top: localTag.top
      bottom: localTag.bottom
      right: localTag.right
      topMargin: localTag.height / 2 - 9
      bottomMargin: - 6
      rightMargin: - 3
    }

    // detailed playerInfo text
    Item {
      y: 34

      Text {
        id: infoText
        text: "Rank: " + rank + "\nLevel: " + localTag.level + "\nScore: " + localTag.highscore
        font.family: standardFont.name
        color: "black"
        font.pixelSize: 8
        width: contentWidth
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 14
        verticalAlignment: Text.AlignVCenter

        property string rank: localTag.rank > 0 ? "#" + localTag.rank : "-"
      }
    }

    // clickable area to hide the detailed playerInfo
    MouseArea {
      anchors.fill: parent
      onClicked: info.visible ^= true
    }
  }

  // button leading to the profile view
  MenuButton {
    action: "profile"
    color: "transparent"
    width: 30
    height: 30
    buttonImage.source: "../../assets/img/Settings.png"
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10
    anchors.right: info.left
    anchors.rightMargin: 5
    visible: info.visible
    onClicked: {
//      ga.logEvent("User", "Profile")
//      flurry.logEvent("User.Profile")
    }
  }

  GameButton {
    anchors.right: gameWindowAnchorItem.right
    anchors.bottom: increaseTokenButton.top
    text: storeScene.tokens === 0 ? "Set to 20" : "Set to 0"
    onClicked: storeScene.tokens === 0 ? storeScene.giveTokens(20 - storeScene.tokens) : storeScene.takeTokens(storeScene.tokens)
    visible: system.desktopPlatform && !system.publishBuild && enableStoreAndAds
  }

  GameButton {
    anchors.right: increaseTokenButton.left
    anchors.bottom: increaseTokenButton.bottom
    text: "Token--"
    onClicked: storeScene.takeTokens(1)
    visible: system.desktopPlatform && !system.publishBuild && enableStoreAndAds
  }

  GameButton {
    id: increaseTokenButton
    anchors.right: gameWindowAnchorItem.right
    anchors.bottom: tokenInfo.top
    anchors.bottomMargin: 15
    text: "Token++"
    onClicked: storeScene.giveTokens(1)
    visible: system.desktopPlatform && !system.publishBuild && enableStoreAndAds
  }

  TokenInfo {
    id: tokenInfo
    tokens: storeScene.tokens
    anchors.right: gameWindowAnchorItem.right
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 85
    onClicked: menuButtonPressed("store")
    visible: enableStoreAndAds
  }

  // local player tag
  PlayerTag {
    id: localTag
    player: gameNetwork.user
    nameColor: info.visible ? "#28a3c1" : "white"
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

    infoButton.enabled: player.name != ""
    infoButton.onClicked: {
//      ga.logEvent("User", "Own Player Details")
//      flurry.logEvent("User.OwnPlayerDetails")
      info.visible ^= true
    }
  }

  // credits
  Text {
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10
    anchors.right: gameWindowAnchorItem.right
    anchors.rightMargin: 10
    font.pixelSize: 6
    color: "white"
    text: "UNO © 2016 Matell, Inc."
    visible: false
  }

  // main menu
  Column {
    id: gameMenu
    anchors.top: titleImage.bottom
    anchors.topMargin: 10
    anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
    spacing: 6

    MenuButton {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Quick Game"
      action: "quick"
      onClicked: {
//        ga.logEvent("User", "Quick Game")
//        flurry.logEvent("User.Quick Game")
      }
    }

    MenuButton {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Matchmaking"
      onClicked: {
//        ga.logEvent("User", "Matchmaking")
//        flurry.logEvent("User.Matchmaking")
      }
    }

    MenuButton {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Single Player"
      action: "single"
      //visible: false
      onClicked: {
//        ga.logEvent("User", "Single Game")
//        flurry.logEvent("User.Single Game")
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
//        ga.logEvent("User", "Friends")
//        flurry.logEvent("User.Friends")
      }
      opacity: communityButton.hidden ? 0 : 1
    }

    // button to connect with facebook
    ButtonBase {
      color: "transparent"
      width: communityButton.width
      height: communityButton.height
      anchors.margins: communityButton.anchors.margins
      buttonImage.source: "../../assets/img/Facebook.png"
      visible: !system.desktopPlatform && !gameNetwork.facebookConnectionSuccessful

      onClicked: {
//        ga.logEvent("User", "Show Facebook")
//        flurry.logEvent("User.ShowFacebook")
        connectFacebook.visible ^= true
      }
    }

    // button to share the game
    ButtonBase {
      color: "transparent"
      width: communityButton.width
      height: communityButton.height
      anchors.margins: communityButton.anchors.margins
      buttonImage.source: "../../assets/img/Share.png"
      visible: !system.desktopPlatform

      onClicked: {
//        ga.logEvent("User", "Share")
//        flurry.logEvent("User.Share")
        nativeUtils.share("Come and play " + gameTitle + " with me, the best multiplayer card game! My player name is " + gameNetwork.displayName, "https://felgo.com/one-download/")
      }
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
//          ga.logEvent("User", "Music")
//          flurry.logEvent("User.Music")
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
//          ga.logEvent("User", "Sound")
//          flurry.logEvent("User.Sound")
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

//    // button to send feedback to Felgo
//    ButtonBase {
//      color: "transparent"
//      width: communityButton.width
//      height: communityButton.height
//      anchors.margins: communityButton.anchors.margins
//      buttonImage.source: "../../assets/img/Invites.png"
//      onClicked: showFeedback()
//    }
  }

  // message and leaderboard buttons
  Row {
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.left: community.right
    anchors.bottomMargin: 10
    anchors.leftMargin: community.spacing
    spacing: community.spacing

    MenuButton {
      id: inboxButton
      action: "inbox"
      color: "transparent"
      width: communityButton.width
      height: communityButton.height
      anchors.margins: communityButton.anchors.margins
      buttonImage.source: "../../assets/img/Messages.png"
      onClicked: {
//        ga.logEvent("User", "Messages")
//        flurry.logEvent("User.Messages")
      }
    }

    MenuButton {
      action: "leaderboard"
      color: "transparent"
      width: communityButton.width
      height: communityButton.height
      anchors.margins: communityButton.anchors.margins
      buttonImage.source: "../../assets/img/Network.png"
      onClicked: {
//        ga.logEvent("User", "Network")
//        flurry.logEvent("User.Network")
      }
    }
  }

  ConnectFacebookWindow {
    id: connectFacebook
    visible: false
    scale: 0.5
    anchors.centerIn: gameWindowAnchorItem
    onConnectFacebookClicked: {
      // close community submenu after showing facebook dialog
      communityButton.clicked()
    }
  }

//  LikeWindow {
//    id: like
//    visible: false
//    scale: 0.5
//    anchors.centerIn: gameWindowAnchorItem
//  }

  RatingWindow {
    id: rating
    visible: false
    scale: 0.5
    anchors.centerIn: gameWindowAnchorItem
  }

//  FeedbackWindow {
//    id: feedback
//    visible: false
//    scale: 0.5
//    anchors.centerIn: gameWindowAnchorItem
//  }

  WebsiteWindow {
    id: website
    visible: false
    scale: 0.5
    anchors.centerIn: gameWindowAnchorItem
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

//  Connections {
//    target: window.loadingScene
//    onOpacityChanged: {
//      if (window.loadingScene.opacity == 0){
//        if (localStorage.getValue("appstarts") > 5 && !localStorage.getValue("feedbackSent")){
//          showFeedback()
//        }
//      }
//    }
//  }

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
//      ga.logScreen("MenuScene")
//      flurry.logEvent("Screen.MenuScene")
      gameNetwork.api.inbox()
      gameNetwork.sync()
    }
  }

//  function showFeedback(){
////    ga.logEvent("User", "Show Feedback Dialog")
////    flurry.logEvent("User.ShowFeedbackDialog")
//    like.visible = true
//  }

  // enter scene will be called whenever menuScene is shown
  function enterScene() {
    checkDailyBonus()
  }

  // check date to give daily bonus
  function checkDailyBonus() {
    if(!enableStoreAndAds)
      return

    var today = new Date()
    var todayTruncated = new Date(today.getTime()-today.getHours()*3600000-today.getMinutes()*60000-today.getSeconds()*1000-today.getMilliseconds())
    console.debug("Today truncated is " + todayTruncated.getTime().toString())
    var storedLastLoginMS = localStorage.lastLogin
    console.debug("Read from database " + storedLastLoginMS)
    if(storedLastLoginMS === 0) {
      // start with 20 tokens
      _initialTokens = true
      localStorage.setLastLogin(todayTruncated.getTime().toString()) // initialize
      if(storeScene.tokens < 20)
        storeScene.giveTokens(20 - storeScene.tokens)
    }
    else if(todayTruncated.getTime().toString() > storedLastLoginMS) {
      // give daily bonus
      console.debug("Last login was a day ago, give player bonus")
      localStorage.setLastLogin(todayTruncated.getTime().toString())
      storeScene.giveTokens(gameTokensEarnedPerDay) // increase tokens by 1
      dailyTokenDialog.visible = true
    }

    if (!system.publishBuild && !_initialTokens && storeScene.tokens < 20) {
      // always start with 20 tokens for debug builds
      _initialTokens = true
      storeScene.giveTokens(20 - storeScene.tokens)
    }
  }
}
