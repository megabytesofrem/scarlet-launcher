#pragma once

#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QVariant>

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

inline QList<QPair<QString, QString>> fetchEntries()
{
    QList<QPair<QString, QString>> entries;
    QSqlQuery query("SELECT name, path FROM games");
    while (query.next()) {
        entries.append(qMakePair(query.value(0).toString(), query.value(1).toString()));
    }
    return entries;
}
}