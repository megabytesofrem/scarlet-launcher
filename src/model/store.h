#pragma once

#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QVariant>

using Source = scarlet::model::Source;
using GameInfo = scarlet::model::GameMetadata;

namespace scarlet::store {

inline bool openDatabase(const QString& path = "scarlet.db")
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(path);
    if (!db.open()) {
        qWarning() << "Failed to open database:" << db.lastError().text();
        return false;
    }
    return true;
}

inline bool createTables()
{
    QSqlQuery query;
    return query.exec("CREATE TABLE IF NOT EXISTS games ("
                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                      "source TEXT NOT NULL,"
                      "name TEXT NOT NULL UNIQUE,"
                      "path TEXT NOT NULL"
                      ")");
}

inline bool addEntry(const QString& source, const QString& name, const QString& path)
{
    QSqlQuery query;
    query.prepare("INSERT INTO games (source, name, path) VALUES (?, ?, ?)");
    query.addBindValue(source);
    query.addBindValue(name);
    query.addBindValue(path);
    return query.exec();
}

inline bool removeEntry(const QString& name)
{
    QSqlQuery query;
    query.prepare("DELETE FROM games WHERE name = ?");
    query.addBindValue(name);
    return query.exec();
}

inline bool hasEntry(const QString& name)
{
    QSqlQuery query;
    query.prepare("SELECT COUNT(*) FROM games WHERE name = ?");
    query.addBindValue(name);
    query.exec();
    query.next();
    return query.value(0).toInt() > 0;
}

inline QList<GameInfo> fetchEntries()
{
    QList<GameInfo> entries;
    QSqlQuery query("SELECT * FROM games");
    while (query.next()) {
        GameInfo info;
        info.source = static_cast<Source>(query.value("source").toInt());
        info.name = query.value("name").toString();
        info.path = query.value("path").toString();
        entries.append(info);
    }
    return entries;
}
}