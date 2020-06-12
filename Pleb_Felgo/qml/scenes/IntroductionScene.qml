import Felgo 3.0
import QtQuick 2.0
import "../common"

// scene describing the game rules
SceneBase {
    id: introductionScene

    signal menuButtonPressed(string button)


    // background
    Image {
        id: background
        source: "../../assets/img/BG.png"
        anchors.fill: introductionScene.gameWindowAnchorItem
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
        border.color: Constants.sBorderColor
        border.width: 1
    }
    
//    // credits
//    Text {
//        anchors.bottom: infoRect.bottom
//        anchors.bottomMargin: 5
//        anchors.right: infoRect.right
//        anchors.rightMargin: 15
//        font.pixelSize: 8
//        color: Constants.sBorderColor
//        text: "Music: Bensound.com, Sound Effects: freesound.org"
//    }


    // the header
    Text {
        anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.top: gameWindowAnchorItem.top
        anchors.topMargin: 60
        font.pixelSize: 20
        font.family: standardFont.name
        color: Constants.sBorderColor
        text: "Welcome to Pleb"
    }

    Row
    {
        spacing: 13
        anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
        anchors.top: gameWindowAnchorItem.top
        anchors.topMargin: 100

        Column
        {
            spacing: 10

            Text
            {
                font.pixelSize: 9
                color: "black"
                width: 300
                wrapMode: Text.WordWrap
                text: "This new implementation of the popular card came 'President' (a.k.a. 'Arschloch') is the outcome of our team hackaton in Stuttgart, 2020, " +
                      "established during the crisis. We aim at demonstrating that despite the lockdown, it is possible to stick together and use the " +
                      "time meaningfully e.g. by studying a new, fun technique of creating games." + "\n\n" +
                      "Contributors: Joachim, Ben, Max, Sebastian, Sven" + "\n" +
                      "Happy playing! "
            }

            Text
            {
                font.pixelSize: 9
                color: "black"
                width: 300
                wrapMode: Text.WordWrap
                text: "Find more information on our <a href=\"https://github.com/Pleb-Team/pleb\">Pleb project website</a>."
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Text
            {
                font.pixelSize: 9
                color: "black"
                width: 200
                wrapMode: Text.WordWrap
                text: "Contact or feedback: <a href=\"mailto:stuggihackaton@gmail.com?subject=Feedback\%20about\%20Pleb\">stuggihackaton@gmail.com</a>."
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }


        Image
        {
            width: 80
            height: 60
            //           anchors.horizontalCenter: parent.horizontalCenter
            source: "../../assets/img/Stuttgart.png"
            smooth: true
        }
    }



    // back button to leave scene
    ButtonBase {
        width: 25
        height: 25
        buttonImage.source: "../../assets/img/Exit.png"
        anchors.left: gameWindowAnchorItem.left
        anchors.leftMargin: 10
        anchors.bottom: gameWindowAnchorItem.bottom
        anchors.bottomMargin: 10
        onClicked: {
            backButtonPressed()
        }
    }

    // button to cardScene
    MenuButton {
        id: cardButton
        action: "cards"
        //    color: "transparent"
        width: 25
        height: 25
        buttonImage.source: "../../assets/img/ArrowRight.png"
        anchors.right: gameWindowAnchorItem.right
        anchors.rightMargin: 10
        anchors.bottom: gameWindowAnchorItem.bottom
        anchors.bottomMargin: 10
    }
}
