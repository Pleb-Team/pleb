import QtQuick 2.0
import '.'

// button variation to switch scenes
ButtonBase {
  id: menuButton
  width: 140

  property string action: (typeof text !== "undefined") ? text.toLowerCase() : undefined

  onClicked: menuButtonPressed(action)
}
