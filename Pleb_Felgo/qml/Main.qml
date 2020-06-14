import Felgo 3.0
import QtQuick 2.0
import "scenes"
import "common"
import Qt.labs.settings 1.0

// NOTE: to enable push notifications & Facebook connection on iOS & Android, you need a paid license
// this demo also works without push notifications so you can test its functionality
// contact us via support@felgo.com if you want to enable push notifications & Facebook in your multiplayer games or in this demo


GameWindow {
  id: window
  height: 640
  width: 960

  // generate your own license key which includes the OneSignal Push Notification plugin & the Facebook plugin at https://felgo.com/licenseKey
  licenseKey: "F1EDD573D22CD7C8C63D330B6B0516B4E915E25F0CAD8674F678BCA698455B3B6F03B985D0815C64DAB1784F3738C8EA451056D2B25B477D746C806F20362CD0C2A394674877499D34EE281CCD8247DE1EFDC3ACCAEB759A4861BF3A64FE201522BF202C3F75F0BB043F21DFE96FFB1DCA485F6BFE972603484A97EBBA837078ECDA21910FC8E3EEE242629EDE83D15F64022B4D782A9DF69DD06AF133281E22D596291162F59ECAFAABF1F2A87FC4F21FA51C76367FB47F39783C057B04FD7E0816FC8BDD88C6929F9398A62732F5E1B4E3E722DFD0B0F6BF64174B58A86B0B2CBD12EE4AABBBA6380EA5DCEE81563A83E4592542DFE44505508936E7045EF594725B37E7B8481EEC1AE6D2B8D8F1CAE888B939D5D8404BA905CA304D4D36BD7528F1F1BB2A80A3BABDBA7E6D0DAC614B9CDBB02C84EF4D8F038CF64B74BCBF6855E2E5CF39E40C250D43E3376BF734"
  title: gameNetwork.user.deviceId + " - " + gameNetwork.user.name

  // this is used in the sharing dialog, rating dialog
  readonly property string gameTitle: "Pleb"

  // references to Pleb scenes (loaded with sceneLoader)
  property MenuScene menuScene: sceneLoader.item && sceneLoader.item.menuScene
  property InstructionScene instructionScene: sceneLoader.item && sceneLoader.item.instructionScene
  property IntroductionScene introductionScene: sceneLoader.item && sceneLoader.item.introductionScene
  property LicenseScene licenseScene: sceneLoader.item && sceneLoader.item.licenseScene
  property GameScene gameScene: sceneLoader.item && sceneLoader.item.gameScene
  property MultiplayerScene matchmakingScene: sceneLoader.item && sceneLoader.item.matchmakingScene
  property GameNetworkScene gameNetworkScene: sceneLoader.item && sceneLoader.item.gameNetworkScene
//  property StoreScene storeScene: sceneLoader.item && sceneLoader.item.storeScene

  property alias loadingScene: loadingScene

  // enable / disable store or advertisements
//  readonly property bool enableStoreAndAds: Constants.enableStoreAndAds
//  readonly property bool showAdvertisements: gameTokens < gameTokenNoAdsLimit && enableStoreAndAds
  readonly property int gamesPlayed: menuScene ? menuScene.localStorage.gamesPlayed : 0
  readonly property int appStarts: menuScene ? menuScene.localStorage.appStarts : 0
//  readonly property int gameTokens : storeScene ? storeScene.tokens : 0  // tokens are our game currency from in-app purchase store

//  readonly property int gameTokenEarnedPerVideoWatch: 1
//  readonly property int gameTokensEarnedPerDay: 1
//  readonly property int gameTokenNoAdsLimit: 10

  // create and remove entities at runtime
  EntityManager {
    id: entityManager
    entityContainer: gameScene
  }

  // main text font
  FontLoader {
    id: standardFont
    source: "../assets/fonts/agoestoesan.ttf"
  }

  Settings {
    id: multiSettings
    property alias counterAppInstances: gameNetwork.counterAppInstances

    Component.onCompleted: {

      // use this to reset the counterAppInstances value to 0
      // you might need this, if the app is destroyed forcefully (e.g. from QtCreator with the red quit application button), because then no Component.onDestruction is called and the counter does not get decreased
      // multiSettings.counterAppInstances = 0

      console.log("multiSettings loaded with counterAppInstances value:" + counterAppInstances+ ", userName: " + gameNetwork.user.name)
      multiSettings.counterAppInstances++
    }
  }

  Component.onDestruction: {
    multiSettings.counterAppInstances--
    console.debug("decreasing counterAppInstances by -1 to:", multiSettings.counterAppInstances)
  }

  FelgoGameNetwork {
    id: gameNetwork
    // on mobile, set this to false as you would otherwise simulate a clean app start with no logged in user every time
    // only set it to true if you want to simulate different users
    clearAllUserDataAtStartup: system.desktopPlatform && enableMultiUserSimulation // this can be enabled during development to simulate a first-time app start
    clearOfflineSendingQueueAtStartup: true // clear any stored requests in the offline queue at app start, to avoid starting errors
    gameId: Constants.gameId
    secret: Constants.gameSecret
    user.deviceId: generateDeviceId()

    property int counterAppInstances: 0

    // set this property to true if you want to switch between multiplayer.playerCount players on Desktop
    // this simplifies multiplayer testing, because you get a new user at every app start and can test multiplayer functionality on the same PC
    property bool enableMultiUserSimulation: true

    function generateDeviceId() {
      // on mobile devices, no 2 app instances can be started at the same time, thus return the udid there
      if(system.isPlatform(System.IOS) || system.isPlatform(System.Android) || system.isPlatform(System.WindowsPhone)) {
        console.debug("xxx-setting deviceId to", system.UDID)
        return system.UDID
      }
      // this means the app was started on the same PC more than once, for testing a multiplayer game
      // in this case, append the counterAppInstances value to the deviceID to have 2 separate players
      if(counterAppInstances > 1 && enableMultiUserSimulation) {
        return system.UDID + "_" + (counterAppInstances) % multiplayer.playerCount
      } else {
        return system.UDID
      }
    }
    gameNetworkView: gameNetworkScene && gameNetworkScene.gnView
  }

  FelgoMultiplayer {
      id: multiplayer

      playerCount: 4
      startGameWhenReady: true
      gameNetworkItem: gameNetwork
      multiplayerView: matchmakingScene && matchmakingScene.mpView
      maxJoinTries: 5
      fewRoomsThreshold: 3
      joinRankingIncrease: 200
      enableLateJoin: true // allow joining a running match after it was started (if the match has non-human (AI) players to fill the game
      appVersion: "1.5.0" // 1.5.0 (changed on 8.8.2016, with versionCode 17) adds new messages that correctly trigger a new game start (also a restart). changing it is important, to not interfere with players of the published Pleb games that did not update yet and to prevent players of the old and new version can play together
      latencySimulationTime: system.desktopPlatform && !system.publishBuild ? 2000 : 0 // allows to simulate latency values on Desktop. for published games, always set this to 0!

      appKey: Constants.appKey
      pushKey: Constants.pushKey
      // NOTE: do NOT use these demo keys for publishing your game, we might remove the demo apps in the future!
      // instead, use your own ones from https://cloud.felgo.com/

      onGameStarted: {
          console.debug("[FelgoMultiplayer] onGameStarted")

          // increase gamesPlayed counter for every game start and decrease tokens
          if(menuScene)
          {
              menuScene.localStorage.setGamesPlayed(gamesPlayed + 1)
          }
          window.state = "game"
      }
  }


  // loadingScene is our first scene, so set the state to menu initially
  state: "loading"
  activeScene: loadingScene


  // loading scene is shown initially
  LoadingScene {
    id: loadingScene
  }

  // other scenes are loaded at runtime, when finished menu is shown
  Loader {
      id: sceneLoader
      onLoaded:
      {
          if (    (menuScene.localStorage.getValue("appstarts") === undefined)
                  || (menuScene.localStorage.getValue("appstarts") <= 3)
                  )
              window.state = "indroduction"
          else
              window.state = "menu"
      }


      // start loading other scenes after 500 ms
      Timer {
          id: loadingTimer
          interval: 500
          onTriggered: sceneLoader.source = Qt.resolvedUrl("MainItem.qml")
      }
  }

  Component.onCompleted: loadingTimer.start()   // start loading other scenes after main item is complete

  // state machine, takes care reversing the PropertyChanges when changing the state, like changing the opacity back to 0
  states: [
      State {
          name: "loading"
          PropertyChanges {target: loadingScene; opacity: 1}
          PropertyChanges {target: window; activeScene: loadingScene}
      },

      State {
          name: "menu"
          PropertyChanges {target: menuScene; opacity: 1}
          PropertyChanges {target: window; activeScene: menuScene}
          StateChangeScript {
              script: { menuScene.enterScene() }
          }
      },

      State {
          name: "introduction"
          PropertyChanges {target: introductionScene; opacity: 1}
          PropertyChanges {target: window; activeScene: introductionScene}
      },

      State {
          name: "instructions"
          PropertyChanges {target: instructionScene; opacity: 1}
          PropertyChanges {target: window; activeScene: instructionScene}
      },

      State {
          name: "license"
          PropertyChanges {target: licenseScene; opacity: 1}
          PropertyChanges {target: window; activeScene: licenseScene}
      },

      State {
          name: "game"
          PropertyChanges {target: gameScene; opacity: 1}
          PropertyChanges {target: window; activeScene: gameScene}
      },

      State {
          name: "multiplayer"
          PropertyChanges {target: matchmakingScene; opacity: 1}
          PropertyChanges {target: window; activeScene: matchmakingScene}
      },

      State {
          name: "gn"
          PropertyChanges {target: gameNetworkScene; opacity: 1}
          PropertyChanges {target: window; activeScene: gameNetworkScene}
      }
  ]
}
