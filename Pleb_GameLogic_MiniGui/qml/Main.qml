import Felgo 3.0
import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.11
import io.qt.examples.backend 1.0

GameWindow {
    id: gameWindow

    // You get free licenseKeys from https://felgo.com/licenseKey
    // With a licenseKey you can:
    //  * Publish your games & apps for the app stores
    //  * Remove the Felgo Splash Screen or set a custom one (available with the Pro Licenses)
    //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
    //licenseKey: "<generate one from https://felgo.com/licenseKey>"

    // the size of the Window can be changed at runtime by pressing Ctrl (or Cmd on Mac) + the number keys 1-8
    // the content of the logical scene size (480x320 for landscape mode by default) gets scaled to the window size based on the scaleMode
    // you can set this size to any resolution you would like your project to start with, most of the times the one of your main target device
    // this resolution is for iPhone 4 & iPhone 4S
    screenWidth: 960
    screenHeight: 640

    // sync deck with leader and set up the game
    function showCards(){

        // Show cards and highlight current player
        var s = ""
        for (var i = 0; i < backend.getNumberPlayersMax(); i++)
        {
            if (i === backend.getActualPlayerID())
                s = s + "-->\tPlayer " + i + ": " + backend.getPlayerCardsText(i) + "\n";
            else
                s = s + "\tPlayer " + i + ": " + backend.getPlayerCardsText(i) + "\n";
        }
        textPlayerCards.text = s;
    }


    BackEnd {
        id: backend
        onPlayerCardsTextChanged: showCards()
        onPlayerCardsChanged: showCards()
        onActualPlayerIDChanged: showCards()
    }
	
	
    Scene {
        id: scene

        // the "logical size" - the scene content is auto-scaled to match the GameWindow size
        width: 480
        height: 400

        Rectangle {
            anchors.fill: scene.gameWindowAnchorItem
            color: "blue"
        }

        Text {
            id: textPlayerCards
            text: "Card distribution" // backend.playerCardsText
        }

        GridLayout {
            id: gridPlayer
            anchors.top: textPlayerCards.bottom
            columns: 2

            Text { text: "Number" }
            TextField {
                placeholderText: qsTr("3")
                onTextChanged: backend.moveSimpleNumber = text
            }

            Text { text: "Value (0..7)"  }
            TextField {
                placeholderText: qsTr("2")
                onTextChanged: backend.moveSimpleValue = text
            }

            Text { text: "Resulting Description"  }
            Text {
                text: backend.moveSimpleText
            }

            Button {
                text: "Play it!"
                onClicked: backend.playCards();
            }
        }




        GridLayout {
            id: gridGame

            columns: 2
            anchors.top: gridPlayer.bottom

            Text { text: "Actual Player"  }
            Text {
                text: backend.actualPlayerID
            }

            Text { text: "Last Move"  }
            Text {
                text: backend.lastMoveSimpleText
            }

            Text { text: "Last Player"  }
            Text {
                text: backend.lastPlayerID
            }

            Text { text: "Stack"  }
            Text {
                text: "Stack"
            }
        }
    }
}
