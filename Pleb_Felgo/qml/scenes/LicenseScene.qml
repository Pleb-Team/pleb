import Felgo 3.0
import QtQuick 2.0
import QtQuick.Controls 1.4
import "../common"

// scene showing the license
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


    // content window
    Rectangle {
        id: infoRect
        radius: 15
        anchors.centerIn: gameWindowAnchorItem
        width: gameWindowAnchorItem.width - 70
        height: gameWindowAnchorItem.height - 70
        color: "white"
        border.color: "darkred"
        border.width: 1

        ScrollView {
            id: scrollView
            anchors.fill: infoRect
            anchors.margins: 10
            flickableItem.flickableDirection: Flickable.AutoFlickIfNeeded

//            horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
//            verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn

//            flickableItem.boundsBehavior: Flickable.StopAtBounds
        //    flickableItem.flickableDirection: Flickable.VerticalFlick

//            clip: true


            Image {
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                height: 35

                source: "../../assets/img/gplv3-127x51.png"
            }

            Text {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 10
                width: infoRect.width - 40

                font.pixelSize: 9
                wrapMode: Text.Wrap
                text: fileUtils.readFile(Qt.resolvedUrl("../../assets/text/LICENSE_All.txt"))
            }
        }
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
