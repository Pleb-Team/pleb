// import Felgo 3.0
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.11
import io.qt.examples.backend 1.0

ApplicationWindow {
    id: gameWindow
    visible: true
    width: 640
    height: 480
    title: "Pleb MiniGui"
    
    
    Label {
        text: "Hello world"
        anchors.centerIn: parent
    }
    


    BackEnd {
        id: backend

        // Update the card display whenever needed
        //        onPlayerCardsTextChanged: showCards()
        //        onPlayerCardsChanged: showCards()
        //        onActualPlayerIDChanged: showCards()
        //        Component.onCompleted: showCards();
    }


    Rectangle {
        anchors.fill: parent
        color: "lightblue"
    }

    Text {
        id: textPlayerCards
        font.family: "Courier New"
        text: backend.playerCardsText
    }

    GridLayout {
        anchors.top: textPlayerCards.bottom
        columns: 2

        Text { text: "Number cards" }
        TextField {
            placeholderText: "1"
            onTextChanged: backend.moveSimpleNumber = text
        }

        Text { text: "Value (0..7)"  }
        TextField {
            placeholderText: "0"
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
}
