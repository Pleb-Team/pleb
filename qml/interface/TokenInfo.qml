import Felgo 3.0
import QtQuick 2.0
import QtGraphicalEffects 1.0

// token info
Item {
  id: tokenInfo
  width: contentRow.width
  height: tokenText.implicitHeight + 5

  property int tokens: 0
  signal clicked()

  // background
  Item {
    anchors.fill: parent
    clip: true
    Rectangle {
      color: Qt.rgba(0,0,0,0.5)
      width:  parent.width + radius
      height: parent.height
      radius: 10
      x: radius
    }
  }

  // content
  Row {
    id: contentRow
    x: -15
    anchors.verticalCenter: parent.verticalCenter
    spacing: 4

    Image {
      source: "../../assets/img/OnuTokens.png"
      width: 45
      fillMode: Image.PreserveAspectFit
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      id: tokenText
      text: tokenInfo.tokens
      color: "white"
      font.pixelSize: 16
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  // handle clicked
  MouseArea {
    anchors.fill: parent
    onClicked: tokenInfo.clicked()
  }

  // animation when token value changes
  SequentialAnimation {
    id: tokenAnimation
    PropertyAnimation {
      target: contentRow
      property: "scale"
      to: 1.10
      duration: 150
    }
    PropertyAnimation {
      target: contentRow
      property: "scale"
      duration: 150
      to: 1
    }
  }

  function startAnimation() {
    tokenAnimation.start()
  }
}
