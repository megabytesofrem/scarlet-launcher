#pragma once

#include "model/list_model.h"
#include "wine_worker.h"

#include <QObject>
#include <QtCore>

class AppWindow : public QObject
{
    Q_OBJECT
  public:
    explicit AppWindow(QObject* parent = nullptr)
      : QObject(parent)
    {
    }

    ~AppWindow();

    Q_INVOKABLE void appLoaded();
    Q_INVOKABLE QString openNativeDialog(const QString& filters);
    Q_INVOKABLE void addGameFromPath(const QString& filePath);
    Q_INVOKABLE void launchTHCRAP();
    Q_INVOKABLE void launchGame(const QString& gamePath);

    void setModel(scarlet::model::ListModel* model) { this->_gameModel = model; }

  signals:
    void firstTimeSetup();

    // Wine worker
    void statusChanged(const QString& status);
    void progressChanged(bool visible);
    void wineSetupFinished(bool success, const QString& message);

  private slots:
    void onWineStatusUpdate(const QString& status);
    void onWineFinished(bool success, const QString& message);

  private:
    scarlet::model::ListModel* _gameModel = nullptr;

    QString _installationPath;
    QString _latestRelease;
    QString _thcrapDownloadURL;
    WineWorker* _wineWorker;

    // Wine stuff
    void setupWineEnvironment();
    void createWinePrefix();
    void createSymlink();
    void downloadTHCRAP();
};