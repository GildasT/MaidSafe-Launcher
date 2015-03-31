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

import "../../custom_components"

Item {

  Grid {
    id: gridView

    anchors.fill: parent

    signal dragActive()

    readonly property int dropDownAnimationDuration: 100

    readonly property color iconTextColor: "#4d4d4d"

    readonly property int iconSize: 64
    readonly property int minimumColumnWidth: iconSize + 60
    readonly property int rowHeight: iconSize + 48

    columns: Math.max(1, width / minimumColumnWidth)
    property int columnWidth: width / columns

    move: Transition {
      id: moveTransition

      enabled: false

      NumberAnimation {
        properties: "x,y"
        duration: 200
      }
    }

    MouseArea {
      id: addAppMouseArea

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

      onCountChanged: queuedConnectionTimer.restart()

      delegate: FocusScope {
        id: delegateRoot

        readonly property QtObject itemModel: model

        width: gridView.columnWidth
        height: detailsBox.item === this ?
                  gridView.rowHeight + detailsBox.height + detailsBox.topMargin
                :
                  gridView.rowHeight

        opacity: ! detailsBox.detailedItem || detailsBox.detailedItem === this ? 1 : .5
        Behavior on opacity { NumberAnimation { duration: gridView.dropDownAnimationDuration } }

        function getLeftNeighbour() {
          return gridRepeater.itemAt(model.index ? model.index - 1 : gridRepeater.count - 1)
        }
        function getRightNeighbour() {
          return gridRepeater.itemAt(model.index + 1 >= gridRepeater.count ? 0 : model.index + 1)
        }
        property Item leftNeighbour: getLeftNeighbour()
        property Item rightNeighbour: getRightNeighbour()
        Connections {
          target: queuedConnectionTimer
          onTriggered: {
            delegateRoot.leftNeighbour = delegateRoot.getLeftNeighbour()
            delegateRoot.rightNeighbour = delegateRoot.getRightNeighbour()
          }
        }

        KeyNavigation.left:  leftNeighbour
        KeyNavigation.right: rightNeighbour
        Keys.onEnterPressed:  iconArea.simulateMouseRelease()
        Keys.onReturnPressed: iconArea.simulateMouseRelease()

        MouseArea {
          id: iconArea

          height: gridView.rowHeight
          width: gridView.columnWidth
          anchors {
            left: parent.left
            top: parent.top
          }
          states: State {
            when: iconArea.drag.active
            ParentChange {
              target: iconArea
              parent: mainWindowItem
            }
            AnchorChanges {
              target: iconArea
              anchors {
                top: undefined
                left: undefined
              }
            }
          }


          property int index: model.index
          property bool checked: false
          onCheckedChanged: {
            if (checked) {
              detailsBox.detailedItem = delegateRoot
            } else if (detailsBox.detailedItem === delegateRoot) {
              detailsBox.detailedItem = null
            }
          }
          property bool wasDragged: false

          opacity: iconArea.drag.active ? .4 : 1
          Drag.active: iconArea.drag.active
          Drag.hotSpot.x: width / 2
          Drag.hotSpot.y: height / 2

          function simulateMouseRelease() {
            if (!wasDragged) {
              checked = !checked
            } else {
              moveTransition.enabled = false
              queuedConnectionTimer.restart()
              wasDragged = false
            }

            delegateRoot.focus = true
          }

          Component.onCompleted: {
            exclusiveGroup.bindCheckable(iconArea)
          }

          Binding on checked {
            when: iconArea.drag.active
            value: false
          }

          Connections {
            target: gridView
            onDragActive: {
              iconArea.checked = false
            }
          }

          drag.target: this
          onReleased: simulateMouseRelease()

          drag.onActiveChanged: {
            if (drag.active) {
              moveTransition.enabled = true
              iconArea.wasDragged = true
              gridView.dragActive()
            }
          }

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

            text: model.name
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
            color: gridView.iconTextColor
          }
        }

        DropArea {
          id: dropArea
          anchors.fill: parent

          onEntered: {
            homePageController_.move(drag.source.index, model.index)
          }
        }
      }
    }
  }


  Item {
    id: detailsBox

    readonly property int openedHeight: 180
    readonly property int topMargin: 16
    readonly property color detailsBackgroundColor: "#ffffff"
    readonly property color detailsBorderColor: "#4d4d4d"
    readonly property color detailsTextColor: "#4d4d4d"

    property Item detailedItem: null
    // when closing, item is set to null only at the end of the animation
    // to keep the content of the detail box during the closing animation
    property Item item: null
    onDetailedItemChanged: {
      changeItemValueTimer.stop()
      if (item && !detailedItem) {
        changeItemValueTimer.start()
      } else {
        item = detailedItem
      }
    }
    Timer {
      id: changeItemValueTimer
      interval: gridView.dropDownAnimationDuration
      onTriggered: detailsBox.item = detailsBox.detailedItem
    }

    visible: !!item

    anchors {
      left: parent.left
      right: parent.right
    }
    y: detailsBox.item ? detailsBox.item.y + gridView.rowHeight : 0
    height: detailedItem ? 180 : 0
    Behavior on height { NumberAnimation { duration: gridView.dropDownAnimationDuration } }
    clip: true

    Rectangle {
      anchors.fill: parent
      anchors.topMargin: detailsBox.topMargin

      border { width: 1; color: detailsBox.detailsBorderColor }

      Rectangle {
        id: arrowrect
        x: detailsBox.item ?
             detailsBox.item.x + detailsBox.item.width / 2 - width / 2
           : 0
        y: -height / 2 + 1
        height: 22
        width: height
        rotation: 45
        color: detailsBox.detailsBackgroundColor
        border { width: 1; color: detailsBox.detailsBorderColor }
      }

      Rectangle {
        anchors {
          fill: parent
          topMargin: 1
        }

        color: detailsBox.detailsBackgroundColor

        Column {
          anchors {
            top: parent.top
            topMargin: 10
            left: parent.left
            leftMargin: 50
            right: detailsControls.left
            rightMargin: 10
          }

          CustomText {
            height: 60
            width: parent.width
            text: detailsBox.item ? detailsBox.item.itemModel.name : " "
            color: detailsBox.detailsTextColor
            font.pixelSize: 25
            elide: Text.ElideMiddle
          }
          CustomText {
            width: parent.width
            text: detailsBox.item ? detailsBox.item.itemModel.prop0 : " "
            color: detailsBox.detailsTextColor
            font.pixelSize: 16
            elide: Text.ElideMiddle
          }
          CustomText {
            width: parent.width
            text: detailsBox.item ? detailsBox.item.itemModel.prop1 : " "
            color: detailsBox.detailsTextColor
            font.pixelSize: 16
            elide: Text.ElideMiddle
          }
          CustomText {
            height: 60
            width: parent.width
            text: detailsBox.item ? detailsBox.item.itemModel.prop2 : " "
            color: detailsBox.detailsTextColor
            font.pixelSize: 16
            elide: Text.ElideMiddle
          }
        }

        Item {
          id: detailsControls
          anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
          }
          width: 230

          Image {
            anchors {
              top: parent.top
              topMargin: 40
              right: deleteButton.left
              rightMargin: 20
            }
            source: openMouseArea.pressed ?
                      "/resources/images/home_page/open_icon_pressed.png"
                    : openMouseArea.containsMouse ?
                      "/resources/images/home_page/open_icon_hover.png"
                    :
                      "/resources/images/home_page/open_icon_normal.png"
            MouseArea {
              id: openMouseArea
              anchors.fill: parent
              hoverEnabled: true
            }
          }

          Image {
            id: deleteButton
            anchors {
              top: parent.top
              topMargin: 40
              right: parent.right
              rightMargin: 50
            }
            source: deleteMouseArea.pressed ?
                      "/resources/images/home_page/delete_icon_pressed.png"
                    : deleteMouseArea.containsMouse ?
                      "/resources/images/home_page/delete_icon_hover.png"
                    :
                      "/resources/images/home_page/delete_icon_normal.png"
            MouseArea {
              id: deleteMouseArea
              anchors.fill: parent
              hoverEnabled: true
            }
          }

          CustomText {
            anchors {
              right: parent.right
              rightMargin: 50
              top: deleteButton.bottom
              topMargin: 20
            }
            text: qsTr("ADVANCED")
            color: detailsBox.detailsTextColor
            font.pixelSize: 15
          }
        }
        Rectangle {
          // bottom border
          anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
          }
          height: 1
          color: detailsBox.detailsBorderColor
        }
      }
    }
  }
}
