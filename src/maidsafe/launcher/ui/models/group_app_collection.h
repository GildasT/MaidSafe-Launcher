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

#ifndef GROUP_APP_COLLECTION_H_
#define GROUP_APP_COLLECTION_H_

#include "app_collection.h"

namespace maidsafe {

namespace launcher {

namespace ui {

class Group;

class Item : public QObject {
  Q_OBJECT

  Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)
  Q_PROPERTY(QString type READ type FINAL)

 public:

  Item(const QString& name, const QString& type, QObject* parent)
    : QObject{parent},
      name_{name},
      type_{type},
      group_{nullptr} {}

  Item(const QString& name, const QString& type, Group* group, QObject* parent)
    : QObject{parent},
      name_{name},
      type_{type},
      group_{group} {}

  QString type() const { return type_; }

  QString name() const { return name_; }
  void setName(const QString& name) {
    if (name_ != name) {
        name_ = name;
        emit nameChanged(name_);
      }
  }
  Q_SIGNAL void nameChanged(QString new_name);

  Group* group() const { return group_; }
  void setGroup(Group* new_group) {
    if (new_group != group_) {
      group_ = new_group;
      emit groupChanged(group_);
    }
  }
  Q_SIGNAL void groupChanged(Group* new_group);

 private:
  QString name_;
  QString type_;
  Group* group_;
};

class Group : public Item {
  Q_OBJECT

public:
  Group(const QString& name, QObject* parent)
    : Item{name, "Group", parent} {}

  Group(const QString& name, Group* group)
    : Item{name, "Group", group, group} {}

  const QList<Item*>& childrenItem() { return children_; }
  void insertItem(int index, Item* child) {
    children_.insert(index, child);
    child->setGroup(this);
    child->setParent(this);
    emit childrenItemChanged();
  }
  void appendItem(Item* child) {
    children_.append(child);
    child->setGroup(this);
    child->setParent(this);
    emit childrenItemChanged();
  }
  Q_SIGNAL void childrenItemChanged();

 private:
  QList<Item*> children_;
};

class Application : public Item {
  Q_OBJECT

  Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged FINAL)
  Q_PROPERTY(QString icon READ icon WRITE setIcon NOTIFY iconChanged FINAL)
  Q_PROPERTY(QDateTime lastAccess READ lastAccess WRITE setLastAccess NOTIFY lastAccessChanged FINAL)
  Q_PROPERTY(bool favorite READ favorite WRITE setFavorite NOTIFY favoriteChanged FINAL)
  Q_PROPERTY(bool driveAccess READ driveAccess WRITE setDriveAccess NOTIFY driveAccessChanged FINAL)

 public:
  Application(const QString& name, const QString& path, Group* group)
      : Item{name, "Application", group, group},
        path_{path} { }

  QString path() const { return path_; }
  void setPath(const QString new_path) {
    if (new_path != path_) {
      path_ = new_path;
      emit pathChanged(path_);
    }
  }
  Q_SIGNAL void pathChanged(QString new_path);

  QString icon() const { return icon_; }
  void setIcon(const QString new_icon) {
    if (new_icon != icon_) {
      icon_ = new_icon;
      emit iconChanged(icon_);
    }
  }
  Q_SIGNAL void iconChanged(QString new_icon);

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
  QString path_;
  QString icon_{ "/resources/mock/icon.png" };
  QDateTime last_access_{QDateTime::currentDateTimeUtc()};
  bool favorite_{false};
  bool drive_access_{false};
};

class GroupAppCollection : public QAbstractItemModel {
  Q_OBJECT

 public:

  enum {
    DataRole = Qt::UserRole + 1,
    NameRole,
    TypeRole,
    GroupRole,
    GroupIconsRole,
    PathRole,
    IconRole,
    LastAccessRole,
    FavoriteRole,
    DriveAccessRole,
  };

  explicit GroupAppCollection(QObject* parent = nullptr);

  QHash<int, QByteArray> roleNames() const override;
  int columnCount(const QModelIndex & parent = QModelIndex()) const override;
  QVariant data(const QModelIndex& index, int role = DataRole) const override;
  QModelIndex index(int row, int column, const QModelIndex& parent = QModelIndex()) const override;
  QModelIndex parent(const QModelIndex & index) const override;
  int rowCount(const QModelIndex& = QModelIndex{}) const override;

private:
  QHash<int, QByteArray> roles_;
  Group* root_group_;
};

}  // namespace ui

}  // namespace launcher

}  // namespace maidsafe

#endif // GROUP_APP_COLLECTION_H_
