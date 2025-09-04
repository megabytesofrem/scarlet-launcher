#include "wine_worker.h"
#include "utils.h"

#include <QProcess>
#include <QProcessEnvironment>

using namespace scarlet;

WineWorker::WineWorker(QObject* parent, const QString& winePrefixPath)
  : QThread(parent)
  , _winePrefixPath(winePrefixPath)
{
}

bool WineWorker::wineboot()
{
    QStringList args = { "mkdir", "-p", _winePrefixPath };
    utils::runCommand("mkdir", args, this->getProcessEnvironment());

    args = { "wineboot", "--init" };
    if (!utils::isWineInstalled()) {
        emit finished(false, "Wine is not installed");
        return false;
    }

    utils::runCommand("wine", args, this->getProcessEnvironment());

    // All good, we can proceed
    return true;
}

WineWorker::~WineWorker()
{
    // Wait for thread to finish
    if (isRunning()) {
        quit();
        wait(5000);
    }

    // Cleanup
    if (_wineProcess && _wineProcess->state() != QProcess::NotRunning) {
        _wineProcess->kill();
        _wineProcess->waitForFinished(3000);
        _wineProcess->deleteLater();
        _wineProcess = nullptr;
    }
}

void WineWorker::run()
{
    // Get the environment variables
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("WINEPREFIX", this->getWinePrefixPath());
    env.insert("WINEDEBUG", "-fixme");
    env.insert("HOME", QDir::homePath());

    this->_workerEnv = env;

    bool isWineInstalled = utils::isWineInstalled();
    if (!isWineInstalled) {
        emit finished(false, "Wine is not installed");
        return;
    }

    if (!wineboot()) {
        emit finished(false, "Failed to create wine prefix");
        return;
    }

    // Logging

    emit logMessage("Winetricks installation started at " +
                    QDateTime::currentDateTime().toString());
    emit logMessage("======================================================");

    QFile* logFile = new QFile(_winePrefixPath + "/winetricks.log");
    if (logFile->open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append)) {
        QTextStream out(logFile);
        out << "Winetricks installation started at "
            << QDateTime::currentDateTime().toString() << "\n";
        out << "======================================================\n";
        out.flush();
    }

    // Install winetricks dependencies
    QStringList deps = { "dsound",    "d3dx9_36",  "dxdiag",    "xact",     "dinput8",
                         "vcrun2010", "vcrun2013", "corefonts", "dotnet40", "dotnet48" };

    QStringList winetricksArgs;
    winetricksArgs << "--unattended" << "--force";
    winetricksArgs << deps; // Append the list directly

    _wineProcess = std::make_unique<QProcess>();
    _wineProcess->setProcessEnvironment(this->getProcessEnvironment());

    // IMPORTANT: Merge stderr into stdout like Python does
    _wineProcess->setProcessChannelMode(QProcess::MergedChannels);

    // Connect to readyRead signal for real-time output
    connect(_wineProcess.get(), &QProcess::readyReadStandardOutput, [this, logFile]() {
        QByteArray data = _wineProcess->readAllStandardOutput();
        if (!data.isEmpty()) {
            // Split by lines and emit each one
            QTextStream out(logFile);
            QStringList lines = QString::fromUtf8(data).split('\n', Qt::KeepEmptyParts);

            for (const QString& line : lines) {
                QString trimmed = line.trimmed();

                if (trimmed.startsWith("--") || (trimmed.isEmpty()))
                    continue;

                // Only emit relevant lines, but log everything
                if (trimmed.contains(QRegularExpression(
                      "^(Executing|Downloading|Extracting|Installing|Setting up)"))) {
                    emit statusUpdate(trimmed);
                }

                qDebug() << trimmed;
                emit logMessage(trimmed);

                out << trimmed << "\n";
            }

            out.flush();
        }
    });

    connect(
      _wineProcess.get(), &QProcess::finished, this, &WineWorker::onProcessFinished);

    emit statusUpdate("Starting winetricks installation...");
    qDebug() << "Running winetricks with args:" << winetricksArgs;
    emit logMessage("Running winetricks with args: " + winetricksArgs.join(" "));
    _wineProcess->start("winetricks", winetricksArgs);

    if (!_wineProcess->waitForStarted(10000)) {
        emit finished(
          false,
          QString("Failed to start winetricks: %1").arg(_wineProcess->errorString()));
        return;
    }

    // Don't use waitForFinished() - let the signals handle everything
    exec();
}

// SLOTS

void WineWorker::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    QFile* logFile = new QFile(getWinePrefixPath() + "/winetricks.log");

    if (!logFile->open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append)) {
        qWarning() << "Failed to open log file for writing";
        delete logFile;
        logFile = nullptr;
        return;
    }

    // Get an output stream
    QTextStream out(logFile);

    // Read any remaining output
    QByteArray remainingOutput = _wineProcess->readAllStandardOutput();
    if (!remainingOutput.isEmpty()) {
        QStringList lines =
          QString::fromUtf8(remainingOutput).split('\n', Qt::KeepEmptyParts);

        for (const QString& line : lines) {
            QString trimmed = line.trimmed();
            if (!trimmed.isEmpty()) {
                emit statusUpdate(trimmed);
                qDebug() << trimmed;
                out << trimmed << "\n";
            }
        }

        out.flush();
    }

    // Log completion
    out << "=========================================" << "\n";
    out << "Winetricks finished with exit code:" << exitCode << "\n";
    out << "Finished at: " << QDateTime::currentDateTime().toString() << "\n";
    out << "=========================================" << "\n";
    out.flush();

    emit logMessage("=========================================");
    emit logMessage("Winetricks finished with exit code:" + QString::number(exitCode));
    emit logMessage("Finished at: " + QDateTime::currentDateTime().toString());
    emit logMessage("=========================================");

    logFile->close();
    delete logFile;

    qDebug() << "Winetricks finished with exit code:" << exitCode;

    if (exitCode != 0) {
        QString errorMsg = QString("Winetricks failed with exit code %1").arg(exitCode);
        emit finished(false, errorMsg);
    } else {
        emit finished(true, "Winetricks dependencies installed successfully");
    }

    quit();
}