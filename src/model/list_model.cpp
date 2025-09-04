#include "list_model.h"
#include "store.h"
#include <QDebug>

#include <QDir>
#include <QFileInfo>
#include <QProcess>
#include <QRegularExpression>
#include <algorithm>

namespace scarlet::model {

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

    const GameMetadata& game = m_games[index.row()];

    switch (role) {
        case NameRole:
            return game.name;
        case PathRole:
            return game.path;
        case Qt::DisplayRole: // Add DisplayRole support
            return game.name;
        case HasConfiguratorRole:
            return game.hasConfigurator;
        case PatchesRole:
            return game.patches;
    }

    qDebug() << "Unhandled role:" << role;
    return QVariant();
}

QHash<int, QByteArray> ListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[PathRole] = "path";
    roles[HasConfiguratorRole] = "hasConfigurator";
    roles[PatchesRole] = "patches";
    return roles;
}

void ListModel::addItem(const Source& source, const QString& name, const QString& path)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    bool hasConfig = checkForConfigurator(path);

    m_games.append({ source, name, path, hasConfig, QStringList() });
    endInsertRows();

    qDebug() << "Added game:" << name << "at" << path
             << "Total count:" << m_games.count();
    emit countChanged();
}

void ListModel::addItemWithPatches(const Source& source,
                                   const QString& name,
                                   const QString& path,
                                   const QStringList& patches)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    bool hasConfig = checkForConfigurator(path);

    m_games.append({ source, name, path, hasConfig, patches });
    endInsertRows();

    qDebug() << "Added game with patches:" << name << "at" << path
             << "Patches:" << patches << "Total count:" << m_games.count();
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

    // Special case for THCRAP managed games since we need to remove the shortcut
    // to prevent Scarlet from re-adding it
    if (m_games[index].source == Source::THCRAP) {
        // Remove the shortcut for THCRAP managed games
        scarlet::store::removeEntry(removedName);

        QFileInfo fileInfo(m_games[index].path);

        // TODO: FIGURE OUT AFTER TAKEN SHIT
    }

    scarlet::store::removeEntry(removedName);

    qDebug() << "Removed game:" << removedName;
    emit countChanged();
}

int ListModel::count() const
{
    return m_games.count();
}

void ListModel::sortByName()
{
    beginResetModel();

    std::sort(
      m_games.begin(), m_games.end(), [](const GameMetadata& a, const GameMetadata& b) {
          // Extract th## numbers for proper Touhou sorting
          QRegularExpression thRegex("th(\\d{2})");
          auto matchA = thRegex.match(a.name);
          auto matchB = thRegex.match(b.name);

          if (matchA.hasMatch() && matchB.hasMatch()) {
              int numA = matchA.captured(1).toInt();
              int numB = matchB.captured(1).toInt();
              return numA < numB; // Sort by th number
          }

          // Fallback to alphabetical for non-Touhou games
          return a.name < b.name;
      });

    endResetModel();
    emit countChanged();
}

Q_INVOKABLE
Source ListModel::getGameSource(int index) const
{
    if (index < 0 || index >= m_games.count())
        return Source::MANUAL;
    return m_games[index].source;
}

Q_INVOKABLE
QString ListModel::getGameName(int index) const
{
    if (index < 0 || index >= m_games.count())
        return QString();
    return m_games[index].name;
}

Q_INVOKABLE
QString ListModel::getGamePath(int index) const
{
    if (index < 0 || index >= m_games.count())
        return QString();
    return m_games[index].path;
}

bool ListModel::checkForConfigurator(const QString& path)
{
    QFileInfo fileInfo(path);
    QDir gameDir = fileInfo.absoluteDir();
    QStringList files = gameDir.entryList(QDir::Files);

    // Get the base name of the game file (without extension)
    QString gameBaseName = fileInfo.baseName(); // "th08 (thpatch-en)"

    QRegularExpression languages("(en|fr|it|de|gr|es|pt|nl|uk|ru|cn)",
                                 QRegularExpression::CaseInsensitiveOption);
    bool isJP = !gameBaseName.contains(languages);

    if (!isJP) {
        QRegularExpression configRegex("(custom|config)",
                                       QRegularExpression::CaseInsensitiveOption);

        QString bestMatch;
        int bestSimilarity = -1;

        for (const QString& file : files) {
            if (configRegex.match(file).hasMatch()) {
                // Calculate similarity based on common characters/patterns
                int similarity = calculateSimilarity(gameBaseName, file);

                if (similarity > bestSimilarity) {
                    bestSimilarity = similarity;
                    bestMatch = file;
                }
            }
        }

        if (!bestMatch.isEmpty()) {
            qDebug() << "Found best configurator match:" << bestMatch << "for"
                     << gameBaseName;
            return true;
        }
    } else {
        // config.exe is the filename for a standard Touhou game
        if (QFileInfo::exists(gameDir.filePath("config.exe"))) {
            qDebug() << "Found config.exe for" << gameBaseName;
            return true;
        }
    }

    return false;
}

int ListModel::calculateSimilarity(const QString& gameName, const QString& fileName)
{
    QString gameBase = gameName.toLower();
    QString fileBase = QFileInfo(fileName).baseName().toLower();

    // Remove common words that don't matter for matching
    gameBase.remove("(thpatch-en)").remove("thpatch").remove("en").simplified();
    fileBase.remove("(thpatch-en)").remove("thpatch").remove("en").simplified();

    int score = 0;

    // High score for exact substring match
    if (fileBase.contains(gameBase) || gameBase.contains(fileBase)) {
        score += 100;
    }

    // Score for common prefixes (th08, th07, etc.)
    QRegularExpression thPattern("th\\d{2}");
    auto gameMatch = thPattern.match(gameBase);
    auto fileMatch = thPattern.match(fileBase);

    if (gameMatch.hasMatch() && fileMatch.hasMatch()) {
        if (gameMatch.captured(0) == fileMatch.captured(0)) {
            score += 50; // Same th## number
        }
    }

    // Score for character overlap
    for (int i = 0; i < gameBase.length(); i++) {
        if (fileBase.contains(gameBase[i])) {
            score += 1;
        }
    }

    qDebug() << "Similarity between" << gameName << "and" << fileName << ":" << score;
    return score;
}

}