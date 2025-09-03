#pragma once

#include <QThread>
#include <QtCore>

/**
 * Worker thread for setting up a wine prefix.
 *
 * This is never to be used for short-lived wine tasks such as launching games.
 */
class WineWorker : public QThread
{
    Q_OBJECT
  public:
    explicit WineWorker(QObject* parent = nullptr, const QString& winePrefixPath = "");
    void run() override;

    ~WineWorker();

  private:
    QProcess* _wineProcess = nullptr;
    QString _winePrefixPath;
    QProcessEnvironment _workerEnv;
    bool wineboot();

  signals:
    void statusUpdate(const QString& status);
    void finished(bool success, const QString& message);
};
