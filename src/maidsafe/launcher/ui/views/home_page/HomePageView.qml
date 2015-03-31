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
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.3

import SAFEAppLauncher.HomePageController 1.0

import "../../custom_components"

Rectangle {
  id: appGridView

  color: "#ddffffff"

  Timer {
    id: queuedConnectionTimer
    interval: 0
  }

  FileDialog {
    id: fileDialog

    title: qsTr("Choose an App to add to Launcher")
    onAccepted: homePageController_.addAppRequested(fileUrl)
  }

  ExclusiveGroup {
    id: exclusiveGroup
  }

  AppGridView {
    anchors {
      fill: parent
      topMargin: 18
      bottomMargin: 18
    }
  }
}
