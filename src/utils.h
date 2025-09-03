#pragma once

#include <QtCore>

namespace scarlet::utils {

/**
 * Check if wine and all its tools are installed
 */
bool isWineInstalled();

/**
 * Run a command with given arguments and environment variables
 */
void runCommand(const QString& cmd,
                const QStringList& args,
                const QProcessEnvironment& env);

bool downloadFile(const QString& url, const QString& outputPath);

bool extractZip(const QString& zipPath, const QString& outputDir);

/**
 * Fetch the latest Github release tag for a given repo
 */
QString getLatestGithubRelease(const QString& repo);

/**
 * Search the filesystem recursively for any THCRAP patched games
 */
QList<QString> findThcrapPatchedGames(const QString& path);

/**
 * Extract the icon from a Windows executable file
 */
QIcon extractIconFromExe(const QString& exePath);

}