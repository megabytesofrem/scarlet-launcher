#pragma once

#include "utils.h"

#include <QIcon>
#include <QImage>
#include <QImageReader>
#include <QQuickImageProvider>

/**
 * Custom icon provider to extract the icon from the game exe
 */
class IconProvider : public QQuickImageProvider
{
  public:
    IconProvider()
      : QQuickImageProvider(QQuickImageProvider::Image)
    {
    }

    QImage requestImage(const QString& id,
                        QSize* size,
                        const QSize& requestedSize) override
    {
        qDebug() << "IconProvider requested:" << id;

        QString filePath = id;

        // Convert file:// URL to local path if needed
        if (filePath.startsWith("file://")) {
            filePath = QUrl(id).toLocalFile();
        }

        qDebug() << "Converted to local path:" << filePath;
        qDebug() << "File exists:" << QFile::exists(filePath);

        // Check if file exists
        if (!QFile::exists(filePath)) {
            qDebug() << "File does not exist, returning default icon";
            QImage defaultIcon(24, 24, QImage::Format_ARGB32);
            defaultIcon.fill(Qt::gray);
            return defaultIcon;
        }

        // Extract icon using your utils function
        qDebug() << "Extracting icon from:" << filePath;
        QIcon icon = scarlet::utils::extractIconFromExe(filePath);

        if (icon.isNull()) {
            qDebug() << "Icon extraction failed, returning default";

            QImageReader reader(":/ScarletLauncher/resources/ui/icon_default.png");
            reader.setScaledSize(requestedSize.isValid() ? requestedSize : QSize(24, 24));

            QImage defaultIcon = reader.read();

            qDebug() << "QImageReader error:" << reader.errorString();

            return defaultIcon;
        }

        // Convert QIcon to QImage
        QSize iconSize = requestedSize.isValid() ? requestedSize : QSize(24, 24);
        QPixmap pixmap = icon.pixmap(iconSize);
        QImage image = pixmap.toImage();

        qDebug() << "Successfully extracted icon, size:" << image.size();

        if (size) {
            *size = image.size();
        }

        return image;
    }
};