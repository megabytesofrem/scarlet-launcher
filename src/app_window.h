#pragma once

#include "model/list_model.h"
#include "wine_worker.h"

#include <QObject>
#include <QtCore>
#include <memory>

namespace scarlet {

class AppWindow : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString logMessage READ getLogMessage NOTIFY logMessageChanged)

  public:
    explicit AppWindow(QObject* parent = nullptr)
      : QObject(parent)
      , _gameModel(std::make_unique<scarlet::model::ListModel>())
    {
    }

    ~AppWindow();

    Q_INVOKABLE void appLoaded();
    Q_INVOKABLE QString openNativeDialog(const QString& filters);
    Q_INVOKABLE void addGameFromPath(const QString& filePath);
    Q_INVOKABLE void launchTHCRAP();
    Q_INVOKABLE void launchGame(const QString& gamePath);

    // Configurator stuff
    Q_INVOKABLE void launchConfigurator(const QString& gamePath);

    void setModel(scarlet::model::ListModel* model) { this->_gameModel.reset(model); }
    scarlet::model::ListModel* getModel() const { return this->_gameModel.get(); }

    QString getLastSelectedGamePath() const { return _lastSelectedGamePath; }
    QString getLogMessage() const { return _logMessage; }

  signals:
    void logMessageChanged();
    void firstTimeSetup();

    // Wine worker
    void statusChanged(const QString& status);
    void progressChanged(bool visible);
    void wineSetupFinished(bool success, const QString& message);

    void thcrapOpened();
    void thcrapClosed();

  private slots:
    void onWineStatusUpdate(const QString& status);
    void onWineFinished(bool success, const QString& message);

    void onThcrapOpened();
    void onThcrapClosed();

  public slots:
    void appendLog(const QString& message)
    {
        _logMessage += message + "\n";
        emit logMessageChanged();
    }

  private:
    std::unique_ptr<scarlet::model::ListModel> _gameModel;

    QString _installationPath;
    QString _latestRelease;
    QString _thcrapDownloadURL;
    std::unique_ptr<WineWorker> _wineWorker;

    QString _lastSelectedGamePath;
    QString _logMessage;

    // Wine stuff
    void setupWineEnvironment();
    void createWinePrefix();
    void createSymlink();
    void downloadTHCRAP();

    QString findConfigurator(const QString& gamePath);
    int calculateSimilarity(const QString& gameName, const QString& fileName);
};

} // namespace scarlet
