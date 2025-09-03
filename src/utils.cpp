#include "utils.h"

#include <cstdlib>
#include <string>

#include <QIcon>
#include <QProcess>
#include <QTemporaryFile>
#include <QtCore>

namespace scarlet::utils {

bool isWineInstalled()
{
    auto wineTools = { "wine", "wrestool", "winetricks" };
    for (const auto& tool : wineTools) {
        std::string cmd = "which " + std::string(tool) + " > /dev/null 2>&1";
        if (std::system(cmd.c_str()) != 0) {
            return false;
        }
    }

    return true;
}

void runCommand(const QString& cmd,
                const QStringList& args,
                const QProcessEnvironment& env)
{
    QProcess process;
    process.setProcessEnvironment(env);
    process.start(cmd, args);

    if (!process.waitForFinished()) {
        QString errorMsg = process.errorString();
        qDebug() << "Process error:" << errorMsg;

        return;
    }
}

bool downloadFile(const QString& url, const QString& outputPath)
{
    QProcess process;
    process.start("curl", QStringList() << "-L" << "-o" << outputPath << url);
    if (!process.waitForFinished(5000) || process.exitCode() != 0) {
        return false;
    }
    return true;
}

bool extractZip(const QString& zipPath, const QString& outputDir)
{
    QProcess process;
    process.start("unzip", QStringList() << "-o" << zipPath << "-d" << outputDir);
    if (!process.waitForFinished(5000) || process.exitCode() != 0) {
        return false;
    }
    return true;
}

QString getLatestGithubRelease(const QString& repo)
{
    QProcess process;
    process.start("curl",
                  { "-s", "https://api.github.com/repos/" + repo + "/releases/latest" });
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
    QRegularExpression re(R"(th.*\(en\)\.exe$)",
                          QRegularExpression::CaseInsensitiveOption);
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
        qDebug() << "Failed to create temp file";
        return QIcon();
    }

    QString tmpPath = tempFile.fileName();
    tempFile.close();

    // Extract using wrestool
    QProcess proc;
    QStringList args;
    args << "-x" << "-t14" << "-o" << tmpPath << exePath;
    qDebug() << "Running: wrestool" << args.join(" ");

    proc.start("wrestool", args);

    if (proc.waitForFinished(5000)) {
        if (proc.exitCode() == 0) {
            if (QFile::exists(tmpPath) && QFileInfo(tmpPath).size() > 0) {
                QIcon icon(tmpPath);
                QFile::remove(tmpPath);
                qDebug() << "Icon created successfully, null:" << icon.isNull();
                return icon;
            }
        }
    } else {
        qDebug() << "wrestool error:" << proc.errorString();
    }

    QFile::remove(tmpPath);
    qDebug() << "Icon extraction failed";
    return QIcon();
}

}