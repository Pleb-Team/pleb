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


    // menu scene
    MenuScene {
        id: menuScene

        // switch scenes after pressing a MenuButton
        onMenuButtonPressed: {

            switch (button){
            case "single":
                console.debug("[MainItem] MeanuScene::onMenuButtonPressed 'single': start")
                multiplayer.createSinglePlayerGame()
                window.state = "game"
                console.debug("[MainItem] MenuScene::onMenuButtonPressed 'single': finish")
                break

            case "matchmaking":
                multiplayer.showMatchmaking()
                window.state = "multiplayer"
                break

            case "quick":
                multiplayer.joinOrCreateGame()
                multiplayer.showMatchmaking()
                window.state = "multiplayer"
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
            console.debug("[MainItem] GameScene::onBackButtonPressed() start")

            if(!gameScene.leaveGameWindow.visible)
                gameScene.leaveGameWindow.visible = true
            else
                window.state = "menu"

            console.debug("[MainItem] GameScene::onBackButtonPressed() finish")
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
}
