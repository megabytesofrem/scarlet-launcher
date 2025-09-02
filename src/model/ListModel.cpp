#include "ListModel.h"
#include <QDebug>

ListModel::ListModel(QObject* parent)
    : QAbstractListModel(parent)
{
}

int ListModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_games.count();
}

QVariant ListModel::data(const QModelIndex& index, int role) const
{
    if (index.row() < 0 || index.row() >= m_games.count()) {
        qDebug() << "Invalid index:" << index.row() << "count:" << m_games.count();
        return QVariant();
    }

    const GameInfo& game = m_games[index.row()];
    qDebug() << "Data requested for index:" << index.row() << "role:" << role << "name:" << game.name;

    switch (role) {
    case NameRole:
        return game.name;
    case PathRole:
        return game.path;
    case Qt::DisplayRole: // Add DisplayRole support
        return game.name;
    }

    qDebug() << "Unhandled role:" << role;
    return QVariant();
}

QHash<int, QByteArray> ListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[PathRole] = "path";
    return roles;
}

void ListModel::addItem(const QString& name, const QString& path)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_games.append({ name, path });
    endInsertRows();

    qDebug() << "Added game:" << name << "at" << path << "Total count:" << m_games.count();
    emit countChanged();
}

void ListModel::remove(int index)
{
    if (index < 0 || index >= m_games.count())
        return;

    beginRemoveRows(QModelIndex(), index, index);
    const QString removedName = m_games[index].name;
    m_games.removeAt(index);
    endRemoveRows();

    qDebug() << "Removed game:" << removedName;
    emit countChanged();
}

int ListModel::count() const
{
    qDebug() << "Count requested:" << m_games.count();
    return m_games.count();
}

QString ListModel::getGameName(int index) const
{
    if (index < 0 || index >= m_games.count())
        return QString();
    return m_games[index].name;
}

QString ListModel::getGamePath(int index) const
{
    if (index < 0 || index >= m_games.count())
        return QString();
    return m_games[index].path;
}
