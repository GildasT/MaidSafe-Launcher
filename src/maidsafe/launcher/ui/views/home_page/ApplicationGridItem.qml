/*  Copyright 2015 MaidSafe.net limited

    This MaidSafe Software is licensed to you under (1) the MaidSafe.net Commercial License,
    version 1.0 or later, or (2) The General Public License (GPL), version 3, depending on which
    licence you accepted on initial access to the Software (the "Licences").

    By contributing code to the MaidSafe Software, or to this project generally, you agree to be
    bound by the terms of the MaidSafe Contributor Agreement, version 1.0, found in the root
    directory of this project at LICENSE, COPYING and CONTRIBUTOR respectively and also
    available at: http://www.maidsafe.net/licenses

    Unless required by applicable law or agreed to in writing, the MaidSafe Software distributed
    under the GPL Licence is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
    OF ANY KIND, either express or implied.

    See the Licences for the specific language governing permissions and limitations relating to
    use of the MaidSafe Software.                                                                 */

import QtQuick 2.4

FocusScope {
  id: application

  readonly property QtObject modelData: model
  property bool dragActive: mouseArea.drag.active

  focus: true

  signal clicked()
  onClicked: {
    if (detailsBox.detailedItem === application)
      detailsBox.detailedItem = null
    else
      detailsBox.detailedItem = application
  }
  onDragActiveChanged: {
    detailsBox.item = null
    application.focus = true
    if (dragActive) {
      endDragAnimation.running = false
      moveTrans.enabled = true
      backgroundDropArea.visible = true
      mouseArea.parent = mainWindowItem
    } else {
      moveTrans.enabled = false
      resetNeighbourTimer.restart()
      mouseArea.parent = application
      var newPosition = mainWindowItem.mapToItem(application, mouseArea.x, mouseArea.y)
      mouseArea.x = newPosition.x
      mouseArea.y = newPosition.y
      endDragAnimation.running = true
    }
  }
  NumberAnimation {
    id: endDragAnimation
    target: mouseArea
    properties: "x,y"
    to: 0
    duration: gridView.moveAnimationDuration
  }

  function getLeftNeighbour() {
    return gridRepeater.itemAt(index ? index - 1 : gridRepeater.count - 1)
  }
  function getRightNeighbour() {
    return gridRepeater.itemAt(index + 1 >= gridRepeater.count ? 0 : index + 1)
  }
  property Item leftNeighbour: getLeftNeighbour()
  property Item rightNeighbour: getRightNeighbour()
  Connections {
    target: resetNeighbourTimer
    onTriggered: {
      application.leftNeighbour = application.getLeftNeighbour()
      application.rightNeighbour = application.getRightNeighbour()
    }
  }

  KeyNavigation.left:  leftNeighbour
  KeyNavigation.right: rightNeighbour
  Keys.onEnterPressed:  clicked()
  Keys.onReturnPressed: clicked()
  Keys.onSpacePressed:  clicked()

  DropArea {
    id: dropArea

    height: gridView.rowHeight
    width: gridView.columnWidth
    onEntered: {
      homePageController_.move(drag.source.modelData.index, index)
      backgroundDropArea.visible = true
    }
  }

  MouseArea {
    id: mouseArea

    opacity: application.dragActive ? .4 : 1
    width: gridView.columnWidth
    height: gridView.rowHeight

    onClicked: application.clicked()
    Drag.active: application.dragActive
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2
    Drag.source: application
    drag.target: !gridView.filtering ? mouseArea : null

    Rectangle {
      id: icon

      color: model.color
      width: gridView.iconSize
      height: gridView.iconSize
      anchors {
        top: parent.top
        horizontalCenter: parent.horizontalCenter
        topMargin: 16
      }
    }

    Text {
      id: text

      text: name
      anchors {
        left: parent.left
        top: icon.bottom
        right: parent.right
        bottom: parent.bottom
        topMargin: 12
        bottomMargin: 10
      }
      verticalAlignment: Text.AlignVCenter
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideMiddle
      font.pixelSize: 12
      font.underline: application.activeFocus
      color: gridView.iconTextColor
    }
  }
}
