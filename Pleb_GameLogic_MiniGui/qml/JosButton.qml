import QtQuick 2.0

Rectangle {
    width: 100
    height: 50
    color: "gray"

    Text {
        id: josButtonText
        text: "Jos Button"
    }

    MouseArea {
        anchors.fill: parent;
        onClicked: {
            josButtonText.text = "Gedrückt!";
        }
    }
}
