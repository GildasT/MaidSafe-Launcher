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
import QtQuick.Controls 1.3

FocusScope {
  id: gridView

  readonly property int dropDownAnimationDuration: 100
  readonly property int moveAnimationDuration: 200

  readonly property color iconTextColor: "#4d4d4d"

  readonly property int iconSize: 64
  readonly property int minimumColumnWidth: iconSize + 60
  readonly property int rowHeight: iconSize + 48

  property int columnWidth: width / grid.columns

  property bool filtering: false

  height: grid.height + grid.anchors.topMargin + grid.anchors.bottomMargin
  focus: true

  ExclusiveGroup { id: exclusiveGroup }

  Timer { id: resetNeighbourTimer; interval: 0 }

  Connections {
    target: customTitleBarLoader.item.searchField
    onTextChanged: {
      var text = customTitleBarLoader.item.searchField.text
      if (text === "") {
        gridRepeater.model = homePageController_.homePageModel
        gridView.filtering = false
      } else {
        gridRepeater.model = homePageController_.homePageFilterModel
        gridView.filtering = true
      }
      homePageController_.homePageFilterModel.setFilterWildcard(text)
    }
  }

  DropArea {
    id: backgroundDropArea
    anchors.fill: parent
    onEntered: {
      homePageController_.move(drag.source.modelData.index,
                               gridRepeater.count - 1)
      // when entering this background area, it needs to be hidden
      // because the drag item cannot enter another DropArea
      backgroundDropArea.visible = false
    }
  }

  Grid {
    id: grid

    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      topMargin: 18
      bottomMargin: 18
    }

    columns: Math.max(1, width / minimumColumnWidth)

    move: Transition {
      id: moveTrans

      enabled: false
      SequentialAnimation {
        NumberAnimation {
          property: "x"
          to: moveTrans.ViewTransition.item.x +
              (moveTrans.ViewTransition.destination.x - moveTrans.ViewTransition.item.x) / 2 +
              (moveTrans.ViewTransition.destination.y - moveTrans.ViewTransition.item.y) /
              gridView.rowHeight * gridView.width
          duration: moveTrans.ViewTransition.item.dragActive ?
                      0
                    :
                      gridView.moveAnimationDuration / 2
        }
        NumberAnimation {
          property: "x"
          to: moveTrans.ViewTransition.item.x +
              (moveTrans.ViewTransition.destination.x - moveTrans.ViewTransition.item.x) / 2 +
              (moveTrans.ViewTransition.destination.y - moveTrans.ViewTransition.item.y) / gridView.rowHeight * -gridView.width
          duration: 0
        }
        PropertyAction {
          property: "y"
        }
        NumberAnimation {
          property: "x"
          duration: moveTrans.ViewTransition.item.dragActive ?
                      0
                    :
                      gridView.moveAnimationDuration / 2
        }
      }
    }

    MouseArea {
      id: addAppMouseArea

      visible: !gridView.filtering
      width: gridView.columnWidth
      height: gridView.rowHeight
      opacity: detailsBox.detailedItem ? .5 : 1
      Behavior on opacity { NumberAnimation { duration: gridView.dropDownAnimationDuration } }

      hoverEnabled: true
      onClicked: fileDialog.open()

      Image {
        anchors.centerIn: parent
        source: addAppMouseArea.pressed ?
                  "/resources/images/home_page/add_button_pressed.png"
                : addAppMouseArea.containsMouse ?
                  "/resources/images/home_page/add_button_hover.png"
                :
                  "/resources/images/home_page/add_button_normal.png"
      }
    }

    Repeater {
      id: gridRepeater

      model: homePageController_.homePageModel

      onCountChanged: resetNeighbourTimer.restart()

      delegate: ApplicationGridItem {
        width: gridView.columnWidth
        height: gridView.rowHeight + (detailsBox.item === this ? detailsBox.height : 0)

        opacity: ! detailsBox.detailedItem || detailsBox.detailedItem === this ? 1 : .5
        Behavior on opacity { NumberAnimation { duration: gridView.dropDownAnimationDuration } }
      }
    }
  }

  ApplicationGridDetails { id: detailsBox }
}
