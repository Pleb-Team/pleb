import QtQuick 2.0

// recognizes swipes and switches between scenes
MouseArea {
  property int startX
  property int startY

  // direction signals
  signal swipeRight
  signal swipeLeft

  onPressed: {
    startX = mouse.x
    startY = mouse.y
  }

  onReleased: {
    var deltax = mouse.x - startX
    var deltay = mouse.y - startY

    if (Math.abs(deltax) > 50 || Math.abs(deltay) > 50) {
      if (deltax > 30 && Math.abs(deltay) < 30) {
        // swipe left
        swipeLeft();
      } else if (deltax < -30 && Math.abs(deltay) < 30) {
        // swipe right
        swipeRight();
      }
    }
  }
}
