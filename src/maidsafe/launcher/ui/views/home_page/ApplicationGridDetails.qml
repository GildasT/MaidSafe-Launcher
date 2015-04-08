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
  id: detailsBox

  readonly property int openedHeight: 180
  readonly property color detailsBackgroundColor: "#ffffff"
  readonly property color detailsBorderColor: "#4d4d4d"
  readonly property color detailsTextColor: "#4d4d4d"

  property Item detailedItem: null
  // when closing, item is set to null only at the end of the animation
  // to keep the content of the detail box during the closing animation
  onDetailedItemChanged: {
    changeItemValueTimer.stop()
    if (item && !detailedItem) {
      changeItemValueTimer.start()
    } else {
      item = detailedItem
    }
  }
  property Item item: null
  onItemChanged: detailedItem = item
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
  y: detailsBox.item ? detailsBox.item.y + gridView.rowHeight + grid.anchors.topMargin : 0
  height: detailedItem ? 180 : 0
  Behavior on height { NumberAnimation { duration: gridView.dropDownAnimationDuration } }
  clip: true

  Rectangle {
    anchors.fill: parent
    anchors.topMargin: 16

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
        id: textDetails

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
          text: detailsBox.item ? detailsBox.item.dataModel.name : " "
          color: detailsBox.detailsTextColor
          font.pixelSize: 25
          elide: Text.ElideMiddle
        }
        CustomText {
          width: parent.width
          text: qsTr("Last accessed: ") + (detailsBox.item ? detailsBox.item.dataModel.lastAccess : " ")
          color: detailsBox.detailsTextColor
          font.pixelSize: 16
          elide: Text.ElideMiddle
        }
        CustomText {
          width: parent.width
          text: qsTr("Location: ") + (detailsBox.item ? detailsBox.item.dataModel.path : " ")
          color: detailsBox.detailsTextColor
          font.pixelSize: 16
          elide: Text.ElideMiddle
        }
        CustomText {
          height: 60
          width: parent.width
          text: qsTr("Access to SAFEDrive: ") + (detailsBox.item ? detailsBox.item.dataModel.driveAccess : " ")
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
        id: bottomBorder

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
