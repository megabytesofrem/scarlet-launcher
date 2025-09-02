#include "utils.h"

#include <cstdlib>
#include <string>

#include <QIcon>
#include <QProcess>
#include <QTemporaryFile>
#include <QtCore>

namespace Utils {
bool checkWineInstalled()
{
    auto wineTools = { "wine", "wrestool", "winetricks" };
    for (const auto& tool : wineTools) {
        std::string cmd = "which " + std::string(tool) + " > /dev/null 2>&1";
        if (std::system(cmd.c_str()) != 0) {
            return false;
        }
    }
}

QString getLatestGithubRelease(const QString& repo)
{
    QProcess process;
    process.start("curl", { "-s", "https://api.github.com/repos/" + repo + "/releases/latest" });
    if (!process.waitForFinished(5000) || process.exitCode() != 0) {
        return QString();
    }

    QByteArray output = process.readAllStandardOutput();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(output);
    if (jsonDoc.isObject()) {
        QJsonObject jsonObj = jsonDoc.object();
        if (jsonObj.contains("tag_name")) {
            return jsonObj.value("tag_name").toString();
        }
    }

    return QString();
}

QList<QString> findThcrapPatchedGames(const QString& path)
{
    QList<QString> games;

    // Check if the path exists
    QFileInfo pathInfo(path);
    if (!pathInfo.exists() || !pathInfo.isDir()) {
        return games;
    }

    // Match games ending with (en), they have been patched
    QRegularExpression re(R"(th.*\(en\)\.exe$)", QRegularExpression::CaseInsensitiveOption);
    QDirIterator iter(path, QDir::Files, QDirIterator::Subdirectories);

    while (iter.hasNext()) {
        QString filePath = iter.next();
        if (re.match(QFileInfo(filePath).fileName()).hasMatch()) {
            games.append(filePath);
        }
    }

    return games;
}

QIcon extractIconFromExe(const QString& exePath)
{
    QTemporaryFile tempFile("icon_XXXXXX.ico");
    if (!tempFile.open()) {
        return QIcon();
    }

    QString tmpPath = tempFile.fileName();
    tempFile.close();

    // Extract using wrestool
    QProcess proc;
    QStringList args;
    args << "-x" << "-t14" << "-o" << tmpPath << exePath;
    proc.start("wrestool", args);

    if (proc.waitForFinished(5000) && proc.exitCode() == 0) {
        QIcon icon(tmpPath);
        QFile::remove(tmpPath);
        return icon;
    }

    QFile::remove(tmpPath);
    return QIcon();
}
}
