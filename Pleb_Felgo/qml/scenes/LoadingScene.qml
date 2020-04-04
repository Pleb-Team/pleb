import Felgo 3.0
import QtQuick 2.0
import "../common"

SceneBase {
  id: loadingScene

  // background
  Image {
    id: background
    source: "../../assets/img/BG.png"
    anchors.fill: loadingScene.gameWindowAnchorItem
    fillMode: Image.PreserveAspectCrop
    smooth: true
  }

  // loading text
  Text {
    id: loaderText
    horizontalAlignment: Text.AlignHCenter
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: titleImage.bottom
    anchors.topMargin: 40
    font.pixelSize: 14
    color: "#f9c336"
    text: "Loading ..."
    font.family: standardFont.name
  }

  // loading animation
  SequentialAnimation {
    running: true
    loops: Animation.Infinite

    PropertyAnimation {
      target: loaderText
      property: "scale"
      to: 1.05
      duration: 2000
    }
    PropertyAnimation {
      target: loaderText
      property: "scale"
      to: 1
      duration: 2000
    }
  }

  // the title image
  Image {
    id: titleImage
    anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
    anchors.top: gameWindowAnchorItem.top
    anchors.topMargin: 35
    source: "../../assets/img/Title.png"
    fillMode: Image.PreserveAspectFit
    width: 380
  }

  Component.onCompleted: {
//    ga.logScreen("LoadingScene") // log loading scene at startup
//    flurry.logEvent("Screen.LoadingScene")
  }
}
