import Felgo 3.0
import QtQuick 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4
import "../common"

SceneBase {
  id: gameNetworkScene

  property alias gnView: myGameNetworkView


  GameNetworkView {
    id: myGameNetworkView
    onBackClicked: window.state = 'menu'
    gameNetworkItem: gameNetwork
    state: "leaderboard"
    tintColor: "#28a3c1"
    anchors.fill: gameWindowAnchorItem
  }

  onVisibleChanged: {
    if(visible) {
      ga.logScreen("GameNetworkScene")
      flurry.logEvent("Screen.GameNetworkScene")
    }
  }
}


