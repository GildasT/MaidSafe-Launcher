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

#include "maidsafe/launcher/ui/models/group_app_collection.h"

namespace maidsafe {

namespace launcher {

namespace ui {

  GroupAppCollection::GroupAppCollection(QObject* parent)
    : QAbstractItemModel{parent},
      root_group_{new Group("Home", this)} {
    roles_[DataRole] = "data";
    roles_[NameRole] = "name";
    roles_[TypeRole] = "type";
    roles_[GroupRole] = "group";
    roles_[GroupIconsRole] = "groupIcons";
    roles_[PathRole] = "path";
    roles_[IconRole] = "icon";
    roles_[LastAccessRole] = "lastAccess";
    roles_[FavoriteRole] = "favorite";
    roles_[DriveAccessRole] = "driveAccess";
    root_group_->appendItem(new Application("App A", "", root_group_));
    Group* group_b = new Group("Group B", root_group_);
    group_b->appendItem(new Application("App B1", "", group_b));
    group_b->appendItem(new Application("App B2", "", group_b));
    group_b->appendItem(new Application("App B3", "", group_b));
    root_group_->appendItem(group_b);
    root_group_->appendItem(new Application("App C", "", root_group_));
  }

  QHash<int, QByteArray> GroupAppCollection::roleNames() const {
    return roles_;
  }

  int GroupAppCollection::columnCount(const QModelIndex&) const {
    return 1;
  }

  QVariant GroupAppCollection::data(const QModelIndex& index, int role) const {
    if(index.isValid()) {
      Item* item = static_cast<Item*>(index.internalPointer());
      switch (role) {
        case DataRole:
          return QVariant::fromValue(item);
        case NameRole:
          return QVariant::fromValue(item->name());
        case TypeRole:
          return QVariant::fromValue(item->type());
      }

      if (item->type() == "Application") {
        Application* application = static_cast<Application*>(item);
        switch (role) {
          case GroupRole:
            return QVariant::fromValue(application->group()->name());
          case PathRole:
            return QVariant::fromValue(application->path());
          case IconRole:
            return QVariant::fromValue(application->icon());
          case LastAccessRole:
            return QVariant::fromValue(application->lastAccess());
          case FavoriteRole:
            return QVariant::fromValue(application->favorite());
          case DriveAccessRole:
            return QVariant::fromValue(application->driveAccess());
        }
      } else if (item->type() == "Group" && role == GroupIconsRole) {
          Group* group = static_cast<Group*>(item);
          QVariantList list;
          for (int i = 0; i < group->childrenItem().size() && list.size() < 4; i++) {
            if (group->childrenItem()[i]->type() == "Application") {
              Application* application = static_cast<Application*>(group->childrenItem()[i]);
              list << application->icon();
            }
          }
          return list;
      }
    }
    return QVariant();
  }

  QModelIndex GroupAppCollection::index(int row, int column, const QModelIndex& parent) const {
    Group* group = root_group_;
    if(parent.isValid()) {
        Item* item = static_cast<Item*>(parent.internalPointer());
        if (item->type() == "Group") {
          group = static_cast<Group*>(item);
        }
    }
    if (row >= 0 && row < group->childrenItem().size()) {
      return createIndex(row, column, group->childrenItem().at(row));
    }
    return QModelIndex();
  }

  QModelIndex GroupAppCollection::parent(const QModelIndex& index) const {
    if(index.isValid()) {
      Item* item = static_cast<Item*>(index.internalPointer());
      Group* parentItem = item->group();
      if(parentItem && parentItem != root_group_ && parentItem->group()) {
        return createIndex(parentItem->group()->childrenItem().indexOf(parentItem), 0, static_cast<Item*>(parentItem));
      }
    }
    return QModelIndex();
  }

  int GroupAppCollection::rowCount(const QModelIndex& parent) const {
    if(parent.isValid()) {
      Item* item = static_cast<Item*>(parent.internalPointer());
      if (item->type() == "Group") {
        return static_cast<Group*>(item)->childrenItem().size();
      } else {
        return 0;
      }
    } else {
      return root_group_->childrenItem().size();
    }
  }

}  // namespace ui

}  // namespace launcher

}  // namespace maidsafe
