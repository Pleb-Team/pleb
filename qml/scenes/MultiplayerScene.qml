import Felgo 3.0
import QtQuick 2.0
import "../common"

SceneBase {
  id: multiplayerScene
  property alias state: multiplayerview.state
  property alias mpView: multiplayerview

  MultiplayerView{
    gameNetworkItem: gameNetwork
    tintColor: "#28a3c1"

    id: multiplayerview

    onBackClicked: {
      backButtonPressed()
    }

    onShowCalled: {
      window.state = "multiplayer"
    }
  }

  onVisibleChanged: {
    if(visible) {
      ga.logScreen("MultiplayerScene")
      flurry.logEvent("Screen.MultiplayerScene")
    }
  }

  function show(state){
    multiplayerview.show(state)
  }
}
