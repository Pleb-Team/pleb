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
    property alias introductionScene: introductionScene
    property alias licenseScene: licenseScene
    property alias matchmakingScene: matchmakingScene
    property alias gameNetworkScene: gameNetworkScene
//    property alias storeScene: storeScene


    // menu scene
    MenuScene {
        id: menuScene

        // switch scenes after pressing a MenuButton
        onMenuButtonPressed: {
            // calculate time until bonus
//            var timeUntilBonus = getTimeUntilBonus()
//            var timeUntilBonusStr = (timeUntilBonus.hours !== 0 ? timeUntilBonus.hours+" Hours" : timeUntilBonus.minutes !== 0 ? timeUntilBonus.minutes+ " Minutes" : timeUntilBonus.seconds+ " Seconds")

            switch (button){
            case "single":
//                checkTokens(function() {
                    multiplayer.createSinglePlayerGame()
//                    window.state = "game"
//                }, "Wait "+timeUntilBonusStr, checkDailyBonus)  // adds additional option "Wait"
                break
            case "matchmaking":
//                checkTokens(function() {
                    // only allowed to play if enough tokens
                    multiplayer.showMatchmaking()
//                    window.state = "multiplayer"
//                }, "Wait "+timeUntilBonusStr, checkDailyBonus) // adds additional option "Wait"
                break
            case "quick":
//                checkTokens(function() {
                    // only allowed to play if enough tokens
                    multiplayer.joinOrCreateGame()
//                    multiplayer.showMatchmaking()
//                    window.state = "multiplayer"
//                }, "Wait "+timeUntilBonusStr, checkDailyBonus) // adds additional option "Wait"
                break
            case "invites":
                multiplayer.showInvitesList()
                window.state = "multiplayer"
                break
            case "inbox":
                multiplayer.showInbox()
                window.state = "multiplayer"
                break
            case "friends":
                multiplayer.showFriends()
                window.state = "multiplayer"
                break
            case "leaderboard":
                gameNetwork.showLeaderboard()
                window.state = "gn"
                break
            case "profile":
                gameNetwork.showProfileView()
                window.state = "gn"
                break
//            case "store":
//                storeScene.previousState = window.state
//                window.state = "store"
//                break
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
            if(!gameScene.leaveGame.visible)
                gameScene.leaveGame.visible = true
            else
                window.state = "menu"
        }
    }


    // card scene
    IntroductionScene {
        id: introductionScene
        onBackButtonPressed: window.state = "menu"
        onMenuButtonPressed: window.state = "instructions"
    }

    // instruction scene
    InstructionScene {
        id: instructionScene
        onBackButtonPressed: window.state = "introduction"
        onMenuButtonPressed: window.state = "license"
    }

    // licenseScene scene
    LicenseScene {
        id: licenseScene
        onBackButtonPressed: window.state = "instructions"
        onMenuButtonPressed: window.state = "menu"
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
//    StoreScene {
//        id: storeScene
//        property string previousState: "" // memorize previously visible screen
//        onBackButtonPressed: window.state = previousState
//    }

//    // in-game AdMobBanner on top of screen above opponent hand
//    AdMobBanner {
//        id: adMobBanner
//        adUnitId: Constants.adMobBannerUnitId
//        banner: window.tablet ? AdMobBanner.Large : AdMobBanner.Standard
//        anchors.top: parent.top
//        x: gameScene.rightPlayerTag.mapToItem(mainItem, 0, 0).x - adMobBanner.width
//        visible: window.showAdvertisements && gameScene.opacity === 1

//        // track when ad is displayed
//        onAdReceived: {
//            if(adMobBanner.visible) {
//                //        ga.logEvent("System", "Display AdMob Banner")
//                //        flurry.logEvent("AdMobBanner.Display")
//            }
//        }

//        // track when ad is clicked
//        onAdOpened: {
//            if(adMobBanner.visible) {
//                //        ga.logEvent("User", "AdMob Banner Clicked")
//                //        flurry.logEvent("AdMobBanner.Clicked")
//            }
//        }

//        testDeviceIds: Constants.adMobTestDeviceIds
//    }

//    // dummy mousearea to lock whole game while interstitial is showing
//    // otherwise user may click something in short time until it opens up
//    MouseArea {
//        id: lockScreenArea
//        visible: false
//        enabled: Constants.lockScreenForInterstitial // disabled for testing purposes (would lock screen forever if no ad is received)
//        anchors.fill: parent
//    }

    // interstitial to show when quitting a game
//    AdMobInterstitial {
//        id: adMobInterstitial
//        adUnitId: Constants.adMobInterstitialUnitId

//        property real startTime: 0 // holds time when interstitial is shown
//        property real elapsedTime: 0 // to measure duration the player watches the interstitial

//        // keep state of cached interstitial
//        property bool hasInterstitial: false
//        property bool displayWhenLoaded: false

//        // handle interstitial received
//        onInterstitialReceived: {
//            hasInterstitial = true
//            if(displayWhenLoaded)
//                showInterstitialIfLoaded()
//        }

//        // handle interstitial failed
//        onInterstitialFailedToReceive: {
//            hasInterstitial = false
//            if(displayWhenLoaded) {
//                // user is still waiting for video to show and screen is locked -> notify user and unlock screen
//                displayWhenLoaded = false
//                lockScreenArea.visible = false
//                noVideoDialog.visible = true
//            }
//        }

//        // load interstitial at app start to cache it
//        Component.onCompleted: {
//            loadInterstitial()
//        }

//        // show interstitial and open menu
//        // fromWhereShown is a string with the location where the displayInterstitial was shown from used for analytics
//        function displayInterstitial(openMenu, forceAd, fromWhereShown) {
//            // only show ads on mobile and if ads are enabled or:
//            // a.) showAdvertisements is true which is only the case if <10 tokens
//            // b.) forceAd is true, which is only set from StoreScene because we also allow to watch a video and earn a token if >10 tokens
//            if(!system.desktopPlatform && (window.showAdvertisements || forceAd)) {
//                if(openMenu) {
//                    window.state = "menu"
//                }
//                lockScreenArea.visible = true // lock screen until interstitial is actually opened
//                watchVideoDialog.visible = true // show dialog before starting video

//                //        flurry.logEvent("AdMobInterstitial.Show", {"fromWhereShown": fromWhereShown})
//            }
//            else if(openMenu) {
//                // jump to menu if no ads
//                window.state = "menu"
//            }
//        }


//        // track interstitial behavior
//        onInterstitialOpened: {
//            //      ga.logEvent("System", "Display AdMob Interstitial")
//            //      flurry.logEvent("AdMobInterstitial.Display")
//            //      flurry.logTimedEvent("Interstitial.Running")
//            startTime = new Date().getTime()
//            elapsedTime = 0
//            displayWhenLoaded = false      // deactivate auto display (to allow caching)
//            lockScreenArea.visible = false // unlock screen as soon as interstitial is opened
//        }

//        onInterstitialClosed: {
//            if(elapsedTime == 0) {
//                elapsedTime = new Date().getTime() - startTime
//                startTime = 0
//                //        flurry.endTimedEvent("Interstitial.Running")
//                if(elapsedTime > 10000) {
//                    storeScene.giveTokens(gameTokenEarnedPerVideoWatch) // reward player with 1 token for watching
//                    earnedTokenDialog.visible = true
//                }
//            }

//            //      ga.logEvent("User", "AdMob Interstitial Closed", "watched (ms)", elapsedTime)
//            //      flurry.logEvent("AdMobInterstitial.Closed", "watched (ms)", elapsedTime)

//            // request new interstitial
//            adMobInterstitial.hasInterstitial = false
//            adMobInterstitial.loadInterstitial()
//        }

//        onInterstitialLeftApplication: {
//            if(elapsedTime == 0) {
//                elapsedTime = new Date().getTime() - startTime
//                startTime = 0
//                //        flurry.endTimedEvent("Interstitial.Running")
//                if(elapsedTime > 10000) {
//                    storeScene.giveTokens(gameTokenEarnedPerVideoWatch) // reward player with 1 token for watching
//                    earnedTokenDialog.visible = true
//                }
//            }

//            //      ga.logEvent("User", "AdMob Interstitial Clicked", "watched (ms)", elapsedTime)
//            //      flurry.logEvent("AdMobInterstitial.Clicked", "watched (ms)", elapsedTime)
//        }

//        testDeviceIds: Constants.adMobTestDeviceIds
//    }

//    // dialog before starting video interstitial
//    OnuDialog {
//        id: watchVideoDialog
//        title: "Earn Game Tokens"
//        description: "Watch the following video to earn " + gameTokenEarnedPerVideoWatch + " game token!"
//        options: ["Ok"]
//        visible: false
//        onOptionSelected: {
//            if(adMobInterstitial.hasInterstitial)
//                adMobInterstitial.showInterstitialIfLoaded() // show interstitial
//            else {
//                adMobInterstitial.displayWhenLoaded = true
//                adMobInterstitial.loadInterstitial()
//            }
//            watchVideoDialog.visible = false // close dialog
//        }
//    }

//    // dialog for rewarding user with tokens
//    OnuDialog {
//        id: earnedTokenDialog
//        title: "Awesome!"
//        description: "You earned " + gameTokenEarnedPerVideoWatch + " game token."
//        options: ["Ok"]
//        visible: false
//        onOptionSelected: {
//            menuScene.tokenInfo.startAnimation()
//            visible = false
//        }
//    }

    // dialog for rewarding user with tokens
//    OnuDialog {
//        id: dailyTokenDialog
//        title: "Daily Bonus"
//        description: "Welcome Back! You earned " + gameTokensEarnedPerDay + " game token for playing today."
//        options: ["Ok"]
//        visible: false
//        onOptionSelected: {
//            menuScene.tokenInfo.startAnimation()
//            visible = false
//        }
//    }

    // dialog to show if user has no tokens
//    OnuDialog {
//        id: noTokenDialog
//        title: "No Game Tokens"
//        description: "Playing a game requires one game token."
//        options: ["Watch Video (+" + gameTokenEarnedPerVideoWatch + " Token)", "Buy Tokens"]
//        visible: false

//        property var customHandler // handler for custom 3rd option

//        onOptionSelected: {
//            if(index === 0)
//                adMobInterstitial.displayInterstitial(false, false, "beforeStartFromMainMenu") // show interstitial without opening menu
//            else if(index === 1) {
//                storeScene.previousState = window.state      // memorize previous screen
//                window.state = "store"                       // open store
//            }
//            else if(index === 2 && customHandler !== undefined)
//                customHandler()
//            visible = false // close dialog
//        }
//    }

//    // dialog to show if no video is available
//    OnuDialog {
//        id: noVideoDialog
//        title: "No Video"
//        description: "The video could not be loaded. Please try again later."
//        options: ["Ok"]
//        visible: false
//        onOptionSelected: visible = false
//    }


    // checks if user has enough tokens before starting game
//    function checkTokens(allowedHandler, customOption, optionHandler) {
//        if(storeScene.tokens > 0 || !enableStoreAndAds)
//            allowedHandler()
//        else {
//            if(customOption === undefined) {
//                noTokenDialog.options = noTokenDialog.options.slice(0, 2) // remove 3rd option
//                noTokenDialog.customHandler = undefined
//            }
//            else {
//                noTokenDialog.options[2] = customOption // set custom 3rd option
//                noTokenDialog.customHandler = optionHandler
//            }
//            noTokenDialog.optionsChanged() // signal change in options
//            noTokenDialog.visible = true
//        }
//    }

    // calculates remaining time for daily bonus
//    function getTimeUntilBonus() {
//        var now = new Date().getTime()
//        var next = menuScene.localStorage.lastLogin + (24 * 60 * 60 * 1000)
//        var remaining = next - now

//        var seconds = Math.ceil((remaining / 1000) % 60)
//        var minutes = Math.floor((remaining / 1000 / 60) % 60)
//        var hours = Math.floor((remaining / 1000 / 60) / 60)

//        if(seconds === 60) {
//            minutes++
//            seconds = 0
//        }
//        if(minutes === 60) {
//            hours++
//            minutes = 0
//        }
//        if(hours < 0)
//            hours = 0
//        if(minutes < 0)
//            minutes = 0
//        if(seconds < 0)
//            seconds = 0
//        return { hours: hours, minutes: minutes, seconds: seconds }
//    }
}
