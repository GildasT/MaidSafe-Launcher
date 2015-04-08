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
  id: item

  readonly property int dataIndex: index
  readonly property QtObject dataModel: model
  property bool dragActive: mouseArea.drag.active

  width: gridView.columnWidth
  height: gridView.rowHeight + (detailsBox.item === this ? detailsBox.height : 0)
  opacity: ! detailsBox.detailedItem || detailsBox.detailedItem === this ? 1 : .5
  Behavior on opacity { NumberAnimation { duration: gridView.dropDownAnimationDuration } }
  focus: true

  signal clicked()
  onClicked: {
    if (model.hasModelChildren || detailsBox.detailedItem === item)
      detailsBox.detailedItem = null
    else
      detailsBox.detailedItem = item
  }
  signal doubleClicked()
  onDoubleClicked: {
    if (model.hasModelChildren) {
      childGridView.model.rootIndex = childGridView.model.modelIndex(item.dataIndex)
      childGridView.transformOrigin = Item.TopLeft
      childGridView.scale = 0.25
      childGridView.width = (gridView.iconSize - 2) / childGridView.scale
      childGridView.height = (gridView.iconSize - 2) / childGridView.scale
      var point = rootGridView.mapFromItem(decoration, 0, 0);
      childGridView.x = point.x +1
      childGridView.y = point.y +1
//      console.log(point.x + " " + point.y)
      childGridView.visible = true
    }
  }

  onDragActiveChanged: {
    detailsBox.item = null
    item.focus = true
    if (dragActive) {
      endDragAnimation.running = false
      moveTrans.enabled = true
      backgroundDropArea.visible = true
      mouseArea.parent = mainWindowItem
    } else {
      moveTrans.enabled = false
      resetNeighbourTimer.restart()
      mouseArea.parent = item
      var newPosition = mainWindowItem.mapToItem(item, mouseArea.x, mouseArea.y)
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
      item.leftNeighbour = item.getLeftNeighbour()
      item.rightNeighbour = item.getRightNeighbour()
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
      homePageController_.move(drag.source.dataModel.index, index)
      backgroundDropArea.visible = true
    }
  }

  MouseArea {
    id: mouseArea

    opacity: item.dragActive ? .4 : 1
    width: gridView.columnWidth
    height: gridView.rowHeight

    onClicked: item.clicked()
    onDoubleClicked: item.doubleClicked()
    Drag.active: item.dragActive
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2
    Drag.source: item
    drag.target: !gridView.filtering ? mouseArea : null

    Component {
      id: applicationComponent

      Image {
        source: dataModel.icon
        height: parent.height
        fillMode: Image.PreserveAspectFit
      }
    }
    Component {
      id: groupComponent

      Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        border { width: 1; color: "#4d4d4d" }
        radius: 8
        Grid {
          id: groupGrid
          anchors.fill: parent
          anchors.margins: 8
          columns: 2
          rows: 2
          spacing: 8
          Repeater {
            model: dataModel.groupIcons
            Image {
              source: dataModel.groupIcons[index]
              height: 20
              fillMode: Image.PreserveAspectFit
            }
          }
        }
      }
    }
    Loader {
      id: decoration
      anchors {
        top: parent.top
        horizontalCenter: parent.horizontalCenter
        topMargin: 16
      }
      height: gridView.iconSize
      width: gridView.iconSize
      readonly property QtObject dataModel: model
      sourceComponent: model.hasModelChildren ? groupComponent : applicationComponent
    }

    Text {
      id: text

      text: model.name
      anchors {
        left: parent.left
        top: decoration.bottom
        right: parent.right
        bottom: parent.bottom
        topMargin: 12
        bottomMargin: 10
      }
      verticalAlignment: Text.AlignVCenter
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideMiddle
      font.pixelSize: 12
      font.underline: item.activeFocus
      color: gridView.iconTextColor
    }
  }
}