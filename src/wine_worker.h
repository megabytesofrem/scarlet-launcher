#pragma once

#include <QThread>
#include <QtCore>

#include <memory>

/**
 * Worker thread for setting up a wine prefix and running winetricks.
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

    QProcess* getProcess() const { return _wineProcess.get(); }
    QString getWinePrefixPath() const { return _winePrefixPath; }
    QProcessEnvironment getProcessEnvironment() const { return _workerEnv; }

  private:
    std::unique_ptr<QProcess> _wineProcess;
    QString _winePrefixPath;
    QProcessEnvironment _workerEnv;
    bool wineboot();

  signals:
    void logMessage(const QString& message);
    void statusUpdate(const QString& status);
    void finished(bool success, const QString& message);

  private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
};
