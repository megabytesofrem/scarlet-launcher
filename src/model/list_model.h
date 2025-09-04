#pragma once

#include <QAbstractListModel>
#include <QImage>
#include <QStringList>

namespace scarlet::model {

enum class Source
{
    THCRAP, // Game added via THCRAP
    MANUAL  // Game added manually
};

/**
 * The Touhou game to launch
 **/
struct GameMetadata
{
    Source source;
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
        SourceRole = Qt::UserRole + 1,
        NameRole,
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
    Q_INVOKABLE void addItem(const Source& source,
                             const QString& name,
                             const QString& path);

    Q_INVOKABLE void addItemWithPatches(const Source& source,
                                        const QString& name,
                                        const QString& path,
                                        const QStringList& patches);

    Q_INVOKABLE void remove(int index);
    Q_INVOKABLE int count() const;
    void sortByName();

    // Extracting metadata
    Q_INVOKABLE Source getGameSource(int index) const;
    Q_INVOKABLE QString getGameName(int index) const;
    Q_INVOKABLE QString getGamePath(int index) const;

  signals:
    void countChanged();

  private:
    QList<GameMetadata> m_games;

    bool checkForConfigurator(const QString& path);
    int calculateSimilarity(const QString& gameName, const QString& fileName);
};

}