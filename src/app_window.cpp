#include "app_window.h"
#include "model/store.h"
#include "utils.h"

#include <QFileDialog>
#include <algorithm>
#include <vector>

Q_INVOKABLE void AppWindow::appLoaded()
{
    this->_installationPath = QString(QDir::homePath() + "/.scarlet");
    this->_latestRelease = scarlet::utils::getLatestGithubRelease("thpatch/thcrap");
    this->_thcrapDownloadURL =
      QString("https://github.com/thpatch/thcrap/releases/download/%1/thcrap.zip")
        .arg(this->_latestRelease);

    qDebug() << "Installation path:" << this->_installationPath;
    qDebug() << "Latest thcrap release:" << this->_latestRelease;
    qDebug() << "Thcrap download URL:" << this->_thcrapDownloadURL;

    // Create the DB if needed
    scarlet::store::openDatabase(this->_installationPath + "/scarlet.db");

    // Symlink Steam to standard Windows location that THCRAP expects
    // This is only done if it wasn't already done during setup
    QTimer::singleShot(100, this, &AppWindow::createSymlink);

    // Sort by game name
    auto entries = scarlet::store::fetchEntries();

    // Populate the model with games from the DB
    for (const auto& entry : entries) {
        _gameModel->addItem(entry.first, entry.second);
    }

    _gameModel->sortByName();

    QString winePrefixPath = this->_installationPath + "/.wine-thcrap";
    qDebug() << "Wine prefix path:" << winePrefixPath;

    if (!QDir(winePrefixPath).exists()) {
        emit firstTimeSetup();
        this->createWinePrefix();
    } else {
        emit statusChanged("Wine prefix already exists.");
    }
}

AppWindow::~AppWindow()
{
    if (this->_wineWorker) {
        this->_wineWorker->deleteLater();
    }
}

void AppWindow::createWinePrefix()
{
    emit statusChanged("Creating Wine prefix...");
    emit progressChanged(true);

    QString winePrefixPath = this->_installationPath + "/.wine-thcrap";
    this->_wineWorker = new WineWorker(this, winePrefixPath);

    connect(
      this->_wineWorker, &WineWorker::statusUpdate, this, &AppWindow::onWineStatusUpdate);
    connect(this->_wineWorker, &WineWorker::finished, this, &AppWindow::onWineFinished);

    this->_wineWorker->start();
}

// Signal handlers - dispatch events to QML

void AppWindow::onWineStatusUpdate(const QString& status)
{
    emit statusChanged(status);
}

void AppWindow::onWineFinished(bool success, const QString& message)
{
    emit progressChanged(false);
    emit statusChanged(message);
    emit wineSetupFinished(success, message);

    if (success) {
        if (!QDir(_installationPath + "/thcrap").exists()) {
            downloadTHCRAP();
        } else {
            emit statusChanged("THCRAP already downloaded.");
        }

        // Symlink Steam to standard Windows location that THCRAP expects
        QTimer::singleShot(1000, this, &AppWindow::createSymlink);
    }

    // Clean up later on

    if (_wineWorker) {
        _wineWorker->quit();
        _wineWorker->deleteLater();
        _wineWorker = nullptr;
    }
}

Q_INVOKABLE void AppWindow::launchGame(const QString& gamePath)
{
    QProcess* gameProcess = new QProcess(this);
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();

    // Check for a local copy of thcrap first
    QString thcrapPath;
    if (QDir(gamePath + "/thcrap").exists()) {
        thcrapPath = gamePath + "/thcrap";
    } else {
        thcrapPath = this->_installationPath + "/thcrap";
    }

    env.insert("WINEPREFIX", this->_installationPath + "/.wine-thcrap");
    env.insert("WINEDEBUG", "-fixme");

    // Add thcrap to Wine's PATH so thcrap_loader.exe can be found
    QString winePath = env.value("PATH");
    env.insert("PATH", thcrapPath + ":" + winePath);

    gameProcess->setProcessEnvironment(env);
    gameProcess->setWorkingDirectory(QFileInfo(gamePath).absolutePath());

    // Use wine to launch the game
    qDebug() << "Launching game with wine:" << gamePath;

    gameProcess->start("wine", QStringList() << gamePath);

    connect(gameProcess,
            &QProcess::finished,
            this,
            [this, gameProcess](int exitCode, QProcess::ExitStatus status) {
                emit statusChanged("Game exited with exit code " +
                                   QString::number(exitCode));
                gameProcess->deleteLater();
            });
}

// Hacky looking workaround to get a native QT dialog
Q_INVOKABLE QString AppWindow::openNativeDialog(const QString& filters)
{
    QString filePath =
      QFileDialog::getOpenFileName(nullptr, "Select Game Executable", QString(), filters);
    return filePath;
}

Q_INVOKABLE void AppWindow::addGameFromPath(const QString& filePath)
{
    // Add the game to the model
    QString fileName = QFileInfo(filePath).fileName();
    qDebug() << "File name of selected game:" << fileName;

    if (this->_gameModel != nullptr) {
        this->_gameModel->addItem(fileName, filePath);
    }

    this->_gameModel->sortByName();
}

// THCRAP

Q_INVOKABLE void AppWindow::launchTHCRAP()
{
    QString thcrapPath = this->_installationPath + "/thcrap";
    if (!QDir(thcrapPath).exists()) {
        emit statusChanged("THCRAP not found, downloading...");
        QTimer::singleShot(250, []() {});
        downloadTHCRAP();
        return;
    }

    emit statusChanged("Launching THCRAP...");
    emit progressChanged(true);

    // Launch through Wine with proper environment
    QProcess* thcrapProcess = new QProcess(this);
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("WINEPREFIX", this->_installationPath + "/.wine-thcrap");
    env.insert("WINEDEBUG", "-fixme");
    thcrapProcess->setProcessEnvironment(env);

    // Use wine to launch thcrap.exe
    thcrapProcess->start("wine", QStringList() << (thcrapPath + "/thcrap.exe"));

    connect(thcrapProcess, &QProcess::finished, this, [this, thcrapProcess]() {
        emit progressChanged(false);
        emit statusChanged("THCRAP finished");
        thcrapProcess->deleteLater();
    });
}

// THCRAP configurator

Q_INVOKABLE void AppWindow::launchConfigurator(const QString& gamePath)
{
    // Launch the configurator for the specified game
    qDebug() << "Launching configurator for game at:" << gamePath;

    // Launch through Wine with proper environment
    QProcess* process = new QProcess(this);
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("WINEPREFIX", this->_installationPath + "/.wine-thcrap");
    env.insert("WINEDEBUG", "-fixme");

    // Add thcrap to Wine's PATH so thcrap_loader.exe can be found
    QString winePath = env.value("PATH");
    env.insert("PATH", gamePath + ":" + winePath);

    process->setProcessEnvironment(env);
    process->setWorkingDirectory(QFileInfo(gamePath).absolutePath());

    // Use wine to launch the configurator
    QString configuratorPath = findConfigurator(gamePath);
    if (!configuratorPath.isEmpty()) {
        process->start("wine", QStringList() << configuratorPath);
    }

    connect(process, &QProcess::finished, this, [this, process]() {
        emit progressChanged(false);
        emit statusChanged("THCRAP finished");
        process->deleteLater();
    });
}

QString AppWindow::findConfigurator(const QString& gamePath)
{
    QFileInfo fileInfo(gamePath);
    QDir gameDir = fileInfo.absoluteDir();
    QStringList files = gameDir.entryList(QDir::Files);

    // Get the base name of the game file (without extension)
    QString gameBaseName = fileInfo.baseName(); // "th08 (thpatch-en)"

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
        return gameDir.absoluteFilePath(bestMatch);
    }

    return QString();
}

// TODO: DRY, move this to a common class so it can be shared between app_window.cpp and
// list_model.cpp
int AppWindow::calculateSimilarity(const QString& gameName, const QString& fileName)
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

// End of THCRAP

void AppWindow::createSymlink()
{
    QString steamPath = QDir::homePath() + "/.steam/steam/steamapps/common";
    QString winePrefixPath = this->_installationPath + "/.wine-thcrap";
    QString targetPath =
      winePrefixPath + "/drive_c/Program Files (x86)/Steam/steamapps/common";

    // Debug: Check if Wine prefix exists
    if (!QDir(winePrefixPath + "/drive_c").exists()) {
        emit statusChanged("Wine prefix not ready for Steam symlink");
        return;
    }

    if (!QDir(steamPath).exists()) {
        qDebug() << "Steam directory not found:" << steamPath;
        emit statusChanged("Steam directory not found");
        return;
    }

    // Create the full directory structure
    QDir().mkpath(QFileInfo(targetPath).absolutePath());

    // Remove existing symlink if any
    if (QFileInfo(targetPath).exists()) {
        QFile::remove(targetPath);
    }

    bool linkResult = QFile::link(steamPath, targetPath);
    qDebug() << "Link result: " << linkResult;
}

void AppWindow::downloadTHCRAP()
{
    QString thcrapPath = this->_installationPath + "/thcrap";
    if (QDir(thcrapPath).exists()) {
        emit statusChanged("THCRAP already downloaded.");
        return;
    }

    emit statusChanged("Downloading THCRAP...");
    QTimer::singleShot(250, []() {});

    emit progressChanged(true);

    QString zipFilePath = this->_installationPath + "/thcrap.zip";
    bool downloadSuccess =
      scarlet::utils::downloadFile(this->_thcrapDownloadURL, zipFilePath);
    if (!downloadSuccess) {
        emit statusChanged("Failed to download THCRAP.");
        emit progressChanged(false);
        return;
    }

    emit statusChanged("Extracting THCRAP...");
    bool extractSuccess = scarlet::utils::extractZip(zipFilePath, thcrapPath);
    QTimer::singleShot(250, []() {});

    if (!extractSuccess) {
        emit statusChanged("Failed to extract THCRAP.");
        emit progressChanged(false);
        return;
    }

    // Clean up the zip file
    QFile::remove(zipFilePath);

    emit statusChanged("THCRAP downloaded and extracted successfully.");
    emit progressChanged(false);
}