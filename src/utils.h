#pragma once
#include <qt6/QtGui/qicon.h>

namespace Utils
{
    bool checkWineInstalled();

    QString getLatestGithubRelease(const QString &repo);
    QList<QString> findThcrapPatchedGames(const QString &path);
    QIcon extractIconFromExe(const QString &exePath);
}