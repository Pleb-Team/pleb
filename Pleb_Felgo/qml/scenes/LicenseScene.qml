import Felgo 3.0
import QtQuick 2.0
import QtQuick.Controls 1.4
import "../common"

// scene describing the game rules
SceneBase {
    id: licenseScene

    signal menuButtonPressed(string button)


    // background
    Image {
        id: background
        source: "../../assets/img/BG.png"
        anchors.fill: licenseScene.gameWindowAnchorItem
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    Image {
        id: imageGPL
        height: 30
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 35
        source: "../../assets/img/gplv3-127x51.png"
    }


    // content window
    Rectangle {
        id: infoRect
        radius: 15

        anchors.top: imageGPL.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 35
        anchors.right: parent.right
        anchors.rightMargin: 35
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 35


        color: "white"
        border.color: "darkred"
        border.width: 1

        ScrollView {
            id: scrollView
            anchors.fill: parent
            anchors.margins: 10

            Text {
                anchors.fill: parent.anchors
                font.pixelSize: 9
                text: fileUtils.readFile("../../../../LICENSE")
            }
        }
    }

    // switch between the scenes with swipe motions
    SwipeArea {
        anchors.fill: parent
        onSwipeRight: menuButton.clicked()
        onSwipeLeft: backButtonPressed()
    }

    // back button to leave scene
    ButtonBase {
        width: 25
        height: 25
        buttonImage.source: "../../assets/img/ArrowLeft.png"
        anchors.left: gameWindowAnchorItem.left
        anchors.leftMargin: 10
        anchors.bottom: gameWindowAnchorItem.bottom
        anchors.bottomMargin: 10
        onClicked: {
            backButtonPressed()
        }
    }

    // button to main menu
    MenuButton {
        id: menuButton
        action: "menu"
        //  color: "transparent"
        width: 25
        height: 25
        buttonImage.source: "../../assets/img/Exit.png"
        anchors.right: gameWindowAnchorItem.right
        anchors.rightMargin: 10
        anchors.bottom: gameWindowAnchorItem.bottom
        anchors.bottomMargin: 10
    }
}
