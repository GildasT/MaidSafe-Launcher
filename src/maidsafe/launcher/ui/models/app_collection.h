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

#ifndef APP_COLLECTION_H_
#define APP_COLLECTION_H_

#include "maidsafe/launcher/ui/helpers/qt_push_headers.h"
#include "maidsafe/launcher/ui/helpers/qt_pop_headers.h"

namespace maidsafe {

namespace launcher {

namespace ui {


// Appinfo

class Data : public QObject {
  Q_OBJECT

  Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)
  Q_PROPERTY(QString group READ group WRITE setGroup NOTIFY groupChanged FINAL)
  Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged FINAL)
  Q_PROPERTY(QDateTime lastAccess READ lastAccess WRITE setLastAccess NOTIFY lastAccessChanged FINAL)
  Q_PROPERTY(bool favorite READ favorite WRITE setFavorite NOTIFY favoriteChanged FINAL)
  Q_PROPERTY(bool driveAccess READ driveAccess WRITE setDriveAccess NOTIFY driveAccessChanged FINAL)

 public:
  template<typename T, typename U>
  Data(T&& name, U&& path, QObject* parent)
      : QObject{parent},
        name_{std::forward<T>(name)},
        path_{std::forward<U>(path)} { }

  Data(const Data& other)
      : QObject{other.parent()},
        name_{other.name_},
        group_{other.group_},
        path_{other.path_},
        last_access_{other.last_access_},
        favorite_{other.favorite_},
        drive_access_{other.drive_access_} { }

  Data& operator=(const Data& other) {
    setName(other.name_);
    setGroup(other.group_);
    setPath(other.path_);
    setLastAccess(other.last_access_);
    setFavorite(other.favorite_);
    setDriveAccess(other.drive_access_);

    return *this;
  }

  Data() = default;
  Data(Data&& other) = default;
  Data& operator=(Data&& other) = default;
  ~Data() override = default;

  QString name() const { return name_; }
  void setName(const QString new_name) {
    if (new_name != name_) {
      name_ = new_name;
      emit nameChanged(name_);
    }
  }
  Q_SIGNAL void nameChanged(QString new_name);

  QString path() const { return path_; }
  void setPath(const QString new_path) {
    if (new_path != path_) {
      path_ = new_path;
      emit pathChanged(path_);
    }
  }
  Q_SIGNAL void pathChanged(QString new_path);

  QString group() const { return group_; }
  void setGroup(const QString new_group) {
    if (new_group != group_) {
      group_ = new_group;
      emit groupChanged(group_);
    }
  }
  Q_SIGNAL void groupChanged(QString new_group);

  QDateTime lastAccess() const { return last_access_; }
  void setLastAccess(const QDateTime new_name) {
    if (new_name != last_access_) {
      last_access_ = new_name;
      emit lastAccessChanged(last_access_);
    }
  }
  Q_SIGNAL void lastAccessChanged(QDateTime new_name);

  bool favorite() const { return favorite_; }
  void setFavorite(const bool new_name) {
    if (new_name != favorite_) {
      favorite_ = new_name;
      emit favoriteChanged(favorite_);
    }
  }
  Q_SIGNAL void favoriteChanged(bool new_name);

  bool driveAccess() const { return drive_access_; }
  void setDriveAccess(const bool new_drive_access) {
    if (new_drive_access != drive_access_) {
      drive_access_ = new_drive_access;
      emit driveAccessChanged(drive_access_);
    }
  }
  Q_SIGNAL void driveAccessChanged(bool new_drive_access);

 private:
  QString name_;
  QString group_;
  QString path_;
  QDateTime last_access_{QDateTime::currentDateTimeUtc()};
  bool favorite_{false};
  bool drive_access_{false};
};

class AppCollection : public QAbstractListModel {
  Q_OBJECT

public:
  using ModelRoleContainer_t = QHash<int, QByteArray>;

  enum {
    DataRole = Qt::UserRole + 1,
    NameRole,
    GroupRole,
    PathRole,
    LastAccessRole,
    FavoriteRole,
    DriveAccessRole,
  };

  explicit AppCollection(QObject* parent = nullptr);

  ModelRoleContainer_t roleNames() const override;
  int rowCount(const QModelIndex& = QModelIndex{}) const override;
  QVariant data(const QModelIndex& index, int role /*= Qt::DisplayRole */) const override;
  QVariant data(const Data* application, int role /*= Qt::DisplayRole */) const;

//  void AddData(const QString& name, const QColor& color);
//  void RemoveData(const QString& name);

//  void UpdateData(const QString& name, const Data& new_data);
//  void UpdateData(const QString& name, const QString& new_name);
//  void UpdateData(const QString& name, const QColor& new_color);

//  void MoveData(int index_from, int index_to);

  const std::vector<Data*>& DataCollection() const { return data_collection_; }

 private:
  ModelRoleContainer_t roles_;
  std::vector<Data*> data_collection_;
};

}  // namespace ui

}  // namespace launcher

}  // namespace maidsafe

#endif // APP_COLLECTION_H_
