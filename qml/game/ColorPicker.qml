import QtQuick 2.0
import Felgo 3.0
import "../common"

// select the color for wild and wild4 cards
Item {
  id: colorPicker
  width: 200
  height: 200
  z: 110

  // true while the user is chosing a color
  property bool chosingColor: false


  // visual representation of the colorPicker
  Image {
    id: colorImage
    anchors.fill: parent
    source: "../../assets/img/ColorPicker.png"
    smooth: true
  }

  // clickable areas for each selectable color
  ButtonBase {
    radius: 10
    width: parent.width/2
    height: parent.height/2
    anchors.top: parent.top
    anchors.left: parent.left
    onClicked: colorPicked("yellow")
  }

  ButtonBase {
    radius: 10
    width: parent.width/2
    height: parent.height/2
    anchors.top: parent.top
    anchors.right: parent.right
    onClicked: colorPicked("red")
  }

  ButtonBase {
    radius: 10
    width: parent.width/2
    height: parent.height/2
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    onClicked: colorPicked("green")
  }

  ButtonBase {
    radius: 10
    width: parent.width/2
    height: parent.height/2
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    onClicked: colorPicked("blue")
  }

  // returns a random color
  function randomColor(){
    var colors = ["yellow", "red", "green", "blue"]
    var index = Math.floor(Math.random() * (4))
    return colors[index]
  }
}
