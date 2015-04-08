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

#include <QDebug>

#include "maidsafe/launcher/ui/models/app_collection.h"

namespace maidsafe {

namespace launcher {

namespace ui {

AppCollection::AppCollection(QObject* parent)
    : QAbstractListModel{parent},
      data_collection_ {
        new Data{"App A", "", this},
        new Data{"App B 1", "", this},
        new Data{"App B 2", "", this},
        new Data{"App B 3", "", this},
        new Data{"App C", "", this}} {
  roles_[DataRole] = "data";
  roles_[NameRole] = "name";
  roles_[GroupRole] = "group";
  roles_[PathRole] = "path";
  roles_[LastAccessRole] = "lastAccess";
  roles_[FavoriteRole] = "favorite";
  roles_[DriveAccessRole] = "driveAccess";
  data_collection_[1]->setGroup("Group B");
  data_collection_[2]->setGroup("Group B");
  data_collection_[3]->setGroup("Group B");
}

AppCollection::ModelRoleContainer_t AppCollection::roleNames() const {
  return roles_;
}

int AppCollection::rowCount(const QModelIndex&) const {
  return data_collection_.size();
}

QVariant AppCollection::data(const QModelIndex& index, int role /*= Qt::DisplayRole */) const {
  if (index.row() >= 0 && index.row() < static_cast<int>(data_collection_.size())) {
    return data(data_collection_[index.row()], role);
  }
  return QVariant();
}

QVariant AppCollection::data(const Data* application, int role /*= Qt::DisplayRole */) const {
  QVariant return_val;

  switch (role) {
    case DataRole:
      return_val = QVariant::fromValue(
            const_cast<QObject*>(static_cast<const QObject*>(application)));
      break;
    case NameRole:
      return_val = QVariant::fromValue(application->name());
      break;
    case GroupRole:
      return_val = QVariant::fromValue(application->group());
      break;
    case PathRole:
      return_val = QVariant::fromValue(application->path());
      break;
    case LastAccessRole:
      return_val = QVariant::fromValue(application->lastAccess());
      break;
    case FavoriteRole:
      return_val = QVariant::fromValue(application->favorite());
      break;
    case DriveAccessRole:
      return_val = QVariant::fromValue(application->driveAccess());
      break;
    default:
      break;
  }

  return return_val;
}

//void AppCollection::AddData(const QString& name, const QColor& color) {
//  beginInsertRows(QModelIndex{}, data_collection_.size(), data_collection_.size());
//  data_collection_.emplace_back(name, color);
//  endInsertRows();
//}

//void AppCollection::RemoveData(const QString& name) {
//  for (std::size_t index{}; index < data_collection_.size(); ++index) {
//    if (data_collection_[index].name() == name) {
//      beginRemoveRows(QModelIndex{}, index, index);
//      data_collection_.erase(data_collection_.begin() + index);
//      endRemoveRows();
//      break;
//    }
//  }
//}

//void AppCollection::UpdateData(const QString& name, const Data& new_data) {
//  for (std::size_t index{}; index < data_collection_.size(); ++index) {
//    if (data_collection_[index].name() == name) {
//      data_collection_[index] = new_data;
//      break;
//    }
//  }
//}

//void AppCollection::UpdateData(const QString& name, const QString& new_name) {
//  for (std::size_t index{}; index < data_collection_.size(); ++index) {
//    if (data_collection_[index].name() == name) {
//      data_collection_[index].setName(new_name);
//      break;
//    }
//  }
//}

//void AppCollection::UpdateData(const QString& name, const QColor& new_color) {
//  for (std::size_t index{}; index < data_collection_.size(); ++index) {
//    if (data_collection_[index].name() == name) {
//      data_collection_[index].setObjColor(new_color);
//      break;
//    }
//  }
//}

//void AppCollection::MoveData(int index_from, int index_to) {
//  int size = data_collection_.size();
//  if (index_from >= 0 && index_from < size &&
//      index_to   >= 0 && index_to   < size &&
//      index_from != index_to) {
//    auto row_parent(QModelIndex{});
//    auto temp_data(std::move(data_collection_[index_from]));

//    if (index_from > index_to) {
//      if(beginMoveRows(row_parent, index_from, index_from, row_parent, index_to)) {
//        for (int i = index_from; i > index_to; --i) {
//          data_collection_[i] = std::move(data_collection_[i - 1]);
//        }
//      }
//    } else if (beginMoveRows(row_parent, index_from, index_from, row_parent, index_to + 1)) {
//      for (int i = index_from; i < index_to; ++i) {
//        data_collection_[i] = std::move(data_collection_[i + 1]);
//      }
//    }
//    data_collection_[index_to] = std::move(temp_data);
//    endMoveRows();
//  }
//}

}  // namespace ui

}  // namespace launcher

}  // namespace maidsafe
