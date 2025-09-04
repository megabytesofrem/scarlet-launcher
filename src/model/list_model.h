#pragma once

#include <QAbstractListModel>
#include <QImage>
#include <QStringList>

namespace scarlet::model {

/**
 * The Touhou game to launch
 **/
struct GameInfo
{
    QString name;
    QString path;
    bool hasConfigurator = false;

    // List of patches applied e.g vpatch, thprac
    QStringList patches;
};

class ListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

  public:
    enum Roles
    {
        NameRole = Qt::UserRole + 1,
        PathRole,
        HasConfiguratorRole,
        PatchesRole
    };

    explicit ListModel(QObject* parent = nullptr);

    // QAbstractListModel interface
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Custom methods callable from QML
    Q_INVOKABLE void addItem(const QString& name, const QString& path);
    Q_INVOKABLE void addItemWithPatches(const QString& name,
                                        const QString& path,
                                        const QStringList& patches);

    Q_INVOKABLE void remove(int index);
    Q_INVOKABLE int count() const;
    void sortByName();
    Q_INVOKABLE QString getGameName(int index) const;
    Q_INVOKABLE QString getGamePath(int index) const;

  signals:
    void countChanged();

  private:
    QList<GameInfo> m_games;

    bool checkForConfigurator(const QString& path);
    int calculateSimilarity(const QString& gameName, const QString& fileName);
};

}